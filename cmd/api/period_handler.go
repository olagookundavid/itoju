package api

import (
	"errors"
	"fmt"
	"net/http"
	"sync"
	"time"

	"github.com/olagookundavid/itoju/internal/models"
)

func (app *Application) GetMenstrualCycle(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	ids, err := app.Models.UserPeriod.GetMensesCycleIds(user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	var periodDays = []models.CycleDay{}
	var mu sync.Mutex // Mutex to control access to periodDays
	var wg sync.WaitGroup
	var firstErr error

	for i := 0; i < len(ids); i++ {
		wg.Add(1)
		go func(id string) {
			defer wg.Done()
			defer func() {
				if rec := recover(); rec != nil {
					mu.Lock()
					if firstErr == nil {
						firstErr = fmt.Errorf("%s", rec)
					}
					mu.Unlock()
				}
			}()

			cycleDays, err := app.Models.UserPeriod.GetCycleDays(id, user.ID)
			// Collect errors/results under the mutex; never write to the
			// ResponseWriter from a goroutine (it is not concurrency-safe).
			mu.Lock()
			defer mu.Unlock()
			if err != nil {
				if firstErr == nil {
					firstErr = err
				}
				return
			}
			periodDays = append(periodDays, cycleDays...)
		}(ids[i])
	}
	wg.Wait()

	if firstErr != nil {
		app.serverErrorResponse(w, r, firstErr)
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
	periodDay, err := app.Models.UserPeriod.GetCycleDay(id, user.ID)
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

	// Start a transaction
	tx, err := app.Models.Transaction.BeginTx()
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	// Roll back on any error path; the success path commits explicitly below
	// (before the response is written) so a failed commit is still reported.
	committed := false
	defer func() {
		if !committed {
			tx.Rollback()
		}
	}()

	// Insert the menstrual cycle within the transaction
	cycle := app.Models.UserPeriod.ReturnMenstrualCycle(
		user.ID,
		input.CycleLength,
		input.PeriodLength,
		date,
	)

	cycleID, err := app.Models.UserPeriod.InsertMenstrualCycleTx(tx, &cycle)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordAlreadyExist):
			app.recordAlreadyExistsResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	// Build every cycle day, then insert them all in one statement:
	//   [0, PeriodLength)                 -> period days
	//   [PeriodLength, PeriodLength+9)     -> regular days
	//   [PeriodLength+9, CycleLength)      -> ovulation days
	days := make([]models.CycleDay, 0, input.CycleLength)
	for i := 0; i < input.PeriodLength; i++ {
		days = append(days, app.Models.UserPeriod.ReturnCycleDay(cycleID, user.ID, true, false, cycle.StartDate.AddDate(0, 0, i)))
	}
	for i := input.PeriodLength; i < (input.PeriodLength + 9); i++ {
		days = append(days, app.Models.UserPeriod.ReturnCycleDay(cycleID, user.ID, false, false, cycle.StartDate.AddDate(0, 0, i)))
	}
	for i := (input.PeriodLength + 9); i < input.CycleLength; i++ {
		days = append(days, app.Models.UserPeriod.ReturnCycleDay(cycleID, user.ID, false, true, cycle.StartDate.AddDate(0, 0, i)))
	}
	if err = app.Models.UserPeriod.BulkInsertCycleDaysTx(r.Context(), tx, days); err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	if err = tx.Commit(); err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	committed = true

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

	cycleDay, err := app.Models.UserPeriod.GetCycleDay(id, user.ID)
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

	err = app.Models.UserPeriod.UpdateCycleDay(cycleDay)
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

	err = app.Models.UserPeriod.DeleteMenstrualCycle(id, user.ID)
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
