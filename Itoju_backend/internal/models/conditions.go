package models

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/lib/pq"
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

func (m ConditionsModel) SetUserConditionsBatch(userID string, conditionIDs []int) error {
	if len(conditionIDs) == 0 {
		return nil
	}
	query := `INSERT INTO user_conditions (user_id, conditions_id)
	          SELECT $1, unnest($2::int[])
	          ON CONFLICT DO NOTHING`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if _, err := m.DB.ExecContext(ctx, query, userID, pq.Array(conditionIDs)); err != nil {
		return fmt.Errorf("couldn't add conditions: %w", err)
	}
	return nil
}

func (m ConditionsModel) DeleteUserConditionsBatch(userID string, conditionIDs []int) error {
	if len(conditionIDs) == 0 {
		return nil
	}
	query := `DELETE FROM user_conditions WHERE user_id = $1 AND conditions_id = ANY($2)`
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if _, err := m.DB.ExecContext(ctx, query, userID, pq.Array(conditionIDs)); err != nil {
		return fmt.Errorf("couldn't delete conditions: %w", err)
	}
	return nil
}
