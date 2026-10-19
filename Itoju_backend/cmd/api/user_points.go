package api

import (
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
