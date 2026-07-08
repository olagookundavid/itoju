package models

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/lib/pq"
)

type Symptoms struct {
	Id   int    `json:"id,omitempty"`
	Name string `json:"name,omitempty"`
}

type SymptomsModel struct {
	DB *sql.DB
}

func (m SymptomsModel) GetSymptoms(ctx context.Context) ([]*Symptoms, error) {
	query := ` SELECT id, name FROM symptoms `

	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query)
	if err != nil {
		return []*Symptoms{}, err
	}
	defer rows.Close()
	symptoms := []*Symptoms{}
	for rows.Next() {
		var symptom Symptoms
		err := rows.Scan(&symptom.Id, &symptom.Name)
		if err != nil {
			return []*Symptoms{}, err
		}

		symptoms = append(symptoms, &symptom)
	}
	if err = rows.Err(); err != nil {
		return []*Symptoms{}, err
	}
	return symptoms, nil
}

func (m SymptomsModel) GetUserSymptoms(ctx context.Context, userID string) ([]*Symptoms, error) {

	query := ` SELECT symptoms.id , symptoms.name FROM symptoms
	JOIN user_symptoms ON symptoms.id = user_symptoms.symptoms_id
	WHERE user_symptoms.user_id = $1; `
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	symptoms := []*Symptoms{}
	for rows.Next() {
		var symptom Symptoms
		err := rows.Scan(&symptom.Id, &symptom.Name)
		if err != nil {
			return nil, err
		}
		symptoms = append(symptoms, &symptom)
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return symptoms, nil
}

func (m SymptomsModel) SetUserSymptomsBatch(ctx context.Context, userID string, symptomIDs []int) error {
	if len(symptomIDs) == 0 {
		return nil
	}
	query := `INSERT INTO user_symptoms (user_id, symptoms_id)
	          SELECT $1, unnest($2::int[])
	          ON CONFLICT DO NOTHING`
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	if _, err := m.DB.ExecContext(ctx, query, userID, pq.Array(symptomIDs)); err != nil {
		return fmt.Errorf("couldn't add symptoms: %w", err)
	}
	return nil
}

func (m SymptomsModel) DeleteUserSymptomsBatch(ctx context.Context, userID string, symptomIDs []int) error {
	if len(symptomIDs) == 0 {
		return nil
	}
	query := `DELETE FROM user_symptoms WHERE user_id = $1 AND symptoms_id = ANY($2)`
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	if _, err := m.DB.ExecContext(ctx, query, userID, pq.Array(symptomIDs)); err != nil {
		return fmt.Errorf("couldn't delete symptoms: %w", err)
	}
	return nil
}
