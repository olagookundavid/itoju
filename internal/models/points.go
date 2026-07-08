package models

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"
	"time"
)

type UserPointModel struct {
	DB *sql.DB
}

// PointEvent is a single point award, used for batched inserts.
type PointEvent struct {
	UserID string
	Scope  string
	Points int64
}

// InsertPointsBatch writes many point awards in a single transaction: the
// per-user running totals are aggregated and upserted into user_point, and all
// individual events are inserted into user_point_record with one multi-row
// statement. This replaces N separate InsertPoint transactions with one.
func (m UserPointModel) InsertPointsBatch(events []PointEvent) (err error) {
	if len(events) == 0 {
		return nil
	}
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	tx, err := m.DB.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() {
		if p := recover(); p != nil {
			tx.Rollback()
			panic(p)
		} else if err != nil {
			tx.Rollback()
		}
	}()

	// Aggregate points per user (stable order) for the user_point upsert.
	totals := make(map[string]int64)
	order := make([]string, 0, len(events))
	for _, e := range events {
		if _, seen := totals[e.UserID]; !seen {
			order = append(order, e.UserID)
		}
		totals[e.UserID] += e.Points
	}

	const upsert = `
	INSERT INTO user_point (user_id, tot_point) VALUES ($1, $2)
	ON CONFLICT (user_id) DO UPDATE SET
		tot_point = user_point.tot_point + EXCLUDED.tot_point`
	for _, uid := range order {
		if _, err = tx.ExecContext(ctx, upsert, uid, totals[uid]); err != nil {
			return err
		}
	}

	// One multi-row insert for the per-event records.
	var b strings.Builder
	b.WriteString("INSERT INTO user_point_record (user_id, point, scope) VALUES ")
	args := make([]any, 0, len(events)*3)
	for i, e := range events {
		if i > 0 {
			b.WriteString(", ")
		}
		n := i * 3
		fmt.Fprintf(&b, "($%d, $%d, $%d)", n+1, n+2, n+3)
		args = append(args, e.UserID, e.Points, e.Scope)
	}
	if _, err = tx.ExecContext(ctx, b.String(), args...); err != nil {
		return err
	}

	err = tx.Commit()
	return err
}

// GetUserPointsSummary returns the user's running total plus today's and this
// week's points in a single query (replacing the old 2-goroutine fan-out).
func (m UserPointModel) GetUserPointsSummary(ctx context.Context, userID string) (total, today, week int, err error) {
	query := `
	SELECT
		COALESCE((SELECT tot_point FROM user_point WHERE user_id = $1), 0) AS total,
		COALESCE(SUM(point) FILTER (WHERE date_trunc('day', date) = CURRENT_DATE), 0) AS today,
		COALESCE(SUM(point) FILTER (WHERE date_trunc('week', date) = date_trunc('week', CURRENT_DATE)), 0) AS week
	FROM user_point_record
	WHERE user_id = $1`

	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	err = m.DB.QueryRowContext(ctx, query, userID).Scan(&total, &today, &week)
	return total, today, week, err
}

func (m UserPointModel) InsertPoint(userId, scope string, point int64) error {

	tx, err := m.DB.Begin()
	if err != nil {
		return errors.New("couldn't add user point")
	}

	// Ensure to rollback the transaction in case of an error
	defer func() {
		if p := recover(); p != nil {
			tx.Rollback()
			panic(p)
		} else if err != nil {
			tx.Rollback()
		}
	}()
	query := `
	INSERT INTO user_point (user_id, tot_point)
	VALUES ($1, $2)
	ON CONFLICT (user_id)
	DO UPDATE SET
    tot_point = user_point.tot_point + EXCLUDED.tot_point;
`
	userRecordQuery := `
	INSERT INTO user_point_record (user_id, point, scope)
	VALUES ($1, $2, $3);
`

	args := []any{userId, point}
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	_, err = tx.ExecContext(ctx, query, args...)
	if err != nil {
		return err
	}
	args = append(args, scope)
	ctx, cancel = context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	_, err = tx.ExecContext(ctx, userRecordQuery, args...)
	if err != nil {
		return err
	}

	err = tx.Commit()
	if err != nil {
		return errors.New("couldn't add user point")
	}
	return nil
}

func (m UserPointModel) DeletePointRecordMoreThanWeek() error {
	query := `DELETE FROM user_point_record WHERE date < CURRENT_DATE - INTERVAL '7 days'`
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	_, err := m.DB.ExecContext(ctx, query)
	return err
}
