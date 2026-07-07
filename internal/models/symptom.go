package models

import (
	"context"
	"database/sql"
	"fmt"
	"time"
)

type Symptoms struct {
	Id   int    `json:"id,omitempty"`
	Name string `json:"name,omitempty"`
}

type SymptomsModel struct {
	DB *sql.DB
}

func (m SymptomsModel) GetSymptoms() ([]*Symptoms, error) {
	query := ` SELECT * FROM symptoms `

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
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

func (m SymptomsModel) GetUserSymptoms(userID string) ([]*Symptoms, error) {

	query := ` SELECT symptoms.id , symptoms.name FROM symptoms
	JOIN user_symptoms ON symptoms.id = user_symptoms.symptoms_id
	WHERE user_symptoms.user_id = $1; `
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
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

func (m SymptomsModel) SetUserSymptoms(tx *sql.Tx, symID int, userID string) error {

	query := ` INSERT INTO user_symptoms (user_id, symptoms_id) VALUES ($1, $2)`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	_, err := tx.ExecContext(ctx, query, userID, symID)
	if err != nil {
		return fmt.Errorf("couldn't add new symptoms: %w", err)
	}
	return nil

}

func (m SymptomsModel) DeleteUserSymptoms(tx *sql.Tx, userId string, symptomsID int) error {

	query := ` DELETE FROM user_symptoms
	WHERE user_id = $1
	AND symptoms_id = $2; `

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := tx.ExecContext(ctx, query, userId, symptomsID)
	if err != nil {
		return fmt.Errorf("couldn't delete symptoms: %w", err)
	}

	return nil
}
