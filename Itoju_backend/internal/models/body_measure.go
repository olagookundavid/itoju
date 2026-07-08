package models

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/olagookundavid/itoju/internal/validator"
)

type BodyMeasure struct {
	Id     string `json:"-"`
	Height int    `json:"height"`
	Weight int    `json:"weight"`
}

type BodyMeasureModel struct {
	DB *sql.DB
}

func ValidateBodyMeasure(v *validator.Validator, bodyMeasure *BodyMeasure) {
	v.Check(bodyMeasure.Height >= 0, "Height", "cannot be negative")
	v.Check(bodyMeasure.Weight >= 0, "Weight", "cannot be negative")
}

func (m BodyMeasureModel) GetBodyMeasure(ctx context.Context, id string) (*BodyMeasure, error) {
	if id == "" {
		return nil, ErrRecordNotFound
	}
	query := `SELECT user_id, height, weight FROM bodymeasure WHERE user_id = $1`

	var bodyMeasure BodyMeasure
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&bodyMeasure.Id,
		&bodyMeasure.Height,
		&bodyMeasure.Weight)

	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	return &bodyMeasure, nil
}

// UpsertBodyMeasure creates or partially-updates the user's body measurements in
// one atomic statement (nil fields unchanged on update, default 0 on insert).
func (m BodyMeasureModel) UpsertBodyMeasure(ctx context.Context, userID string, height, weight *int) (*BodyMeasure, error) {
	query := `INSERT INTO bodymeasure (user_id, height, weight)
	          VALUES ($1, COALESCE($2, 0), COALESCE($3, 0))
	          ON CONFLICT (user_id) DO UPDATE SET
	              height = COALESCE($2, bodymeasure.height),
	              weight = COALESCE($3, bodymeasure.weight)
	          RETURNING user_id, height, weight`

	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	var bodyMeasure BodyMeasure
	err := m.DB.QueryRowContext(ctx, query, userID, height, weight).Scan(
		&bodyMeasure.Id, &bodyMeasure.Height, &bodyMeasure.Weight)
	if err != nil {
		return nil, err
	}
	return &bodyMeasure, nil
}
