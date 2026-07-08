package models

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/lib/pq"
)

type UrineMetric struct {
	ID       int       `json:"id"`
	Time     string    `json:"time"`
	Tags     []string  `json:"tags"`
	Date     time.Time `json:"date"`
	Type     float64   `json:"type"`
	Pain     float64   `json:"pain"`
	Quantity float64   `json:"quantity"`
}

type UrineMetricModel struct {
	DB *sql.DB
}

func (m UrineMetricModel) GetUserUrineMetrics(userId string, date time.Time) ([]*UrineMetric, error) {

	query := `
	SELECT uum.id, uum.time, uum.type, uum.pain, uum.tags, uum.date, uum.quantity
    FROM user_urine_metric uum
    WHERE uum.user_id = $1 AND uum.date = $2
	ORDER BY uum.id DESC;
    `
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, userId, date)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	urineMetrics := []*UrineMetric{}
	for rows.Next() {
		var urineMetric UrineMetric
		err := rows.Scan(&urineMetric.ID, &urineMetric.Time, &urineMetric.Type, &urineMetric.Pain, pq.Array(&urineMetric.Tags), &urineMetric.Date, &urineMetric.Quantity)
		if err != nil {
			return nil, err
		}

		urineMetrics = append(urineMetrics, &urineMetric)
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return urineMetrics, nil
}

func (m UrineMetricModel) GetUserUrineMetric(userId string, id int64) (*UrineMetric, error) {
	query := `
    SELECT uum.id, uum.time, uum.type, uum.pain, uum.tags, uum.date, uum.quantity
    FROM user_urine_metric uum
    WHERE uum.user_id = $1 AND uum.id = $2
    `
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	row := m.DB.QueryRowContext(ctx, query, userId, id)

	var urineMetric UrineMetric
	err := row.Scan(&urineMetric.ID, &urineMetric.Time, &urineMetric.Type, &urineMetric.Pain, pq.Array(&urineMetric.Tags), &urineMetric.Date, &urineMetric.Quantity)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrRecordNotFound
		}
		return nil, err
	}
	return &urineMetric, nil
}

func (m UrineMetricModel) InsertUrineMetric(userID string, urineMetric *UrineMetric) error {

	query := `
	INSERT INTO user_urine_metric (user_id, time, pain, type, date, tags, quantity)
	VALUES ($1, $2, $3, $4, $5, $6, $7) `

	args := []any{userID, urineMetric.Time, urineMetric.Pain, urineMetric.Type, urineMetric.Date, pq.Array(urineMetric.Tags), urineMetric.Quantity}
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	_, err := m.DB.ExecContext(ctx, query, args...)
	if err != nil {
		return err
	}
	return nil
}

// UpdateUrineMetric partially updates a urine metric in one statement: nil
// input fields are left unchanged (COALESCE), the row is scoped to the owning
// user, and a 0-row update surfaces as ErrRecordNotFound.
func (m UrineMetricModel) UpdateUrineMetric(ctx context.Context, id int64, userID string, timeOfDay *string, typ, pain, quantity *float64, tags *[]string) error {
	query := `UPDATE user_urine_metric SET
	    time = COALESCE($1, time),
	    pain = COALESCE($2, pain),
	    type = COALESCE($3, type),
	    tags = COALESCE($4, tags),
	    quantity = COALESCE($5, quantity)
	    WHERE id = $6 AND user_id = $7`

	var tagsArg any
	if tags != nil {
		tagsArg = pq.Array(*tags)
	}
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	result, err := m.DB.ExecContext(ctx, query, timeOfDay, pain, typ, tagsArg, quantity, id, userID)
	if err != nil {
		return err
	}
	n, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if n == 0 {
		return ErrRecordNotFound
	}
	return nil
}

func (m UrineMetricModel) DeleteUrineMetric(id int64, user_id string) error {
	if id < 1 {
		return ErrRecordNotFound
	}
	query := ` DELETE FROM user_urine_metric WHERE id = $1 AND user_id = $2 `
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	result, err := m.DB.ExecContext(ctx, query, id, user_id)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return ErrRecordNotFound
	}
	return nil
}
