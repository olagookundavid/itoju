package models

import (
	"context"
	"database/sql"
	"os"
	"testing"
	"time"

	_ "github.com/lib/pq"
	sqlembed "github.com/olagookundavid/itoju/internal/sql"
	"github.com/pressly/goose/v3"
)

// TestSoftDeleteDB verifies the B-3 soft-delete invariants against a real
// Postgres (gated on ITOJU_TEST_DB):
//   - a deleted list metric (bowel) disappears from reads but the row survives
//   - a tombstoned one-per-day row (food) no longer blocks re-creating that date
//   - deleting a menstrual cycle tombstones the cycle AND its day rows, and both
//     vanish from reads.
func TestSoftDeleteDB(t *testing.T) {
	dsn := os.Getenv("ITOJU_TEST_DB")
	if dsn == "" {
		t.Skip("ITOJU_TEST_DB not set; skipping DB-backed soft-delete test")
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

	const email = "soft-delete@example.com"
	db.Exec(`DELETE FROM users WHERE email = $1`, email)
	user := &User{FirstName: "Soft", LastName: "Del", Dob: time.Now().AddDate(-30, 0, 0), Email: email, Activated: true}
	if err := user.Password.Set("softpass123"); err != nil {
		t.Fatalf("set pw: %v", err)
	}
	if err := m.Users.Insert(ctx, user); err != nil {
		t.Fatalf("insert user: %v", err)
	}
	t.Cleanup(func() { db.Exec(`DELETE FROM users WHERE email = $1`, email) })

	date := time.Date(2026, 5, 10, 0, 0, 0, 0, time.UTC)

	// --- list metric: soft delete removes it from reads, row survives ---
	if err := m.BowelMetric.InsertBowelMetric(ctx, user.ID, &BowelMetric{Time: "08:00", Type: 3, Pain: 0.2, Date: date, Tags: []string{"a"}}); err != nil {
		t.Fatalf("insert bowel: %v", err)
	}
	rows, err := m.BowelMetric.GetUserBowelMetrics(ctx, user.ID, date)
	if err != nil || len(rows) != 1 {
		t.Fatalf("expected 1 bowel row, got %d (err %v)", len(rows), err)
	}
	if err := m.BowelMetric.DeleteBowelMetric(ctx, rows[0].ID, user.ID); err != nil {
		t.Fatalf("delete bowel: %v", err)
	}
	rows, err = m.BowelMetric.GetUserBowelMetrics(ctx, user.ID, date)
	if err != nil || len(rows) != 0 {
		t.Fatalf("expected 0 bowel rows after soft delete, got %d (err %v)", len(rows), err)
	}
	var live, dead int
	db.QueryRowContext(ctx, `SELECT count(*) FILTER (WHERE deleted_at IS NULL), count(*) FILTER (WHERE deleted_at IS NOT NULL) FROM user_bowel_metric WHERE user_id = $1`, user.ID).Scan(&live, &dead)
	if live != 0 || dead != 1 {
		t.Fatalf("expected 0 live / 1 tombstoned bowel row, got live=%d dead=%d", live, dead)
	}

	// --- one-per-day: tombstone then re-create the same date must succeed ---
	if err := m.FoodMetric.InsertFoodMetric(ctx, &FoodMetric{UserID: user.ID, Date: date, BreakfastMeal: "eggs", BreakfastTags: []string{}, LunchTags: []string{}, DinnerTags: []string{}, SnackTags: []string{}}); err != nil {
		t.Fatalf("insert food: %v", err)
	}
	if _, err := db.ExecContext(ctx, `UPDATE user_food_metric SET deleted_at = now() WHERE user_id = $1 AND date = $2`, user.ID, date); err != nil {
		t.Fatalf("tombstone food: %v", err)
	}
	if err := m.FoodMetric.InsertFoodMetric(ctx, &FoodMetric{UserID: user.ID, Date: date, BreakfastMeal: "toast", BreakfastTags: []string{}, LunchTags: []string{}, DinnerTags: []string{}, SnackTags: []string{}}); err != nil {
		t.Fatalf("re-create food after tombstone should succeed under partial unique: %v", err)
	}
	food, err := m.FoodMetric.GetUserFoodMetric(ctx, user.ID, date)
	if err != nil || food.BreakfastMeal != "toast" {
		t.Fatalf("expected the live re-created food row (toast), got %+v (err %v)", food, err)
	}

	// --- cycle delete tombstones cycle + its day rows ---
	cycleID, err := m.UserPeriod.CreateCycle(ctx, user.ID, time.Date(2026, 6, 1, 0, 0, 0, 0, time.UTC), 28, 5)
	if err != nil {
		t.Fatalf("create cycle: %v", err)
	}
	if err := m.UserPeriod.DeleteMenstrualCycle(ctx, cycleID, user.ID); err != nil {
		t.Fatalf("delete cycle: %v", err)
	}
	var liveCycles, liveDays int
	db.QueryRowContext(ctx, `SELECT count(*) FROM menstrual_cycles WHERE id = $1 AND deleted_at IS NULL`, cycleID).Scan(&liveCycles)
	db.QueryRowContext(ctx, `SELECT count(*) FROM cycles_days WHERE cycle_id = $1 AND deleted_at IS NULL`, cycleID).Scan(&liveDays)
	if liveCycles != 0 || liveDays != 0 {
		t.Fatalf("expected cycle + days tombstoned, got liveCycles=%d liveDays=%d", liveCycles, liveDays)
	}
}
