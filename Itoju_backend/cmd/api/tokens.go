package api

import (
	"errors"
	"fmt"
	"net/http"
	"time"

	"github.com/olagookundavid/itoju/internal/models"
	"github.com/olagookundavid/itoju/internal/service"
	"github.com/olagookundavid/itoju/internal/validator"
)

// authService builds the auth-orchestration service from the app's
// dependencies. *Application satisfies service.PointsAwarder via AwardPoints.
func (app *Application) authService() *service.AuthService {
	return &service.AuthService{
		Users:    app.Models.Users,
		Tokens:   app.Models.Tokens,
		Points:   app,
		Firebase: app.Firebase,
	}
}

func (app *Application) LoginHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	v := validator.New()
	models.ValidateEmail(v, input.Email)
	models.ValidatePasswordPlaintext(v, input.Password)
	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}
	token, err := app.authService().Login(r.Context(), input.Email, input.Password)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrInvalidCredentials):
			app.invalidCredentialsResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	// user_id lets an offline-first client bind its local account to the server
	// user (re-keying deterministic ids) before its first cloud sync.
	app.respond(w, r, http.StatusOK, envelope{"message": "Successfully logged in User", "data": token, "user_id": token.UserID})
}

// LogoutHandler revokes the caller's session tokens server-side so a long-lived
// token can be invalidated (e.g. on sign-out or a lost device).
func (app *Application) LogoutHandler(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	if err := app.Models.Tokens.DeleteAllForUser(r.Context(), models.ScopeAuthentication, user.ID); err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	if err := app.writeJSON(w, http.StatusOK, envelope{"message": "Successfully logged out"}, nil); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// SocialLoginHandler authenticates a user via a Firebase ID token (Google
// Sign-In). The client obtains the token from Firebase Auth and sends it here;
// the server verifies it against Google's public keys before trusting the
// identity — it never trusts a client-supplied email.
//
// Behaviour:
//   - Verified token, user already exists  -> issue a session token (login).
//   - Verified token, no user yet, no dob   -> 200 {registration_required:true}
//     with the verified email/name so the client can collect a date of birth.
//   - Verified token, no user yet, dob given -> create the account (random,
//     unusable password) and issue a session token (sign-up).
func (app *Application) SocialLoginHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		IDToken string `json:"id_token"`
		Dob     string `json:"dob"` // optional, only needed for first-time sign-up
	}
	if err := app.readJSON(w, r, &input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	if input.IDToken == "" {
		app.badRequestResponse(w, r, errors.New("id_token must be provided"))
		return
	}

	res, err := app.authService().SocialLogin(r.Context(), input.IDToken, input.Dob)
	if err != nil {
		var ve *service.ValidationError
		switch {
		case errors.Is(err, service.ErrSocialLoginDisabled):
			app.errorResponse(w, r, http.StatusServiceUnavailable, "social login is not available")
		case errors.Is(err, service.ErrInvalidIDToken):
			// Don't leak the specific verification failure reason.
			app.invalidAuthenticationTokenResponse(w, r)
		case errors.Is(err, service.ErrEmailUnverified):
			app.errorResponse(w, r, http.StatusForbidden, "google account email is missing or unverified")
		case errors.Is(err, service.ErrAccountConflict):
			app.errorResponse(w, r, http.StatusConflict, "this email is already linked to a different sign-in method")
		case errors.Is(err, service.ErrInvalidDOB):
			app.badRequestResponse(w, r, errors.New("invalid dob, expected format YYYY-MM-DD"))
		case errors.As(err, &ve):
			app.failedValidationResponse(w, r, ve.Errors)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	if res.RegistrationRequired {
		// Ask the client to collect a date of birth, then call again with it.
		if err := app.writeJSON(w, http.StatusOK, envelope{
			"message":               "Additional details required to complete sign up",
			"registration_required": true,
			"email":                 res.Email,
			"first_name":            res.FirstName,
			"last_name":             res.LastName,
		}, nil); err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	if err := app.writeJSON(w, http.StatusOK, envelope{"message": "Successfully logged in User", "data": res.Token, "user_id": res.Token.UserID}, nil); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *Application) CreatePasswordResetTokenHandler(w http.ResponseWriter, r *http.Request) {
	// Parse and validate the user's email address.
	var input struct {
		Email string `json:"email"`
	}
	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	v := validator.New()
	if models.ValidateEmail(v, input.Email); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}
	// Try to retrieve the corresponding user record for the email address. If it can't
	// be found, return an error message to the client.
	user, err := app.Models.Users.GetByEmail(r.Context(), input.Email)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			v.AddError("email", "no matching email address found")
			app.failedValidationResponse(w, r, v.Errors)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	// Return an error message if the user is not activated.
	if !user.Activated {
		v.AddError("email", "user account must be activated")
		app.failedValidationResponse(w, r, v.Errors)
		return
	}
	// Atomically invalidate any previous reset codes and issue a new 6-digit OTP
	// with a 15-minute expiry, so the user is never left without a valid code and
	// concurrent requests can't leave two live codes.
	otp, err := app.Models.Tokens.ReplacePasswordResetOTP(r.Context(), user.ID, 15*time.Minute)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	// Email the user their one-time code. The code is NEVER returned in the
	// response body — that would defeat the purpose of email verification.
	firstName := user.FirstName
	email := user.Email
	app.Background(func() {
		if !app.Mailer.Enabled() {
			app.Logger.PrintError(fmt.Errorf("password reset requested for %s but mailer is disabled", email), nil)
			return
		}
		if err := app.Mailer.SendPasswordResetOTP(email, firstName, otp); err != nil {
			app.Logger.PrintError(err, map[string]string{"error": "failed to send password reset email"})
		}
	})
	env := envelope{
		"message": "If an account exists for that email, a reset code has been sent.",
	}
	app.respond(w, r, http.StatusOK, env)
}

// VerifyPasswordResetOTPHandler checks that a 6-digit code is valid for the
// given email without consuming it. The mobile app calls this between the
// "enter code" and "set new password" screens for fast feedback.
func (app *Application) VerifyPasswordResetOTPHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Email string `json:"email"`
		Otp   string `json:"otp"`
	}
	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	v := validator.New()
	models.ValidateEmail(v, input.Email)
	models.ValidateOTPPlaintext(v, input.Otp)
	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}
	_, err = app.Models.Users.GetForPasswordResetOTP(r.Context(), input.Email, input.Otp)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			v.AddError("otp", "invalid or expired code")
			app.failedValidationResponse(w, r, v.Errors)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Code verified"})
}

// go func(metricID int) {
// 	defer wg.Done()
// 	defer func() {
// 		if err := recover(); err != nil {
// 			logger.PrintError(fmt.Errorf("%s", err), nil)
// 		}
// 	}()
// 	_, err := m.DB.ExecContext(ctx, query, userID, metricID)
// 	if err != nil {
// 		errors <- err
// 		return
// 	}
// 	done <- true
// 	wg.Wait()
// }(metricID)

// logger := jsonlog.New(os.Stdout, jsonlog.LevelInfo)
