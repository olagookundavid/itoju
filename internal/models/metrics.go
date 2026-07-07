package models

import (
	"context"
	"database/sql"
	"fmt"
	"time"
)

type Metrics struct {
	Id   int    `json:"id,omitempty"`
	Name string `json:"name,omitempty"`
}

type MetricsModel struct {
	DB *sql.DB
}

// unique issue on user_metrics table, also how to do this well

func (m MetricsModel) SetUserMetrics(tx *sql.Tx, metricID int, userID string) error {

	query := ` INSERT INTO user_trackedmetric (user_id, metric_id) VALUES ($1, $2)`
	//TODO: change to TX

	// for _, metricID := range selectedMetrics {
	// 	wg.Add(1)
	// 	go func(metricID int) {
	// 		ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	// 		defer cancel()
	// 		defer wg.Done()
	// 		defer func() {
	// 			if err := recover(); err != nil {
	// 				logger.PrintError(fmt.Errorf("%s", err), nil)
	// 			}
	// 		}()
	// 		_, err := m.DB.ExecContext(ctx, query, userID, metricID)
	// 		if err != nil {
	// 			logger.PrintError(fmt.Errorf("metric error  %s", err), nil)
	// 			return
	// 		}
	// 	}(metricID)
	// }
	// wg.Wait()

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	_, err := tx.ExecContext(ctx, query, userID, metricID)
	if err != nil {
		return fmt.Errorf("could add user metric: %w", err)
	}
	return nil

}

func (m MetricsModel) GetMetrics() ([]*Metrics, error) {
	query := ` SELECT * FROM trackedmetrics `

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

func (m MetricsModel) DeleteUserMetrics(tx *sql.Tx, userId string, metricID int) error {

	query := ` DELETE FROM user_trackedmetric
	WHERE user_id = $1
	AND metric_id = $2; `

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := tx.ExecContext(ctx, query, userId, metricID)
	if err != nil {

		return fmt.Errorf("could delete user metric: %w", err)
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
