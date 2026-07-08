package models

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/olagookundavid/itoju/internal/validator"
)

type Menses struct {
	Id         string `json:"-"`
	Period_len int    `json:"period_len"`
	Cycle_len  int    `json:"cycle_len"`
}

type MensesModels struct {
	DB *sql.DB
}

func ValidateMenses(v *validator.Validator, menses *Menses) {
	v.Check(menses.Period_len >= 0, "Period length", "cannot be negative")
	v.Check(menses.Cycle_len >= 0, "Cycle length", "cannot be negative")
}

func (m MensesModels) GetMenses(id string) (*Menses, error) {
	if id == "" {
		return nil, ErrRecordNotFound
	}
	query := `SELECT user_id, period_len, cycle_len FROM menstruation WHERE user_id = $1`

	var menses Menses
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	err := m.DB.QueryRowContext(ctx, query, id).Scan(
		&menses.Id,
		&menses.Period_len,
		&menses.Cycle_len)

	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			return nil, ErrRecordNotFound
		default:
			return nil, err
		}
	}
	return &menses, nil
}

// UpsertMenses creates or partially-updates the user's menstruation settings in
// one atomic statement. Nil fields are left unchanged on update (and default to
// 0 on first insert), so there is no read-then-branch race.
func (m MensesModels) UpsertMenses(ctx context.Context, userID string, periodLen, cycleLen *int) (*Menses, error) {
	query := `INSERT INTO menstruation (user_id, period_len, cycle_len)
	          VALUES ($1, COALESCE($2, 0), COALESCE($3, 0))
	          ON CONFLICT (user_id) DO UPDATE SET
	              period_len = COALESCE($2, menstruation.period_len),
	              cycle_len  = COALESCE($3, menstruation.cycle_len)
	          RETURNING user_id, period_len, cycle_len`

	ctx, cancel := context.WithTimeout(ctx, 3*time.Second)
	defer cancel()
	var menses Menses
	err := m.DB.QueryRowContext(ctx, query, userID, periodLen, cycleLen).Scan(
		&menses.Id, &menses.Period_len, &menses.Cycle_len)
	if err != nil {
		return nil, err
	}
	return &menses, nil
}
