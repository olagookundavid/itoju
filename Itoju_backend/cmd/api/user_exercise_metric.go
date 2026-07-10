package api

import (
	"errors"
	"net/http"

	"github.com/olagookundavid/itoju/internal/models"
)

func (app *Application) GetUserExerciseMetrics(w http.ResponseWriter, r *http.Request) {
	date, err := app.GetDate(r)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := app.contextGetUser(r)
	exerciseMetric, err := app.Models.ExerciseMetric.GetUserExerciseMetric(r.Context(), user.ID, date)

	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			env := envelope{
				"message":        "Retrieved All Exercise Metrics for user",
				"exerciseMetric": exerciseMetric,
			}
			app.respond(w, r, http.StatusOK, env)

		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	env := envelope{
		"message":        "Retrieved All Exercise Metrics for user",
		"exerciseMetric": exerciseMetric,
	}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) CreateExerciseMetric(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)
	date, err := app.GetDate(r)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	var input struct {
		Name string `json:"name"`
	}
	err = app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	exerciseMetric := &models.ExerciseMetric{
		UserID: user.ID,
		Date:   date,
		Name:   input.Name,
	}
	err = app.Models.ExerciseMetric.InsertExerciseMetric(r.Context(), exerciseMetric)

	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.AwardPoints(user.ID, "Exercise", 2)
	env := envelope{
		"message": "Successfully Created Exercise Metrics!",
	}

	app.respond(w, r, http.StatusOK, env)

}

func (app *Application) UpdateExerciseMetric(w http.ResponseWriter, r *http.Request) {
	id, err := app.readStringParam(r, "id")
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}
	user := app.contextGetUser(r)

	exerciseMetric, err := app.Models.ExerciseMetric.Get(r.Context(), id, user.ID)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.NotFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	var input struct {
		Started   *string   `json:"start"`
		Ended     *string   `json:"ended"`
		Tags      *[]string `json:"tags"`
		NoOfTimes *int      `json:"no_of_times"`
	}
	err = app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	if input.Started != nil {
		exerciseMetric.Started = *input.Started
	}

	if input.Ended != nil {
		exerciseMetric.Ended = *input.Ended
	}

	if input.NoOfTimes != nil {
		exerciseMetric.NoOfTimes = *input.NoOfTimes
	}

	if input.Tags != nil {
		exerciseMetric.Tags = *input.Tags
	}

	err = app.Models.ExerciseMetric.UpdateExerciseMetric(r.Context(), exerciseMetric, id, user.ID)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.NotFoundResponse(w, r)
		case errors.Is(err, models.ErrEditConflict):
			app.editConflictResponse(w, r)
		case errors.Is(err, models.ErrRecordAlreadyExist):
			app.recordAlreadyExistsResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	env := envelope{
		"message": "Successfully Updated Exercise Metric",
	}
	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) DeleteExerciseMetric(w http.ResponseWriter, r *http.Request) {
	id, err := app.readStringParam(r, "id")
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}
	user := app.contextGetUser(r)
	err = app.Models.ExerciseMetric.DeleteExerciseMetric(r.Context(), id, user.ID)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.NotFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Exercise Metric Successfully Deleted"})
}
