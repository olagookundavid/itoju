package api

import (
	"net/http"
)

func (app *Application) GetConditions(w http.ResponseWriter, r *http.Request) {

	conditions, err := app.Models.Conditions.GetConditions()
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":    "Retrieved All Conditions",
		"conditions": conditions}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) GetUserConditions(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	conditions, err := app.Models.Conditions.GetUserConditions(user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	env := envelope{
		"message":    "Retrieved All Conditions for User",
		"conditions": conditions}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) InsertUserConditions(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Conditions []int `json:"conditions"`
	}
	if err := app.readJSON(w, r, &input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := app.contextGetUser(r)

	if err := app.Models.Conditions.SetUserConditionsBatch(user.ID, input.Conditions); err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Successfully added User Conditions"})
}

func (app *Application) DeleteUserConditions(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Conditions []int `json:"conditions"`
	}
	if err := app.readJSON(w, r, &input); err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := app.contextGetUser(r)

	if err := app.Models.Conditions.DeleteUserConditionsBatch(user.ID, input.Conditions); err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	app.respond(w, r, http.StatusOK, envelope{"message": "Deleted Conditions for User"})
}
