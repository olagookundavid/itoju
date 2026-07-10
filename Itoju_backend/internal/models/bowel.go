package models

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/lib/pq"
)

type BowelMetric struct {
	ID   string    `json:"id"`
	Time string    `json:"time"`
	Tags []string  `json:"tags"`
	Date time.Time `json:"date"`
	Type float64   `json:"type"`
	Pain float64   `json:"pain"`
}

type BowelMetricModel struct {
	DB *sql.DB
}

func (m BowelMetricModel) GetUserBowelMetrics(ctx context.Context, userId string, date time.Time) ([]*BowelMetric, error) {

	query := `
	SELECT ubm.id, ubm.time, ubm.type, ubm.pain, ubm.tags, ubm.date
    FROM user_bowel_metric ubm
    WHERE ubm.user_id = $1 AND ubm.date = $2 AND ubm.deleted_at IS NULL
	ORDER BY ubm.date DESC, ubm.id;
    `
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, userId, date)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	bowelMetrics := []*BowelMetric{}
	for rows.Next() {
		var bowelMetric BowelMetric
		err := rows.Scan(&bowelMetric.ID, &bowelMetric.Time, &bowelMetric.Type, &bowelMetric.Pain, pq.Array(&bowelMetric.Tags), &bowelMetric.Date)
		if err != nil {
			return nil, err
		}

		bowelMetrics = append(bowelMetrics, &bowelMetric)
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return bowelMetrics, nil
}

func (m BowelMetricModel) InsertBowelMetric(ctx context.Context, userID string, bowelMetric *BowelMetric) error {

	query := `
	INSERT INTO user_bowel_metric (user_id, time, pain, type, date, tags)
	VALUES ($1, $2, $3, $4, $5, $6) `

	args := []any{userID, bowelMetric.Time, bowelMetric.Pain, bowelMetric.Type, bowelMetric.Date, pq.Array(bowelMetric.Tags)}
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	_, err := m.DB.ExecContext(ctx, query, args...)
	if err != nil {
		return err
	}
	return nil
}

// UpdateBowelMetric partially updates a bowel metric in one statement, scoped
// to the owning user; a 0-row update surfaces as ErrRecordNotFound.
func (m BowelMetricModel) UpdateBowelMetric(ctx context.Context, id string, userID string, timeOfDay *string, typ, pain *float64, tags *[]string) error {
	col, val := MetricIDArg(id)
	query := fmt.Sprintf(`UPDATE user_bowel_metric SET
	    time = COALESCE($1, time),
	    pain = COALESCE($2, pain),
	    type = COALESCE($3, type),
	    tags = COALESCE($4, tags)
	    WHERE %s = $5 AND user_id = $6 AND deleted_at IS NULL`, col)

	var tagsArg any
	if tags != nil {
		tagsArg = pq.Array(*tags)
	}
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	result, err := m.DB.ExecContext(ctx, query, timeOfDay, pain, typ, tagsArg, val, userID)
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

func (m BowelMetricModel) DeleteBowelMetric(ctx context.Context, id string, user_id string) error {
	col, val := MetricIDArg(id)
	query := fmt.Sprintf(` UPDATE user_bowel_metric SET deleted_at = now() WHERE %s = $1 AND user_id = $2 AND deleted_at IS NULL `, col)
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	result, err := m.DB.ExecContext(ctx, query, val, user_id)
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
