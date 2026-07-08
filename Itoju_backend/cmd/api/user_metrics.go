package api

import (
	"net/http"
)

func (app *Application) SetUserMetrics(w http.ResponseWriter, r *http.Request) {

	var input struct {
		Metrics []int `json:"metrics"`
	}
	if err := app.readJSON(w, r, &input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := app.contextGetUser(r)

	if err := app.Models.Metrics.SetUserMetricsBatch(user.ID, input.Metrics); err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Successfully added track metrics"})
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
	if err := app.readJSON(w, r, &input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := app.contextGetUser(r)

	if err := app.Models.Metrics.DeleteUserMetricsBatch(user.ID, input.Metrics); err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Deleted Tracked Metric for User"})
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
