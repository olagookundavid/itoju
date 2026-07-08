package api

import (
	"errors"
	"fmt"
	"net/http"
	"time"

	"github.com/olagookundavid/itoju/internal/models"
)

func (app *Application) GetSmileys(w http.ResponseWriter, r *http.Request) {

	smileys, err := app.Models.Smileys.GetSmileys(r.Context())
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message": "Retrieved All Smileys",
		"smileys": smileys}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) InsertUserSmileys(w http.ResponseWriter, r *http.Request) {
	var input struct {
		SmileyID int      `json:"smiley_id"`
		Tags     []string `json:"tags"`
		Date     string   `json:"date"`
	}
	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	smiley := &models.Smileys{
		Id: input.SmileyID, Tags: input.Tags,
	}
	user := app.contextGetUser(r)
	date, err := time.Parse("2006-01-02 15:04:05", input.Date)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	err = app.Models.Smileys.InsertUserSmileys(r.Context(), user.ID, *smiley, date)

	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordAlreadyExist):
			app.recordAlreadyExistsResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	env := envelope{
		"message": "Successfully added User smiley",
	}

	app.respond(w, r, http.StatusOK, env)

}

func (app *Application) GetUserSmileys(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	smileys, err := app.Models.Smileys.GetUserSmileys(r.Context(), user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message": "Retrieved All Smileys for User",
		"smileys": smileys}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) GetLatestUserSmileyForToday(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	date, err := app.GetDate(r)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	smiley, err := app.Models.Smileys.GetLatestUserSmileyForToday(r.Context(), user.ID, date)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message": "Retrieved All Smileys for User",
		"smileys": smiley}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) GetUserSmileysCountInXDays(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	id, err := app.readIDParam(r)
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}

	smileys, totalCount, err := app.Models.Smileys.GetUserSmileysCount(r.Context(), user.ID, int(id))
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":     fmt.Sprintf("Retrieved All Smiley's count for User in %d day(s)", id),
		"smileys":     smileys,
		"total_count": totalCount,
	}

	app.respond(w, r, http.StatusOK, env)
}
