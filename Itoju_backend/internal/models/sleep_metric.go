package models

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/lib/pq"
)

type SleepMetric struct {
	ID         string    `json:"id"`
	IsNight    bool      `json:"is_night"`
	TimeSlept  string    `json:"time_slept"`
	TimeWokeUp string    `json:"time_woke_up"`
	Tags       []string  `json:"tags"`
	Date       time.Time `json:"date"`
	Severity   float64   `json:"severity"`
}

type SleepMetricModel struct {
	DB *sql.DB
}

func (m SleepMetricModel) GetUserSleepMetrics(ctx context.Context, userId string, date time.Time) ([]*SleepMetric, error) {

	query := `
	SELECT usm.id, usm.is_night, usm.time_slept, usm.time_woke_up, usm.tags, usm.date, usm.severity
    FROM user_sleep_metric usm
    WHERE usm.user_id = $1 AND usm.date = $2 AND usm.deleted_at IS NULL
	ORDER BY usm.date DESC, usm.id;
    `
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, userId, date)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	sleepsMetrics := []*SleepMetric{}
	for rows.Next() {
		var sleepMetric SleepMetric
		err := rows.Scan(&sleepMetric.ID, &sleepMetric.IsNight, &sleepMetric.TimeSlept, &sleepMetric.TimeWokeUp, pq.Array(&sleepMetric.Tags), &sleepMetric.Date, &sleepMetric.Severity)
		if err != nil {
			return nil, err
		}

		sleepsMetrics = append(sleepsMetrics, &sleepMetric)
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return sleepsMetrics, nil
}

func (m SleepMetricModel) InsertSleepMetric(ctx context.Context, userID string, sleepMetric *SleepMetric) error {

	query := `
	INSERT INTO user_sleep_metric (user_id, is_night, time_slept, time_woke_up, date, severity, tags)
	VALUES ($1, $2, $3, $4, $5, $6, $7) `

	args := []any{userID, sleepMetric.IsNight, sleepMetric.TimeSlept, sleepMetric.TimeWokeUp, sleepMetric.Date, sleepMetric.Severity, pq.Array(sleepMetric.Tags)}
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	_, err := m.DB.ExecContext(ctx, query, args...)
	if err != nil {
		return err
	}
	return nil
}

// UpdateSleepMetric partially updates a sleep metric in one statement, scoped
// to the owning user; a 0-row update surfaces as ErrRecordNotFound.
func (m SleepMetricModel) UpdateSleepMetric(ctx context.Context, id string, userID string, timeSlept, timeWokeUp *string, severity *float64, tags *[]string) error {
	col, val := MetricIDArg(id)
	query := fmt.Sprintf(`UPDATE user_sleep_metric SET
	    time_slept = COALESCE($1, time_slept),
	    time_woke_up = COALESCE($2, time_woke_up),
	    tags = COALESCE($3, tags),
	    severity = COALESCE($4, severity)
	    WHERE %s = $5 AND user_id = $6 AND deleted_at IS NULL`, col)

	var tagsArg any
	if tags != nil {
		tagsArg = pq.Array(*tags)
	}
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	result, err := m.DB.ExecContext(ctx, query, timeSlept, timeWokeUp, tagsArg, severity, val, userID)
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

func (m SleepMetricModel) DeleteSleepMetric(ctx context.Context, id string, user_id string) error {
	col, val := MetricIDArg(id)
	query := fmt.Sprintf(` UPDATE user_sleep_metric SET deleted_at = now() WHERE %s = $1 AND user_id = $2 AND deleted_at IS NULL `, col)
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
