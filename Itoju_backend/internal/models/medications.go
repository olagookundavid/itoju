package models

import (
	"context"
	"database/sql"
	"fmt"
	"time"
)

type MedicationMetric struct {
	ID       string    `json:"id"`
	Time     string    `json:"time"`
	Name     string    `json:"name"`
	Metric   string    `json:"metric"`
	Date     time.Time `json:"date"`
	Dosage   float64   `json:"dosage"`
	Quantity float64   `json:"quantity"`
}

type MedicationMetricModel struct {
	DB *sql.DB
}

func (m MedicationMetricModel) GetUserMedicationMetrics(ctx context.Context, userId string, date time.Time) ([]*MedicationMetric, error) {

	query := `
	SELECT umm.id, umm.time, umm.dosage, umm.quantity, umm.name, umm.date, umm.metric
    FROM user_medication_metric umm
    WHERE umm.user_id = $1 AND umm.date = $2 AND umm.deleted_at IS NULL
	ORDER BY umm.date DESC, umm.id;
    `
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, userId, date)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	medicationMetrics := []*MedicationMetric{}
	for rows.Next() {
		var medicationMetric MedicationMetric
		err := rows.Scan(&medicationMetric.ID, &medicationMetric.Time, &medicationMetric.Dosage, &medicationMetric.Quantity, &medicationMetric.Name, &medicationMetric.Date, &medicationMetric.Metric)
		if err != nil {
			return nil, err
		}

		medicationMetrics = append(medicationMetrics, &medicationMetric)
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return medicationMetrics, nil
}

func (m MedicationMetricModel) InsertMedicationMetric(ctx context.Context, userID string, medicationMetric *MedicationMetric) error {

	query := `
	INSERT INTO user_medication_metric (user_id, time, dosage, quantity, date, name, metric)
	VALUES ($1, $2, $3, $4, $5, $6, $7) `

	args := []any{userID, medicationMetric.Time, medicationMetric.Dosage, medicationMetric.Quantity, medicationMetric.Date, medicationMetric.Name, medicationMetric.Metric}
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	_, err := m.DB.ExecContext(ctx, query, args...)
	if err != nil {
		return err
	}
	return nil
}

// UpdateMedicationMetric partially updates a medication metric in one
// statement, scoped to the owning user; a 0-row update is ErrRecordNotFound.
func (m MedicationMetricModel) UpdateMedicationMetric(ctx context.Context, id string, userID string, timeOfDay, name, metric *string, dosage, quantity *float64) error {
	col, val := MetricIDArg(id)
	query := fmt.Sprintf(`UPDATE user_medication_metric SET
	    time = COALESCE($1, time),
	    dosage = COALESCE($2, dosage),
	    quantity = COALESCE($3, quantity),
	    metric = COALESCE($4, metric),
	    name = COALESCE($5, name)
	    WHERE %s = $6 AND user_id = $7 AND deleted_at IS NULL`, col)

	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	result, err := m.DB.ExecContext(ctx, query, timeOfDay, dosage, quantity, metric, name, val, userID)
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

func (m MedicationMetricModel) DeleteMedicationMetric(ctx context.Context, id string, user_id string) error {
	col, val := MetricIDArg(id)
	query := fmt.Sprintf(` UPDATE user_medication_metric SET deleted_at = now() WHERE %s = $1 AND user_id = $2 AND deleted_at IS NULL `, col)
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
