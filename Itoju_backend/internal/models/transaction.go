package models

import (
	"context"
	"database/sql"
)

type TransactionModel struct {
	DB *sql.DB
}

func (m *TransactionModel) BeginTx(ctx context.Context) (*sql.Tx, error) {
	return m.DB.BeginTx(ctx, nil)
}
