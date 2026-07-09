package api

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/olagookundavid/itoju/internal/models"
	"github.com/olagookundavid/itoju/internal/validator"
)

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
	user, err := app.Models.Users.GetByEmail(r.Context(), input.Email)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.invalidCredentialsResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	// Check if the provided password matches the actual password for the user.
	match, err := user.Password.Matches(input.Password)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	if !match {
		app.invalidCredentialsResponse(w, r)
		return
	}
	token, err := app.Models.Tokens.New(r.Context(), user.ID, models.AuthTokenTTL, models.ScopeAuthentication)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.AwardPoints(token.UserID, "Login", 5)
	// Encode the token to JSON and send it in the response along with a 201 Created // status code.
	app.respond(w, r, http.StatusOK, envelope{"message": "Successfully logged in User", "data": token})
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
	if !app.Firebase.Enabled() {
		app.errorResponse(w, r, http.StatusServiceUnavailable, "social login is not available")
		return
	}

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

	identity, err := app.Firebase.Verify(r.Context(), input.IDToken)
	if err != nil {
		// Any verification failure (bad signature, wrong audience, expired) is
		// an authentication failure — do not leak the specific reason.
		app.invalidAuthenticationTokenResponse(w, r)
		return
	}
	if identity.Email == "" || !identity.EmailVerified {
		app.errorResponse(w, r, http.StatusForbidden, "google account email is missing or unverified")
		return
	}

	user, err := app.Models.Users.GetByEmail(r.Context(), identity.Email)
	switch {
	case err == nil:
		// Existing account — log in.
		app.issueSessionToken(w, r, user.ID)
		return
	case !errors.Is(err, models.ErrRecordNotFound):
		app.serverErrorResponse(w, r, err)
		return
	}

	// No account yet: this is a first-time social sign-up.
	firstName, lastName := splitName(identity.Name, identity.Email)
	if input.Dob == "" {
		// Ask the client to collect a date of birth, then call again with it.
		err = app.writeJSON(w, http.StatusOK, envelope{
			"message":               "Additional details required to complete sign up",
			"registration_required": true,
			"email":                 identity.Email,
			"first_name":            firstName,
			"last_name":             lastName,
		}, nil)
		if err != nil {
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	dob, err := time.Parse("2006-01-02", input.Dob)
	if err != nil {
		app.badRequestResponse(w, r, errors.New("invalid dob, expected format YYYY-MM-DD"))
		return
	}

	newUser := &models.User{
		FirstName: firstName,
		LastName:  lastName,
		Dob:       dob,
		Email:     identity.Email,
		Activated: true,
	}
	// Social accounts have no user-chosen password; set a random, unusable one
	// so the password_hash column is satisfied and cannot be guessed.
	randomPassword, err := generateRandomSecret()
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	if err = newUser.Password.Set(randomPassword); err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	v := validator.New()
	if models.ValidateUser(v, newUser); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}
	if err = app.Models.Users.Insert(r.Context(), newUser); err != nil {
		switch {
		case errors.Is(err, models.ErrDuplicateEmail):
			// Raced with another sign-up; treat as login.
			existing, gerr := app.Models.Users.GetByEmail(r.Context(), identity.Email)
			if gerr != nil {
				app.serverErrorResponse(w, r, gerr)
				return
			}
			app.issueSessionToken(w, r, existing.ID)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	app.AwardPoints(newUser.ID, "Register", 10)
	app.issueSessionToken(w, r, newUser.ID)
}

// issueSessionToken mints a session auth token for the user and writes it to
// the response, awarding login points in the background.
func (app *Application) issueSessionToken(w http.ResponseWriter, r *http.Request, userID string) {
	token, err := app.Models.Tokens.New(r.Context(), userID, models.AuthTokenTTL, models.ScopeAuthentication)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.AwardPoints(token.UserID, "Login", 5)
	if err = app.writeJSON(w, http.StatusOK, envelope{"message": "Successfully logged in User", "data": token}, nil); err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

// splitName splits a provider-supplied display name into first/last names,
// falling back to the email local-part when no name is available.
func splitName(fullName, email string) (first, last string) {
	fullName = strings.TrimSpace(fullName)
	if fullName == "" {
		local := email
		if i := strings.Index(email, "@"); i > 0 {
			local = email[:i]
		}
		return local, "-"
	}
	parts := strings.Fields(fullName)
	if len(parts) == 1 {
		return parts[0], "-"
	}
	return parts[0], strings.Join(parts[1:], " ")
}

// generateRandomSecret returns a 32-byte cryptographically-random hex string,
// used as an unusable password for accounts that authenticate via a provider.
func generateRandomSecret() (string, error) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
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
