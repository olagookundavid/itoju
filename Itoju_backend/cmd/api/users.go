package api

import (
	"errors"
	"net/http"
	"time"

	"github.com/olagookundavid/itoju/internal/models"
	"github.com/olagookundavid/itoju/internal/validator"
)

func (app *Application) RegisterUserHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		FirstName string    `json:"first_name"`
		LastName  string    `json:"last_name"`
		Dob       time.Time `json:"dob"`
		Email     string    `json:"email"`
		Password  string    `json:"password"`
	}
	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := &models.User{
		FirstName: input.FirstName,
		LastName:  input.LastName,
		Dob:       input.Dob,
		Email:     input.Email,
		Activated: true}
	err = user.Password.Set(input.Password)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	v := validator.New()
	if models.ValidateUser(v, user); !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}
	err = app.Models.Users.Insert(r.Context(), user)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrDuplicateEmail):
			v.AddError("email", "a user with this email address already exists")
			app.failedValidationResponse(w, r, v.Errors)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	// _, err = app.Models.Tokens.New(user.ID, 3*24*time.Hour, models.ScopeActivation)
	// if err != nil {
	// 	app.serverErrorResponse(w, r, err)
	// 	return
	// }
	// app.background(func() {
	// 	data := map[string]any{
	// 		"activationToken": token.Plaintext,
	// 		"userID":          user.ID}
	// 	err = app.mailer.Send(user.Email, "user_welcome.html", data)
	// 	if err != nil {
	// 		app.logger.PrintError(err, nil)
	// 	}
	// })

	app.AwardPoints(user.ID, "Register", 10)
	err = app.writeJSON(w, http.StatusCreated, envelope{
		"message": "Successful Registered User",
		"user":    user}, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *Application) UpdateUserPasswordHandler(w http.ResponseWriter, r *http.Request) {
	// Parse and validate the email, one-time code and the user's new password.
	var input struct {
		Email    string `json:"email"`
		Otp      string `json:"otp"`
		Password string `json:"password"`
	}
	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	v := validator.New()
	models.ValidateEmail(v, input.Email)
	models.ValidateOTPPlaintext(v, input.Otp)
	models.ValidatePasswordPlaintext(v, input.Password)
	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}
	// Hash the new password up front, then let the model verify the OTP, apply the
	// new hash, and consume the reset tokens in a single transaction — so a valid
	// code can't survive (and be replayed) if any step fails.
	newHash, err := models.HashPassword(input.Password)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	err = app.Models.Users.ResetPasswordWithOTP(r.Context(), input.Email, input.Otp, newHash)
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
	// Send the user a confirmation message.
	env := envelope{"message": "your password was successfully reset"}
	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) ChangeUserPasswordHandler(w http.ResponseWriter, r *http.Request) {
	// Parse and validate the user's new password and password reset token.
	var input struct {
		Password           string `json:"password"`
		NewPassword        string `json:"new_password"`
		ConfirmNewPassword string `json:"confirm_new_password"`
	}
	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	v := validator.New()
	v.Check(input.NewPassword == input.ConfirmNewPassword, "new password", "doesn't match confirm password")
	v.Check(input.NewPassword != input.Password, "password", "old and new password are the same")
	models.ValidatePasswordPlaintext(v, input.Password)
	models.ValidatePasswordPlaintext(v, input.ConfirmNewPassword)
	models.ValidatePasswordPlaintext(v, input.NewPassword)

	if !v.Valid() {
		app.failedValidationResponse(w, r, v.Errors)
		return
	}
	user := app.contextGetUser(r)
	match, err := user.Password.Matches(input.Password)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	if !match {
		app.invalidCredentialsResponse(w, r)
		return
	}
	err = user.Password.Set(input.NewPassword)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	// Save the updated user record in our database, checking for any edit conflicts as normal
	err = app.Models.Users.Update(r.Context(), user)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrEditConflict):
			app.editConflictResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	// Send the user a confirmation message.
	env := envelope{"message": "your password was successfully changed"}
	app.respond(w, r, http.StatusOK, env)
}
