package models

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"
)

type SymsMetric struct {
	Id                string    `json:"id"`
	SymptomsID        int       `json:"symptoms_id"`
	Name              string    `json:"name"`
	Date              time.Time `json:"date"`
	MorningSeverity   float32   `json:"morning_severity"`
	AfternoonSeverity float32   `json:"afternoon_severity"`
	NightSeverity     float32   `json:"night_severity"`
}
type SymTopN struct {
	Id    int    `json:"id"`
	Count int    `json:"count"`
	Name  string `json:"name"`
}

type SymsMetricModel struct {
	DB *sql.DB
}

func (m SymsMetricModel) CreateSymsMetric(ctx context.Context, userId string, symsMetric SymsMetric) error {
	// id (set by the BEFORE INSERT trigger) is deterministic per
	// (user, symptom, day), so that triple is a single physical row for its whole
	// lifetime. Re-creating a soft-deleted entry therefore revives the tombstone
	// (clears deleted_at) rather than inserting a duplicate; a genuine LIVE
	// duplicate updates no row (the WHERE is false) and surfaces as ErrNoRows,
	// which we map to ErrRecordAlreadyExist to preserve the handler's behaviour.
	query := `
	INSERT INTO user_symptoms_metric (user_id, symptoms_id, date)
	VALUES ($1, $2, $3)
	ON CONFLICT (id) DO UPDATE SET deleted_at = NULL
	WHERE user_symptoms_metric.deleted_at IS NOT NULL
	RETURNING id `

	args := []any{userId, symsMetric.SymptomsID, symsMetric.Date}
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	var id string
	err := m.DB.QueryRowContext(ctx, query, args...).Scan(&id)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return ErrRecordAlreadyExist
		}
		return err
	}
	return nil
}

func (m SymsMetricModel) GetUserSymptomsMetric(ctx context.Context, userId string, date time.Time) ([]*SymsMetric, error) {
	query := `
	SELECT usm.id, s.name, usm.date, usm.morning_severity, usm.afternoon_severity, usm.night_severity
	FROM user_symptoms_metric usm
	JOIN symptoms s ON usm.symptoms_id = s.id
	WHERE usm.user_id = $1 AND usm.date = $2 AND usm.deleted_at IS NULL
    `
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, userId, date)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	symsMetrics := []*SymsMetric{}
	for rows.Next() {
		var symsMetric SymsMetric
		err := rows.Scan(&symsMetric.Id, &symsMetric.Name, &symsMetric.Date, &symsMetric.MorningSeverity, &symsMetric.AfternoonSeverity, &symsMetric.NightSeverity)
		if err != nil {
			return nil, err
		}

		symsMetrics = append(symsMetrics, &symsMetric)
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return symsMetrics, nil
}

func (m SymsMetricModel) GetUserTopNSyms(ctx context.Context, userId string, interval int) ([]*SymTopN, error) {

	query := `
	SELECT s.name, usm.symptoms_id, COUNT(*) AS count
	FROM user_symptoms_metric usm
	JOIN symptoms s ON usm.symptoms_id = s.id
	WHERE usm.user_id = $1
	AND usm.date >= CURRENT_DATE - make_interval(days => $2)
	AND usm.deleted_at IS NULL
	GROUP BY s.name, usm.symptoms_id
	ORDER BY count DESC
	LIMIT 4;
	`

	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, userId, interval)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	outPuts := []*SymTopN{}
	for rows.Next() {
		var outPut SymTopN
		err := rows.Scan(&outPut.Name, &outPut.Id, &outPut.Count)
		if err != nil {
			return nil, err
		}

		outPuts = append(outPuts, &outPut)
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return outPuts, nil
}

func (m SymsMetricModel) Get(ctx context.Context, id string, userID string) (*SymsMetric, error) {
	col, val := MetricIDArg(id)
	query := fmt.Sprintf(` SELECT usm.id, usm.date, usm.morning_severity, usm.afternoon_severity, usm.night_severity
	FROM user_symptoms_metric usm WHERE usm.%s = $1 AND usm.user_id = $2 AND usm.deleted_at IS NULL; `, col)
	var symsMetric SymsMetric
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	err := m.DB.QueryRowContext(ctx, query, val, userID).Scan(&symsMetric.Id, &symsMetric.Date, &symsMetric.MorningSeverity, &symsMetric.AfternoonSeverity, &symsMetric.NightSeverity)

	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	return &symsMetric, nil
}

func (m SymsMetricModel) UpdateSymsMetric(ctx context.Context, symsMetric *SymsMetric, id string, userID string) error {

	col, val := MetricIDArg(id)
	query := fmt.Sprintf(` UPDATE user_symptoms_metric SET morning_severity = $1, afternoon_severity= $2, night_severity = $3 WHERE %s = $4 AND user_id = $5 AND deleted_at IS NULL; `, col)

	args := []any{symsMetric.MorningSeverity, symsMetric.AfternoonSeverity, symsMetric.NightSeverity, val, userID}
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

func (m SymsMetricModel) DeleteSymsMetric(ctx context.Context, id string, user_id string) error {
	col, val := MetricIDArg(id)
	query := fmt.Sprintf(` UPDATE user_symptoms_metric SET deleted_at = now() WHERE %s = $1 AND user_id = $2 AND deleted_at IS NULL `, col)
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

func (m SymsMetricModel) DaysTrackedInARow(ctx context.Context, userID string) (*int, error) {

	query := `
        SELECT MAX(consecutive_days) AS max_consecutive_days
        FROM (
            SELECT COUNT(*) AS consecutive_days
            FROM (
                SELECT date,
                       ROW_NUMBER() OVER (ORDER BY date) - 
                       ROW_NUMBER() OVER (PARTITION BY tracked ORDER BY date) AS grp
                FROM (
                    SELECT date, 
                           CASE WHEN COUNT(user_id) > 0 THEN 1 ELSE 0 END AS tracked
                    FROM user_symptoms_metric
                    WHERE user_id = $1 AND deleted_at IS NULL
                    GROUP BY date
                ) AS t
            ) AS s
            GROUP BY grp
        ) AS max_consecutive_days_query
    `

	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	var maxConsecutiveDays int
	err := m.DB.QueryRowContext(ctx, query, userID).Scan(&maxConsecutiveDays)
	if err != nil {
		return nil, err
	}
	return &maxConsecutiveDays, err
}

func (m SymsMetricModel) DaysTrackedFree(ctx context.Context, userID string) (*int, error) {

	query := `
	SELECT COUNT(*) AS max_consecutive_symptom_free_days
	FROM (
		SELECT date,
			   CASE WHEN LAG(tracked, 1, 0) OVER (ORDER BY date) = 0 THEN 1 ELSE 0 END AS is_consecutive
		FROM (
			SELECT g.date, 
				   CASE WHEN COUNT(usm.user_id) = 0 THEN 1 ELSE 0 END AS tracked
			FROM generate_series(CURRENT_DATE, CURRENT_DATE - INTERVAL '29 days', '-1 day') AS g(date)
			LEFT JOIN user_symptoms_metric AS usm ON g.date = usm.date AND usm.user_id = $1 AND usm.deleted_at IS NULL
			GROUP BY g.date
		) AS t
	) AS s
	WHERE is_consecutive = 1
    `

	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	var maxConsecutiveDays int
	err := m.DB.QueryRowContext(ctx, query, userID).Scan(&maxConsecutiveDays)
	if err != nil {
		return nil, err
	}
	return &maxConsecutiveDays, err
}
