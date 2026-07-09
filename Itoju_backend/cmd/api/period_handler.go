package api

import (
	"errors"
	"net/http"
	"time"

	"github.com/olagookundavid/itoju/internal/models"
)

func (app *Application) GetMenstrualCycle(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	periodDays, err := app.Models.UserPeriod.GetRecentCycleDays(r.Context(), user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":     "Retrieved All Period data",
		"period_days": periodDays}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) GetCycleDay(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	id, err := app.readStringParam(r, "id")
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}
	periodDay, err := app.Models.UserPeriod.GetCycleDay(r.Context(), id, user.ID)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.NotFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	env := envelope{
		"message":    "Retrieved Period data",
		"period_day": periodDay}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) AddMenstrualCycle(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	var input struct {
		StartDate    string `json:"start_date"`
		CycleLength  int    `json:"cycle_length"`
		PeriodLength int    `json:"period_length"`
	}

	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	date, err := time.Parse("2006-01-02", input.StartDate)
	if err != nil {
		err := errors.New("invalid date format")
		app.badRequestResponse(w, r, err)
		return
	}
	// Bound the lengths so a single request can't be asked to generate an
	// unreasonable number of day rows.
	if input.PeriodLength < 1 || input.CycleLength < input.PeriodLength+9 || input.CycleLength > 60 {
		app.badRequestResponse(w, r, errors.New("invalid period_length/cycle_length"))
		return
	}

	// Persist the cycle and its generated day rows atomically.
	if _, err := app.Models.UserPeriod.CreateCycle(r.Context(), user.ID, date, input.CycleLength, input.PeriodLength); err != nil {
		switch {
		case errors.Is(err, models.ErrRecordAlreadyExist):
			app.recordAlreadyExistsResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	env := envelope{
		"message": "Successful Created User Cycle",
	}
	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) UpdateMenstrualCycle(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	id, err := app.readStringParam(r, "id")
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}

	cycleDay, err := app.Models.UserPeriod.GetCycleDay(r.Context(), id, user.ID)
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
		IsPeriod    *bool     `json:"is_period"`
		IsOvulation *bool     `json:"is_ovulation"`
		Flow        *float32  `json:"flow"`
		Pain        *float32  `json:"pain"`
		Tags        *[]string `json:"tags"`
		CMQ         *string   `json:"cmq"`
	}
	err = app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	if input.Pain != nil {
		cycleDay.Pain = *input.Pain
	}
	if input.Flow != nil {
		cycleDay.Flow = *input.Flow
	}
	if input.IsOvulation != nil {
		cycleDay.IsOvulation = *input.IsOvulation
	}
	if input.IsPeriod != nil {
		cycleDay.IsPeriod = *input.IsPeriod
	}
	if input.CMQ != nil {
		cycleDay.CMQ = *input.CMQ
	}
	if input.Tags != nil {
		cycleDay.Tags = *input.Tags
	}

	err = app.Models.UserPeriod.UpdateCycleDay(r.Context(), cycleDay)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrEditConflict):
			app.editConflictResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	env := envelope{
		"message":  "Successfully updated Cycle Day",
		"cycleDay": cycleDay,
	}
	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) DeleteMenstrualCycle(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)

	id, err := app.readStringParam(r, "id")
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}

	err = app.Models.UserPeriod.DeleteMenstrualCycle(r.Context(), id, user.ID)
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
