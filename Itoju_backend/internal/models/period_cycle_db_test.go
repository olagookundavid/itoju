package models

import (
	"context"
	"database/sql"
	"errors"
	"os"
	"testing"
	"time"

	_ "github.com/lib/pq"
	sqlembed "github.com/olagookundavid/itoju/internal/sql"
	"github.com/pressly/goose/v3"
)

// TestCreateCycleDB verifies CreateCycle inserts a cycle plus its generated day
// rows atomically, and rejects a duplicate start date without leaving partial
// state. Gated on ITOJU_TEST_DB.
func TestCreateCycleDB(t *testing.T) {
	dsn := os.Getenv("ITOJU_TEST_DB")
	if dsn == "" {
		t.Skip("ITOJU_TEST_DB not set; skipping DB-backed cycle test")
	}
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		t.Fatalf("open db: %v", err)
	}
	defer db.Close()
	goose.SetDialect("postgres")
	goose.SetBaseFS(sqlembed.EmbedMigrations)
	if err := goose.Up(db, "migrations"); err != nil {
		t.Fatalf("migrate: %v", err)
	}

	ctx := context.Background()
	m := NewModels(db)

	const email = "cycle-create@example.com"
	db.Exec(`DELETE FROM users WHERE email = $1`, email)
	user := &User{FirstName: "Cy", LastName: "Cle", Dob: time.Now().AddDate(-30, 0, 0), Email: email, Activated: true}
	if err := user.Password.Set("cyclepass123"); err != nil {
		t.Fatalf("set pw: %v", err)
	}
	if err := m.Users.Insert(ctx, user); err != nil {
		t.Fatalf("insert user: %v", err)
	}
	t.Cleanup(func() { db.Exec(`DELETE FROM users WHERE email = $1`, email) })

	start := time.Date(2026, 3, 1, 0, 0, 0, 0, time.UTC)
	const cycleLen, periodLen = 28, 5

	cycleID, err := m.UserPeriod.CreateCycle(ctx, user.ID, start, cycleLen, periodLen)
	if err != nil {
		t.Fatalf("create cycle: %v", err)
	}
	if cycleID == "" {
		t.Fatal("empty cycle id")
	}

	// One cycle, cycleLen day rows, with the expected period/ovulation split.
	if n := scalarInt(t, db, `SELECT count(*) FROM menstrual_cycles WHERE user_id = $1`, user.ID); n != 1 {
		t.Fatalf("cycles: want 1, got %d", n)
	}
	if n := scalarInt(t, db, `SELECT count(*) FROM cycles_days WHERE cycle_id = $1`, cycleID); n != cycleLen {
		t.Fatalf("day rows: want %d, got %d", cycleLen, n)
	}
	if n := scalarInt(t, db, `SELECT count(*) FROM cycles_days WHERE cycle_id = $1 AND is_period`, cycleID); n != periodLen {
		t.Fatalf("period days: want %d, got %d", periodLen, n)
	}
	wantOvu := cycleLen - periodLen - 9
	if n := scalarInt(t, db, `SELECT count(*) FROM cycles_days WHERE cycle_id = $1 AND is_ovulation`, cycleID); n != wantOvu {
		t.Fatalf("ovulation days: want %d, got %d", wantOvu, n)
	}

	// Duplicate start date is rejected and leaves NO partial second cycle.
	if _, err := m.UserPeriod.CreateCycle(ctx, user.ID, start, cycleLen, periodLen); !errors.Is(err, ErrRecordAlreadyExist) {
		t.Fatalf("duplicate cycle: want ErrRecordAlreadyExist, got %v", err)
	}
	if n := scalarInt(t, db, `SELECT count(*) FROM menstrual_cycles WHERE user_id = $1`, user.ID); n != 1 {
		t.Fatalf("after dup: cycles want 1, got %d", n)
	}
	if n := scalarInt(t, db, `SELECT count(*) FROM cycles_days WHERE user_id = $1`, user.ID); n != cycleLen {
		t.Fatalf("after dup: day rows want %d, got %d", cycleLen, n)
	}
}

func scalarInt(t *testing.T, db *sql.DB, q string, args ...any) int {
	t.Helper()
	var n int
	if err := db.QueryRow(q, args...).Scan(&n); err != nil {
		t.Fatalf("query %q: %v", q, err)
	}
	return n
}
