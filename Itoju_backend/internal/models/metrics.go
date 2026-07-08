package models

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/lib/pq"
)

type Metrics struct {
	Id   int    `json:"id,omitempty"`
	Name string `json:"name,omitempty"`
}

type MetricsModel struct {
	DB *sql.DB
}

// SetUserMetricsBatch inserts all selected tracked metrics for a user in a
// single statement, ignoring any the user already tracks.
func (m MetricsModel) SetUserMetricsBatch(userID string, metricIDs []int) error {
	if len(metricIDs) == 0 {
		return nil
	}
	query := `INSERT INTO user_trackedmetric (user_id, metric_id)
	          SELECT $1, unnest($2::int[])
	          ON CONFLICT DO NOTHING`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if _, err := m.DB.ExecContext(ctx, query, userID, pq.Array(metricIDs)); err != nil {
		return fmt.Errorf("could not add user metrics: %w", err)
	}
	return nil
}

func (m MetricsModel) GetMetrics() ([]*Metrics, error) {
	query := ` SELECT id, name FROM trackedmetrics `

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query)
	if err != nil {
		return []*Metrics{}, err
	}
	defer rows.Close()
	metrics := []*Metrics{}
	for rows.Next() {
		var metric Metrics
		err := rows.Scan(&metric.Id, &metric.Name)
		if err != nil {
			return []*Metrics{}, err
		}

		metrics = append(metrics, &metric)
	}
	if err = rows.Err(); err != nil {
		return []*Metrics{}, err
	}
	return metrics, nil
}

func (m MetricsModel) GetUserMetrics(userID string) ([]*Metrics, error) {

	query := ` SELECT trackedmetrics.id , trackedmetrics.name FROM trackedmetrics
	JOIN user_trackedmetric ON trackedmetrics.id = user_trackedmetric.metric_id
	WHERE user_trackedmetric.user_id = $1; `
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	metrics := []*Metrics{}
	for rows.Next() {
		var metric Metrics
		err := rows.Scan(&metric.Id, &metric.Name)
		if err != nil {
			return nil, err
		}
		metrics = append(metrics, &metric)
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return metrics, nil
}

// DeleteUserMetricsBatch removes all the given tracked metrics for a user in a
// single statement (idempotent — deleting untracked metrics is a no-op).
func (m MetricsModel) DeleteUserMetricsBatch(userID string, metricIDs []int) error {
	if len(metricIDs) == 0 {
		return nil
	}
	query := `DELETE FROM user_trackedmetric WHERE user_id = $1 AND metric_id = ANY($2)`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if _, err := m.DB.ExecContext(ctx, query, userID, pq.Array(metricIDs)); err != nil {
		return fmt.Errorf("could not delete user metrics: %w", err)
	}
	return nil
}

// GetMetricsStatus reports, in a single round-trip, whether the user has any
// entry for the given date in each tracked-metric table. This replaces the old
// 7-goroutine / 7-query fan-out with one query.
func (m MetricsModel) GetMetricsStatus(userID string, date time.Time) (map[string]bool, error) {
	query := `
	SELECT
		EXISTS(SELECT 1 FROM user_symptoms_metric  WHERE user_id = $1 AND date = $2),
		EXISTS(SELECT 1 FROM user_sleep_metric      WHERE user_id = $1 AND date = $2),
		EXISTS(SELECT 1 FROM user_food_metric       WHERE user_id = $1 AND date = $2),
		EXISTS(SELECT 1 FROM user_exercise_metric   WHERE user_id = $1 AND date = $2),
		EXISTS(SELECT 1 FROM user_medication_metric WHERE user_id = $1 AND date = $2),
		EXISTS(SELECT 1 FROM user_bowel_metric      WHERE user_id = $1 AND date = $2),
		EXISTS(SELECT 1 FROM user_urine_metric      WHERE user_id = $1 AND date = $2)`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	var symptoms, sleep, food, exercise, medication, bowel, urine bool
	err := m.DB.QueryRowContext(ctx, query, userID, date).Scan(
		&symptoms, &sleep, &food, &exercise, &medication, &bowel, &urine)
	if err != nil {
		return nil, err
	}
	return map[string]bool{
		"symptoms":   symptoms,
		"sleep":      sleep,
		"food":       food,
		"exercise":   exercise,
		"medication": medication,
		"bowel":      bowel,
		"urine":      urine,
	}, nil
}
