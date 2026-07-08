package api

import (
	"errors"
	"net/http"

	"github.com/olagookundavid/itoju/internal/models"
)

func (app *Application) GetUserMedicationMetrics(w http.ResponseWriter, r *http.Request) {

	date, err := app.GetDate(r)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := app.contextGetUser(r)
	medicationMetric, err := app.Models.MedicationMetric.GetUserMedicationMetrics(r.Context(), user.ID, date)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":           "Retrieved All Medication Metrics for user",
		"medicationMetrics": medicationMetric}

	app.respond(w, r, http.StatusOK, env)

}

func (app *Application) UpdateMedicationMetric(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)
	id, err := app.readIDParam(r)
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}
	var input struct {
		Time     *string  `json:"time"`
		Name     *string  `json:"name"`
		Metric   *string  `json:"metric"`
		Dosage   *float64 `json:"dosage"`
		Quantity *float64 `json:"quantity"`
	}
	if err = app.readJSON(w, r, &input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	err = app.Models.MedicationMetric.UpdateMedicationMetric(r.Context(), id, user.ID, input.Time, input.Name, input.Metric, input.Dosage, input.Quantity)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.NotFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Successfully updated User Medication Metrics"})
}

func (app *Application) CreateMedicationMetric(w http.ResponseWriter, r *http.Request) {

	user := app.contextGetUser(r)
	date, err := app.GetDate(r)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}

	var input struct {
		Time     string  `json:"time"`
		Name     string  `json:"name"`
		Metric   string  `json:"metric"`
		Dosage   float64 `json:"dosage"`
		Quantity float64 `json:"quantity"`
	}
	err = app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	medicationMetric := &models.MedicationMetric{
		Time: input.Time, Dosage: input.Dosage, Quantity: input.Quantity, Metric: input.Metric, Date: date, Name: input.Name}

	err = app.Models.MedicationMetric.InsertMedicationMetric(r.Context(), user.ID, medicationMetric)

	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.AwardPoints(user.ID, "Medication", 2)
	env := envelope{
		"message": "Successfully Created User Medication Metrics!",
	}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) DeleteMedicationMetric(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	id, err := app.readIDParam(r)
	if err != nil {
		app.NotFoundResponse(w, r)
		return
	}

	err = app.Models.MedicationMetric.DeleteMedicationMetric(r.Context(), id, user.ID)
	if err != nil {
		switch {
		case errors.Is(err, models.ErrRecordNotFound):
			app.NotFoundResponse(w, r)
		default:
			app.serverErrorResponse(w, r, err)
		}
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Medication Metric successfully deleted"})
}
