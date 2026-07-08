package api

import (
	"net/http"
)

func (app *Application) GetSymptoms(w http.ResponseWriter, r *http.Request) {

	symptoms, err := app.Models.Symptoms.GetSymptoms()
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":  "Retrieved All Symptoms",
		"symptoms": symptoms}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) GetUserSymptoms(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	symptoms, err := app.Models.Symptoms.GetUserSymptoms(user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":  "Retrieved All Symptoms for User",
		"symptoms": symptoms}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) InsertUserSymptoms(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Symptoms []int `json:"symptoms"`
	}
	if err := app.readJSON(w, r, &input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := app.contextGetUser(r)

	if err := app.Models.Symptoms.SetUserSymptomsBatch(user.ID, input.Symptoms); err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Successfully added User Symptoms"})
}

func (app *Application) DeleteUserSymptoms(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Symptoms []int `json:"symptoms"`
	}
	if err := app.readJSON(w, r, &input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := app.contextGetUser(r)

	if err := app.Models.Symptoms.DeleteUserSymptomsBatch(user.ID, input.Symptoms); err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Deleted Symptoms for User"})
}
