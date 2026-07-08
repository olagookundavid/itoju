package api

import (
	"errors"
	"net/http"

	"github.com/olagookundavid/itoju/internal/models"
)

func (app *Application) GetUserSleepMetrics(w http.ResponseWriter, r *http.Request) {

	date, err := app.GetDate(r)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := app.contextGetUser(r)
	sleepMetric, err := app.Models.SleepMetric.GetUserSleepMetrics(user.ID, date)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":      "Retrieved All Sleep Metrics for user",
		"sleepMetrics": sleepMetric}

	app.respond(w, r, http.StatusOK, env)

}

/*
 func (app *Application) FormerGetUserSleepMetrics(w http.ResponseWriter, r *http.Request) {
	date, err := app.GetDate(r)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := app.contextGetUser(r)
	dayMetricChan := make(chan *models.SleepMetric)
	nightMetricChan := make(chan *models.SleepMetric)
	dayErrChan := make(chan error)
	nightErrChan := make(chan error)
	var daySleepMetric, nightSleepMetric *models.SleepMetric
	app.goSafe(func() {
		app.getUserSleepMetricAsync(user.ID, date, dayMetricChan, dayErrChan, false)
	})
	app.goSafe(func() {
		app.getUserSleepMetricAsync(user.ID, date, nightMetricChan, nightErrChan, true)
	})
	for i := 0; i < 2; i++ {
		select {
		case dayMetric := <-dayMetricChan:
			daySleepMetric = dayMetric
		case nightMetric := <-nightMetricChan:
			nightSleepMetric = nightMetric
		case <-dayErrChan:
		case <-nightErrChan:
		}
	}
	defer close(dayMetricChan)
	defer close(dayErrChan)
	defer close(nightMetricChan)
	defer close(nightErrChan)
	env := envelope{
		"message":          "Retrieved All Sleep Metrics for user",
		"daySleepMetric":   daySleepMetric,
		"nightSleepMetric": nightSleepMetric,
	}
	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) getUserSleepMetricAsync(userID string, date time.Time, sendMetric chan<- (*models.SleepMetric), errChan chan<- error, isNight bool) {
	metric, err := app.Models.SleepMetric.GetUserSleepMetric(userID, date, isNight)
	if err != nil {
		errChan <- err
		return
	}
	sendMetric <- metric
}
*/

func (app *Application) UpdateSleepMetric(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	id, err := app.readIDParam(r)
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}
	var input struct {
		TimeSlept  *string   `json:"time_slept"`
		TimeWokeUp *string   `json:"time_woke_up"`
		Severity   *float64  `json:"severity"`
		Tags       *[]string `json:"tags"`
	}
	if err = app.readJSON(w, r, &input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	err = app.Models.SleepMetric.UpdateSleepMetric(r.Context(), id, user.ID, input.TimeSlept, input.TimeWokeUp, input.Severity, input.Tags)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.NotFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Successfully updated User Sleep Metrics"})
}

func (app *Application) CreateSleepMetric(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)
	date, err := app.GetDate(r)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	var input struct {
		TimeSlept  string   `json:"time_slept"`
		TimeWokeUp string   `json:"time_woke_up"`
		Severity   float64  `json:"severity"`
		IsNight    bool     `json:"is_night"`
		Tags       []string `json:"tags"`
	}
	err = app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	sleepMetric := &models.SleepMetric{
		IsNight: input.IsNight, TimeSlept: input.TimeSlept, TimeWokeUp: input.TimeWokeUp, Tags: input.Tags, Date: date, Severity: input.Severity}

	err = app.Models.SleepMetric.InsertSleepMetric(user.ID, sleepMetric)

	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	app.AwardPoints(user.ID, "Sleep", 2)
	env := envelope{
		"message": "Successfully Created User Sleep Metrics!",
	}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) DeleteSleepMetric(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	id, err := app.readIDParam(r)
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}

	err = app.Models.SleepMetric.DeleteSleepMetric(id, user.ID)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.NotFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Sleep Metric successfully deleted"})
}
