package api

import (
	"errors"
	"net/http"

	"github.com/olagookundavid/itoju/internal/models"
)

func (app *Application) GetUserUrineMetrics(w http.ResponseWriter, r *http.Request) {

	date, err := app.GetDate(r)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := app.contextGetUser(r)
	urineMetric, err := app.Models.UrineMetric.GetUserUrineMetrics(r.Context(), user.ID, date)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":      "Retrieved All Urine Metrics for user",
		"urineMetrics": urineMetric}

	app.respond(w, r, http.StatusOK, env)

}

func (app *Application) UpdateUrineMetric(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	id, err := app.readIDParam(r)
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}
	var input struct {
		Time     *string   `json:"time"`
		Type     *float64  `json:"type"`
		Pain     *float64  `json:"pain"`
		Quantity *float64  `json:"quantity"`
		Tags     *[]string `json:"tags"`
	}
	if err = app.readJSON(w, r, &input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	err = app.Models.UrineMetric.UpdateUrineMetric(r.Context(), id, user.ID, input.Time, input.Type, input.Pain, input.Quantity, input.Tags)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.NotFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Successfully updated User Urine Metrics"})
}

func (app *Application) CreateUrineMetric(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)
	date, err := app.GetDate(r)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	var input struct {
		Time     string   `json:"time"`
		Type     float64  `json:"type"`
		Pain     float64  `json:"pain"`
		Quantity float64  `json:"quantity"`
		Tags     []string `json:"tags"`
	}
	err = app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	urineMetric := &models.UrineMetric{
		Time: input.Time, Type: input.Type, Pain: input.Pain, Tags: input.Tags, Quantity: input.Quantity, Date: date}

	err = app.Models.UrineMetric.InsertUrineMetric(r.Context(), user.ID, urineMetric)

	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.AwardPoints(user.ID, "Urine", 2)
	env := envelope{
		"message": "Successfully Created User Urine Metrics!",
	}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) DeleteUrineMetric(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	id, err := app.readIDParam(r)
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}

	err = app.Models.UrineMetric.DeleteUrineMetric(r.Context(), id, user.ID)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.NotFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Urine Metric successfully deleted"})
}
