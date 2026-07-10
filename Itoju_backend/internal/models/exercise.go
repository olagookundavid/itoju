package models

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/lib/pq"
)

type ExerciseMetric struct {
	ID        string    `json:"id"`
	UserID    string    `json:"-"`
	Date      time.Time `json:"date"`
	Name      string    `json:"name"`
	Started   string    `json:"start"`
	Ended     string    `json:"ended"`
	Tags      []string  `json:"tags"`
	NoOfTimes int       `json:"no_of_times"`
}

type ExerciseMetricModel struct {
	DB *sql.DB
}

func (m ExerciseMetricModel) InsertExerciseMetric(ctx context.Context, exerciseMetric *ExerciseMetric) error {
	query := `
        INSERT INTO user_exercise_metric (user_id, date, name)
        VALUES ($1, $2, $3)
    `
	args := []any{
		exerciseMetric.UserID,
		exerciseMetric.Date, exerciseMetric.Name}

	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()

	_, err := m.DB.ExecContext(ctx, query, args...)
	if err != nil {
		return err
	}
	return nil
}

func (m ExerciseMetricModel) GetUserExerciseMetric(ctx context.Context, userId string, date time.Time) ([]*ExerciseMetric, error) {
	query := `
    SELECT uem.id, uem.name, uem.started, uem.ended, uem.tags, uem.date, uem.no_of_times
    FROM user_exercise_metric uem
    WHERE uem.user_id = $1 AND uem.date = $2 AND uem.deleted_at IS NULL
	ORDER BY uem.date DESC, uem.id;
    `

	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, userId, date)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	exerciseMetrics := []*ExerciseMetric{}
	for rows.Next() {
		var exerciseMetric ExerciseMetric
		err := rows.Scan(&exerciseMetric.ID, &exerciseMetric.Name, &exerciseMetric.Started, &exerciseMetric.Ended, pq.Array(&exerciseMetric.Tags), &exerciseMetric.Date, &exerciseMetric.NoOfTimes)
		if err != nil {
			return nil, err
		}

		exerciseMetrics = append(exerciseMetrics, &exerciseMetric)
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return exerciseMetrics, nil
}

func (m ExerciseMetricModel) UpdateExerciseMetric(ctx context.Context, exerciseMetric *ExerciseMetric, id string, userID string) error {

	col, val := MetricIDArg(id)
	query := fmt.Sprintf(` UPDATE user_exercise_metric SET started = $1, ended = $2, tags = $3, no_of_times = $4 WHERE %s = $5 AND user_id = $6 AND deleted_at IS NULL; `, col)

	args := []any{&exerciseMetric.Started, &exerciseMetric.Ended, pq.Array(&exerciseMetric.Tags), &exerciseMetric.NoOfTimes, val, userID}
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	result, err := m.DB.ExecContext(ctx, query, args...)
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

func (m ExerciseMetricModel) Get(ctx context.Context, id string, userID string) (*ExerciseMetric, error) {
	col, val := MetricIDArg(id)
	query := fmt.Sprintf(`
    SELECT uem.id, uem.name, uem.started, uem.ended, uem.tags, uem.date, uem.no_of_times
    FROM user_exercise_metric uem
    WHERE uem.%s = $1 AND uem.user_id = $2 AND uem.deleted_at IS NULL
    `, col)

	var exerciseMetric ExerciseMetric
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	err := m.DB.QueryRowContext(ctx, query, val, userID).Scan(&exerciseMetric.ID, &exerciseMetric.Name, &exerciseMetric.Started, &exerciseMetric.Ended, pq.Array(&exerciseMetric.Tags), &exerciseMetric.Date, &exerciseMetric.NoOfTimes)

	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	return &exerciseMetric, nil
}

func (m ExerciseMetricModel) DeleteExerciseMetric(ctx context.Context, id string, user_id string) error {
	col, val := MetricIDArg(id)
	query := fmt.Sprintf(` UPDATE user_exercise_metric SET deleted_at = now() WHERE %s = $1 AND user_id = $2 AND deleted_at IS NULL `, col)
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
