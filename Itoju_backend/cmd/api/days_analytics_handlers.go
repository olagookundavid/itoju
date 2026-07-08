package api

import (
	"net/http"
)

func (app *Application) GetBowelDaysAnalytics(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)
	days, err := app.readBoundedIntParam(r, "days", 1, 366)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	analytics, err := app.Models.AnalyticsMetric.Get7DaysBowelTypeOccurrences(r.Context(), user.ID, int(days))
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":          "Retrieved All Analytics for user",
		"analyticsMetrics": analytics}

	app.respond(w, r, http.StatusOK, env)

}

func (app *Application) GetExerciseDaysAnalytics(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)
	days, err := app.readBoundedIntParam(r, "days", 1, 366)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	analytics, err := app.Models.AnalyticsMetric.Get7DaysExerciseOccurrences(r.Context(), user.ID, int(days))
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":          "Retrieved All Analytics for user",
		"analyticsMetrics": analytics}

	app.respond(w, r, http.StatusOK, env)

}

func (app *Application) GetSymsDaysAnalytics(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)
	id, err := app.readIDParam(r)
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}
	days, err := app.readBoundedIntParam(r, "days", 1, 366)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	analytics, err := app.Models.AnalyticsMetric.GetSymptom7DaysOccurrences(r.Context(), user.ID, int(id), int(days))
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":          "Retrieved All Analytics for user",
		"analyticsMetrics": EnsureAllDaysPresent(analytics)}

	app.respond(w, r, http.StatusOK, env)

}

func (app *Application) GetTagsDaysAnalytics(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)
	days, err := app.readBoundedIntParam(r, "days", 1, 366)
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

	analytics, err := app.Models.AnalyticsMetric.Get7DaysTagOccurrences(r.Context(), user.ID, int(days), tagToQuery)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":          "Retrieved All Analytics for user",
		"analyticsMetrics": analytics}

	app.respond(w, r, http.StatusOK, env)

}

func EnsureAllDaysPresent(metrics map[int]float64) map[int]float64 {
	for i := 0; i <= 6; i++ {
		if _, exists := metrics[i]; !exists {
			metrics[i] = 0
		}
	}
	return metrics
}
