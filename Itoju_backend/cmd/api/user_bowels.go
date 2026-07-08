package api

import (
	"errors"
	"net/http"

	"github.com/olagookundavid/itoju/internal/models"
)

func (app *Application) GetUserBowelMetrics(w http.ResponseWriter, r *http.Request) {

	date, err := app.GetDate(r)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := app.contextGetUser(r)
	bowelMetric, err := app.Models.BowelMetric.GetUserBowelMetrics(r.Context(), user.ID, date)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":      "Retrieved All Bowel Metrics for user",
		"bowelMetrics": bowelMetric}

	app.respond(w, r, http.StatusOK, env)

}

func (app *Application) UpdateBowelMetric(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	id, err := app.readIDParam(r)
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}
	var input struct {
		Time *string   `json:"time"`
		Type *float64  `json:"type"`
		Pain *float64  `json:"pain"`
		Tags *[]string `json:"tags"`
	}
	if err = app.readJSON(w, r, &input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	err = app.Models.BowelMetric.UpdateBowelMetric(r.Context(), id, user.ID, input.Time, input.Type, input.Pain, input.Tags)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.NotFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Successfully updated User Bowel Metrics"})
}

func (app *Application) CreateBowelMetric(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)
	date, err := app.GetDate(r)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	var input struct {
		Time string   `json:"time"`
		Type float64  `json:"type"`
		Pain float64  `json:"pain"`
		Tags []string `json:"tags"`
	}
	err = app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	bowelMetric := &models.BowelMetric{
		Time: input.Time, Type: input.Type, Pain: input.Pain, Tags: input.Tags, Date: date}

	err = app.Models.BowelMetric.InsertBowelMetric(r.Context(), user.ID, bowelMetric)

	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.AwardPoints(user.ID, "Bowel", 2)
	env := envelope{
		"message": "Successfully Created User Bowel Metrics!",
	}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) DeleteBowelMetric(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	id, err := app.readIDParam(r)
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}

	err = app.Models.BowelMetric.DeleteBowelMetric(r.Context(), id, user.ID)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.NotFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Bowel Metric successfully deleted"})
}
