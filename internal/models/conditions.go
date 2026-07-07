package models

import (
	"context"
	"database/sql"
	"fmt"
	"time"
)

type Conditions struct {
	Id   int    `json:"id,omitempty"`
	Name string `json:"name,omitempty"`
}

type ConditionsModel struct {
	DB *sql.DB
}

func (m ConditionsModel) GetConditions() ([]*Conditions, error) {
	query := ` SELECT * FROM conditions `

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query)
	if err != nil {
		return []*Conditions{}, err
	}
	defer rows.Close()
	conditions := []*Conditions{}
	for rows.Next() {
		var condition Conditions
		err := rows.Scan(&condition.Id, &condition.Name)
		if err != nil {
			return []*Conditions{}, err
		}

		conditions = append(conditions, &condition)
	}
	if err = rows.Err(); err != nil {
		return []*Conditions{}, err
	}
	return conditions, nil
}

func (m ConditionsModel) GetUserConditions(userID string) ([]*Conditions, error) {

	query := ` SELECT conditions.id , conditions.name FROM Conditions
	JOIN user_conditions ON conditions.id = user_conditions.conditions_id
	WHERE user_conditions.user_id = $1; `
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	conditions := []*Conditions{}
	for rows.Next() {
		var condition Conditions
		err := rows.Scan(&condition.Id, &condition.Name)
		if err != nil {
			return nil, err
		}
		conditions = append(conditions, &condition)
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return conditions, nil
}

func (m ConditionsModel) SetUserConditions(tx *sql.Tx, conditionID int, userID string) error {

	query := ` INSERT INTO user_conditions (user_id, conditions_id) VALUES ($1, $2)`

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := tx.ExecContext(ctx, query, userID, conditionID)

	if err != nil {

		return fmt.Errorf("could add user condition: %w", err)
	}
	return nil

}

func (m ConditionsModel) DeleteUserConditions(tx *sql.Tx, userId string, conditionID int) error {

	query := ` DELETE FROM user_conditions
	WHERE user_id = $1
	AND conditions_id = $2; `

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	_, err := tx.ExecContext(ctx, query, userId, conditionID)
	if err != nil {
		return fmt.Errorf("could delete user condition: %w", err)
	}

	return nil
}
