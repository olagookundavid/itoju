package api

import (
	"fmt"
	"net/http"
	"time"
)

type UserPoint struct {
	ID    int64     `json:"id"`
	Date  time.Time `json:"-"`
	Point int64     `json:"point"`
}

type UserPointReponse struct {
	TotalPoints    int `json:"total_point"`
	TodayPoints    int `json:"today_point"`
	ThisWeekPoints int `json:"week_point"`
}

func (app *Application) GetUserTotalPoints(w http.ResponseWriter, r *http.Request) {
	user := app.contextGetUser(r)

	total, today, week, err := app.Models.UserPoint.GetUserPointsSummary(r.Context(), user.ID)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	userPointResponse := UserPointReponse{
		TotalPoints:    total,
		TodayPoints:    today,
		ThisWeekPoints: week,
	}

	env := envelope{
		"message":    "Retrieved User Total Points",
		"user_point": userPointResponse}

	app.respond(w, r, http.StatusOK, env)
}

func (app *Application) AddUserTotalPoints(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Point int64 `json:"point"`
	}
	err := app.readJSON(w, r, &input)
	if err != nil {
		app.badRequestResponse(w, r, err)
		return
	}
	user := app.contextGetUser(r)
	err = app.Models.UserPoint.InsertPoint(r.Context(), user.ID, "", input.Point)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}

	pointMsg := fmt.Sprintf("Added %d Points to User", input.Point)
	env := envelope{
		"message": pointMsg,
	}

	app.respond(w, r, http.StatusOK, env)
}
