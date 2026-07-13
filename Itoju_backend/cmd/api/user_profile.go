package api

import (
	"errors"
	"net/http"

	"github.com/olagookundavid/itoju/internal/models"
)

func (app *Application) GetUserProfileHandler(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	env := envelope{
		"message": "Retrieved User Profile",
		"user":    user}
	err := app.writeJSON(w, http.StatusOK, env, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}

func (app *Application) UpdateUserProfilePicHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Pic_no int `json:"pic_no"`
	}
	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	if input.Pic_no <= 0 {
		app.badRequestResponse(w, r, errors.New("pic_no must be greater than 0"))
		return
	}
	user := app.contextGetUser(r)
	user.PicNo = input.Pic_no

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

	env := envelope{"message": "your Profile pic as been updated"}
	app.respond(w, r, http.StatusOK, env)
}

// DeleteAccountHandler permanently deletes the authenticated user and, via the
// ON DELETE CASCADE foreign keys, all of their server-side data (tokens,
// tracked metrics, cycles, sync state, etc.). This is irreversible.
func (app *Application) DeleteAccountHandler(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	err := app.Models.Users.Delete(r.Context(), user.ID)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.NotFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "your account and all associated data have been deleted"})
}

// UpdateUserAliasHandler stores the display name chosen on the onboarding
// name step, so it roams with the account across devices.
func (app *Application) UpdateUserAliasHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Alias string `json:"alias"`
	}
	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	if len(input.Alias) > 50 {
		app.badRequestResponse(w, r, errors.New("alias must not be more than 50 characters"))
		return
	}
	user := app.contextGetUser(r)
	err = app.Models.Users.UpdateAlias(r.Context(), user.ID, input.Alias)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.NotFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "your display name has been updated"})
}
