package api

import (
	"net/http"
)

func (app *Application) GetBowelYearAnalytics(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)
	year, err := app.readBoundedIntParam(r, "year", 2000, 2100)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	analytics, err := app.Models.AnalyticsMetric.GetYearBowelTypeOccurrences(user.ID, int(year))
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":          "Retrieved All Analytics for user",
		"analyticsMetrics": analytics}

	app.respond(w, r, http.StatusOK, env)

}

func (app *Application) GetExerciseYearAnalytics(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)
	year, err := app.readBoundedIntParam(r, "year", 2000, 2100)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	analytics, err := app.Models.AnalyticsMetric.GetYearExerciseTypeOccurrences(user.ID, int(year))
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":          "Retrieved All Analytics for user",
		"analyticsMetrics": analytics}

	app.respond(w, r, http.StatusOK, env)

}

func (app *Application) GetSymsYearAnalytics(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)
	id, err := app.readIDParam(r)
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}
	year, err := app.readBoundedIntParam(r, "year", 2000, 2100)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	analytics, err := app.Models.AnalyticsMetric.GetYearSymptomOccurrences(user.ID, int(id), int(year))
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":          "Retrieved All Analytics for user",
		"analyticsMetrics": EnsureAllMonthsPresent(analytics)}

	app.respond(w, r, http.StatusOK, env)

}

func (app *Application) GetTagsYearAnalytics(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)
	year, err := app.readBoundedIntParam(r, "year", 2000, 2100)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	tagToQuery, err := app.readStringParam(r, "tag")
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	if tagToQuery == "General" {
		tagToQuery = ""
	}

	analytics, err := app.Models.AnalyticsMetric.GetYearTagOccurrences(user.ID, int(year), tagToQuery)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":          "Retrieved All Analytics for user",
		"analyticsMetrics": analytics}

	app.respond(w, r, http.StatusOK, env)

}

func EnsureAllMonthsPresent(metrics map[int]float64) map[int]float64 {
	for i := 1; i <= 12; i++ {
		if _, exists := metrics[i]; !exists {
			metrics[i] = 0
		}
	}
	return metrics
}
