package models

import (
	"context"
	"database/sql"
)

// withTx runs fn inside a database transaction, committing if it returns nil and
// rolling back on any error or panic. It centralises the begin/commit/rollback
// dance so callers express only the work, and multi-statement operations stay
// atomic (all-or-nothing) instead of leaking half-applied state on a mid-way
// failure.
func withTx(ctx context.Context, db *sql.DB, fn func(*sql.Tx) error) error {
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() {
		if p := recover(); p != nil {
			_ = tx.Rollback()
			panic(p)
		}
	}()
	if err := fn(tx); err != nil {
		_ = tx.Rollback()
		return err
	}
	return tx.Commit()
}
