package api

import (
	"errors"
	"net/http"

	"github.com/olagookundavid/itoju/internal/models"
)

func (app *Application) SetUserMetrics(w http.ResponseWriter, r *http.Request) {

	var input struct {
		Metrics []int `json:"metrics"`
	}
	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := app.contextGetUser(r)

	tx, err := app.Models.Transaction.BeginTx()
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	defer func() {
		if err != nil {
			tx.Rollback()
			app.serverErrorResponse(w, r, err)
			return
		}
		err = tx.Commit()
		if err != nil {
			app.serverErrorResponse(w, r, err)
		}
	}()

	for i := 0; i < len(input.Metrics); i++ {
		if err = app.Models.Metrics.SetUserMetrics(tx, input.Metrics[i], user.ID); err != nil {
			// deferred func rolls back and writes the error response
			return
		}
	}

	env := envelope{
		"message": "Successfully added track metrics",
	}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) GetTrackedMetrics(w http.ResponseWriter, r *http.Request) {

	metrics, err := app.Models.Metrics.GetMetrics()
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message": "Retrieved All Trackable Metrics",
		"metrics": metrics}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) GetUserTrackedMetrics(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	metrics, err := app.Models.Metrics.GetUserMetrics(user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message": "Retrieved All Tracked Metrics for User",
		"metrics": metrics}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) DeleteUserTrackedMetrics(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Metrics []int `json:"metrics"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	user := app.contextGetUser(r)

	tx, err := app.Models.Transaction.BeginTx()
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	defer func() {
		if err != nil {
			tx.Rollback()
			switch {
			case errors.Is(err, models.ErrRecordNotFound):
				app.NotFoundResponse(w, r)
			default:
				app.serverErrorResponse(w, r, err)
			}
			return
		}
		err = tx.Commit()
		if err != nil {
			app.serverErrorResponse(w, r, err)
		}
	}()

	for i := 0; i < len(input.Metrics); i++ {
		if err = app.Models.Metrics.DeleteUserMetrics(tx, user.ID, input.Metrics[i]); err != nil {
			// deferred func rolls back and writes the mapped error response
			return
		}
	}

	env := envelope{
		"message": "Deleted Tracked Metric for User"}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) GetTrackedMetricsStatus(w http.ResponseWriter, r *http.Request) {

	date, err := app.GetDate(r)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	user := app.contextGetUser(r)

	resultMap, err := app.Models.Metrics.GetMetricsStatus(user.ID, date)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message": "retrieved Tracked Metric Status for User", "metrics_status": resultMap}

	app.respond(w, r, http.StatusOK, env)
}
