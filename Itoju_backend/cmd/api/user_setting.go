package api

import (
	"errors"
	"net/http"

	"github.com/olagookundavid/itoju/internal/models"
)

func (app *Application) GetMenses(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	menses, err := app.Models.Menses.GetMenses(r.Context(), user.ID)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			env := envelope{
				"message": "Retrieved User Menses",
				"menses": map[string]int{
					"period_len": 0,
					"cycle_len":  0,
				}}

			app.respond(w, r, http.StatusOK, env)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	env := envelope{
		"message": "Retrieved User Menses",
		"menses":  menses}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) UpdateMenses(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	var input struct {
		Period_len *int `json:"period_len"`
		Cycle_len  *int `json:"cycle_len"`
	}
	if err := app.readJSON(w, r, &input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	if (input.Period_len != nil && *input.Period_len < 0) ||
		(input.Cycle_len != nil && *input.Cycle_len < 0) {
		app.badRequestResponse(w, r, errors.New("period_len/cycle_len cannot be negative"))
		return
	}

	menses, err := app.Models.Menses.UpsertMenses(r.Context(), user.ID, input.Period_len, input.Cycle_len)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.respond(w, r, http.StatusOK, envelope{
		"message": "Successfully updated Menstruation",
		"menses":  menses,
	})
}

//Body Measure

func (app *Application) GetBodyMeasure(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	bodyMeasure, err := app.Models.BodyMeasure.GetBodyMeasure(r.Context(), user.ID)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			env := envelope{
				"message": "Retrieved User Body Measure",
				"body_measure": map[string]int{
					"height": 0,
					"weight": 0,
				}}

			app.respond(w, r, http.StatusOK, env)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}

	env := envelope{
		"message":      "Retrieved User Body Measure",
		"body_measure": bodyMeasure}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) UpdateBodyMeasure(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	var input struct {
		Height *int `json:"height"`
		Weight *int `json:"weight"`
	}
	if err := app.readJSON(w, r, &input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	if (input.Height != nil && *input.Height < 0) ||
		(input.Weight != nil && *input.Weight < 0) {
		app.badRequestResponse(w, r, errors.New("height/weight cannot be negative"))
		return
	}

	bodyMeasure, err := app.Models.BodyMeasure.UpsertBodyMeasure(r.Context(), user.ID, input.Height, input.Weight)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.respond(w, r, http.StatusOK, envelope{
		"message":      "Successfully updated Body Measure",
		"body_measure": bodyMeasure,
	})
}
