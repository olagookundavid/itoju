package models

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/lib/pq"
)

type MenstrualCycle struct {
	ID           string    `json:"id"`
	UserID       string    `json:"user_id"`
	StartDate    time.Time `json:"start_date"`
	CycleLength  int       `json:"cycle_length"`
	PeriodLength int       `json:"period_length"`
}

type CycleDay struct {
	ID          string    `json:"id"`
	CycleID     string    `json:"cycle_id"`
	UserID      string    `json:"-"`
	Date        time.Time `json:"date"`
	IsPeriod    bool      `json:"is_period"`
	IsOvulation bool      `json:"is_ovulation"`
	Flow        float32   `json:"flow"`
	Pain        float32   `json:"pain"`
	Tags        []string  `json:"tags"`
	CMQ         string    `json:"cmq"`
}

type UserPeriodModel struct {
	DB *sql.DB
}

// CreateCycle inserts a menstrual cycle and all of its generated day rows in a
// single transaction, so a partially-created cycle can never be left behind.
// The day layout is derived from the lengths:
//
//	[0, periodLen)              -> period days
//	[periodLen, periodLen+9)    -> regular days
//	[periodLen+9, cycleLen)     -> ovulation days
//
// It returns the new cycle id, or ErrRecordAlreadyExist if a cycle already
// exists for that start date. (Callers are expected to bound the lengths.)
func (m *UserPeriodModel) CreateCycle(ctx context.Context, userID string, startDate time.Time, cycleLen, periodLen int) (string, error) {
	cycle := MenstrualCycle{UserID: userID, StartDate: startDate, CycleLength: cycleLen, PeriodLength: periodLen}
	var cycleID string
	err := withTx(ctx, m.DB, func(tx *sql.Tx) error {
		var err error
		cycleID, err = m.insertMenstrualCycleTx(ctx, tx, &cycle)
		if err != nil {
			return err
		}
		return m.bulkInsertCycleDaysTx(ctx, tx, buildCycleDays(cycleID, userID, startDate, cycleLen, periodLen))
	})
	if err != nil {
		return "", err
	}
	return cycleID, nil
}

// buildCycleDays materialises the per-day rows for a cycle. Each day defaults to
// empty tags and CMQ, matching the previous per-row construction.
func buildCycleDays(cycleID, userID string, startDate time.Time, cycleLen, periodLen int) []CycleDay {
	days := make([]CycleDay, 0, cycleLen)
	add := func(i int, isPeriod, isOvulation bool) {
		days = append(days, CycleDay{
			CycleID: cycleID, UserID: userID, IsPeriod: isPeriod, IsOvulation: isOvulation,
			Date: startDate.AddDate(0, 0, i), CMQ: "", Tags: []string{},
		})
	}
	for i := 0; i < periodLen; i++ {
		add(i, true, false)
	}
	for i := periodLen; i < periodLen+9; i++ {
		add(i, false, false)
	}
	for i := periodLen + 9; i < cycleLen; i++ {
		add(i, false, true)
	}
	return days
}

func (m *UserPeriodModel) GetMenstrualCycles(userID string) ([]MenstrualCycle, error) {
	query := `SELECT id, user_id, start_date, cycle_length, period_length
              FROM menstrual_cycles WHERE user_id = $1 AND deleted_at IS NULL ORDER BY start_date DESC`

	rows, err := m.DB.Query(query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var cycles []MenstrualCycle
	for rows.Next() {
		var cycle MenstrualCycle
		err := rows.Scan(&cycle.ID, &cycle.UserID, &cycle.StartDate, &cycle.CycleLength, &cycle.PeriodLength)
		if err != nil {
			return nil, err
		}
		cycles = append(cycles, cycle)
	}
	return cycles, nil
}

// GetRecentCycleDays returns all cycle days for the user's 3 most recent
// cycles in a single query (replacing the old per-cycle N+1 goroutine fan-out).
func (m *UserPeriodModel) GetRecentCycleDays(ctx context.Context, userID string) ([]CycleDay, error) {
	query := `SELECT id, cycle_id, date, is_period, is_ovulation, flow, pain, tags, cmq
	          FROM cycles_days
	          WHERE user_id = $1
	            AND deleted_at IS NULL
	            AND cycle_id IN (
	                SELECT id FROM menstrual_cycles WHERE user_id = $1 AND deleted_at IS NULL ORDER BY created_at DESC LIMIT 3)
	          ORDER BY cycle_id, date ASC`

	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	rows, err := m.DB.QueryContext(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	days := []CycleDay{}
	for rows.Next() {
		var day CycleDay
		if err := rows.Scan(&day.ID, &day.CycleID, &day.Date, &day.IsPeriod, &day.IsOvulation, &day.Flow, &day.Pain, pq.Array(&day.Tags), &day.CMQ); err != nil {
			return nil, err
		}
		days = append(days, day)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return days, nil
}

func (m *UserPeriodModel) insertMenstrualCycleTx(ctx context.Context, tx *sql.Tx, cycle *MenstrualCycle) (string, error) {
	// The cycle id (set by the BEFORE INSERT trigger from migration 038) is
	// deterministic per (user, start_date), so that pair is a single physical row
	// for its whole lifetime. Re-creating a soft-deleted cycle revives the
	// tombstone with the new lengths; a LIVE duplicate updates no row (the WHERE
	// is false) and surfaces as ErrNoRows → ErrRecordAlreadyExist, preserving the
	// handler's behaviour.
	query := `INSERT INTO menstrual_cycles (user_id, start_date, cycle_length, period_length, created_at)
              VALUES ($1, $2, $3, $4, $5)
              ON CONFLICT (id) DO UPDATE SET
                  deleted_at = NULL,
                  cycle_length = EXCLUDED.cycle_length,
                  period_length = EXCLUDED.period_length
              WHERE menstrual_cycles.deleted_at IS NOT NULL
              RETURNING id`

	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	var id string
	err := tx.QueryRowContext(ctx, query, cycle.UserID, cycle.StartDate, cycle.CycleLength, cycle.PeriodLength, time.Now()).Scan(&id)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return "", ErrRecordAlreadyExist
		case isUniqueViolation(err, "ux_menstrual_cycles_user_start"):
			return "", ErrRecordAlreadyExist
		default:
			return "", err
		}
	}
	return id, nil
}

// BulkInsertCycleDaysTx inserts all cycle days for a cycle in a single
// multi-row statement, instead of one round-trip per day. Day ids are
// deterministic per (user, cycle, date), so re-creating a soft-deleted cycle
// revives its day rows — keeping any previously logged flow/pain/tags — and
// only updates the layout flags for the new lengths.
func (m *UserPeriodModel) bulkInsertCycleDaysTx(ctx context.Context, tx *sql.Tx, days []CycleDay) error {
	if len(days) == 0 {
		return nil
	}
	var b strings.Builder
	b.WriteString(`INSERT INTO cycles_days (cycle_id, user_id, date, is_period, is_ovulation, flow, pain, tags, cmq, created_at) VALUES `)
	args := make([]any, 0, len(days)*9)
	for i, d := range days {
		if i > 0 {
			b.WriteString(", ")
		}
		n := i * 9
		fmt.Fprintf(&b, "($%d,$%d,$%d,$%d,$%d,$%d,$%d,$%d,$%d,now())",
			n+1, n+2, n+3, n+4, n+5, n+6, n+7, n+8, n+9)
		args = append(args, d.CycleID, d.UserID, d.Date, d.IsPeriod, d.IsOvulation, d.Flow, d.Pain, pq.Array(d.Tags), d.CMQ)
	}
	b.WriteString(` ON CONFLICT (id) DO UPDATE SET
		deleted_at = NULL,
		is_period = EXCLUDED.is_period,
		is_ovulation = EXCLUDED.is_ovulation`)
	if _, err := tx.ExecContext(ctx, b.String(), args...); err != nil {
		return err
	}
	return nil
}

func (m *UserPeriodModel) UpdateCycleDay(ctx context.Context, cycleDay *CycleDay) error {

	query := `UPDATE cycles_days SET flow = $1, pain = $2, is_ovulation = $3, is_period = $4, cmq = $5, tags = $6  WHERE id = $7 AND user_id = $8 AND deleted_at IS NULL`

	args := []any{cycleDay.Flow, cycleDay.Pain, cycleDay.IsOvulation, cycleDay.IsPeriod, cycleDay.CMQ, pq.Array(cycleDay.Tags), cycleDay.ID, cycleDay.UserID}
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

func (m *UserPeriodModel) GetCycleDay(ctx context.Context, id, userID string) (*CycleDay, error) {
	if id == "" {
		return nil, ErrRecordNotFound
	}
	query := ` SELECT id, cycle_id, date, is_period, is_ovulation, flow, pain, tags, cmq FROM cycles_days WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL; `
	var cycleDay CycleDay
	cycleDay.UserID = userID
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	err := m.DB.QueryRowContext(ctx, query, id, userID).Scan(
		&cycleDay.ID,
		&cycleDay.CycleID,
		&cycleDay.Date,
		&cycleDay.IsPeriod,
		&cycleDay.IsOvulation,
		&cycleDay.Flow,
		&cycleDay.Pain,
		pq.Array(&cycleDay.Tags),
		&cycleDay.CMQ,
	)

	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	return &cycleDay, nil
}

func (m *UserPeriodModel) DeleteMenstrualCycle(ctx context.Context, id, user_id string) error {
	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()

	return withTx(ctx, m.DB, func(tx *sql.Tx) error {
		// Soft-delete cascades explicitly: a tombstone on the cycle does not
		// fire the ON DELETE CASCADE FK, so its day rows must be tombstoned too.
		if _, err := tx.ExecContext(ctx,
			`UPDATE cycles_days SET deleted_at = now() WHERE cycle_id = $1 AND user_id = $2 AND deleted_at IS NULL`,
			id, user_id); err != nil {
			return err
		}

		result, err := tx.ExecContext(ctx,
			`UPDATE menstrual_cycles SET deleted_at = now() WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL`,
			id, user_id)
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
	})
}
