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

// Golden vectors — see /SYNC_ID_SPEC.md. These literals are the cross-language
// contract: the mobile client's ids.dart MUST reproduce the same values.
const (
	goldenUserID  = "00000000-0000-0000-0000-000000000001"
	goldenFoodID  = "392ec4ce-09f7-5cb0-848e-921265e26b1f"
	goldenSymsID  = "89ed2f07-25de-5807-ba0e-e1c6ebb998b3"
	goldenSymptom = 1
	goldenDateYMD = "2026-05-10"
)

// TestDeterministicSyncIDDB anchors the server-side deterministic id (the uuid
// PK set by the BEFORE INSERT triggers, carried in the `id` column after the 036
// cutover) to the golden vectors, and verifies the symptoms revive-on-recreate
// behaviour. Gated on ITOJU_TEST_DB.
func TestDeterministicSyncIDDB(t *testing.T) {
	dsn := os.Getenv("ITOJU_TEST_DB")
	if dsn == "" {
		t.Skip("ITOJU_TEST_DB not set; skipping DB-backed deterministic-id test")
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
	date, _ := time.Parse("2006-01-02", goldenDateYMD)

	// Fixed-id user so the deterministic ids equal the published golden literals.
	db.Exec(`DELETE FROM users WHERE id = $1`, goldenUserID)
	_, err = db.ExecContext(ctx,
		`INSERT INTO users (id, first_name, last_name, date_of_birth, email, password_hash, activated)
		 VALUES ($1,'G','V','2000-01-01','golden@example.com','\x00',true)`, goldenUserID)
	if err != nil {
		t.Fatalf("insert fixed user: %v", err)
	}
	t.Cleanup(func() { db.Exec(`DELETE FROM users WHERE id = $1`, goldenUserID) })

	// --- food deterministic id matches the golden vector ---
	if err := m.FoodMetric.InsertFoodMetric(ctx, &FoodMetric{
		UserID: goldenUserID, Date: date, BreakfastMeal: "eggs",
		BreakfastTags: []string{}, LunchTags: []string{}, DinnerTags: []string{}, SnackTags: []string{},
	}); err != nil {
		t.Fatalf("insert food: %v", err)
	}
	var foodID string
	if err := db.QueryRowContext(ctx, `SELECT id FROM user_food_metric WHERE user_id=$1 AND date=$2`, goldenUserID, date).Scan(&foodID); err != nil {
		t.Fatalf("read food id: %v", err)
	}
	if foodID != goldenFoodID {
		t.Fatalf("food id = %s, want golden %s (client recipe drift!)", foodID, goldenFoodID)
	}

	// --- symptom deterministic id matches the golden vector ---
	if err := m.SymsMetric.CreateSymsMetric(ctx, goldenUserID, SymsMetric{SymptomsID: goldenSymptom, Date: date}); err != nil {
		t.Fatalf("create symptom: %v", err)
	}
	var symsID string
	if err := db.QueryRowContext(ctx, `SELECT id FROM user_symptoms_metric WHERE user_id=$1 AND symptoms_id=$2 AND date=$3`, goldenUserID, goldenSymptom, date).Scan(&symsID); err != nil {
		t.Fatalf("read symptom id: %v", err)
	}
	if symsID != goldenSymsID {
		t.Fatalf("symptom id = %s, want golden %s (client recipe drift!)", symsID, goldenSymsID)
	}

	// --- live duplicate → ErrRecordAlreadyExist ---
	err = m.SymsMetric.CreateSymsMetric(ctx, goldenUserID, SymsMetric{SymptomsID: goldenSymptom, Date: date})
	if !errors.Is(err, ErrRecordAlreadyExist) {
		t.Fatalf("live-duplicate create: got %v, want ErrRecordAlreadyExist", err)
	}

	// --- soft delete then re-create revives the SAME physical row (same id) ---
	if err := m.SymsMetric.DeleteSymsMetric(ctx, symsID, goldenUserID); err != nil {
		t.Fatalf("delete symptom: %v", err)
	}
	rows, err := m.SymsMetric.GetUserSymptomsMetric(ctx, goldenUserID, date)
	if err != nil || len(rows) != 0 {
		t.Fatalf("after soft delete expected 0 symptom rows, got %d (err %v)", len(rows), err)
	}
	if err := m.SymsMetric.CreateSymsMetric(ctx, goldenUserID, SymsMetric{SymptomsID: goldenSymptom, Date: date}); err != nil {
		t.Fatalf("re-create symptom (revive) should succeed: %v", err)
	}
	var revivedID string
	if err := db.QueryRowContext(ctx, `SELECT id FROM user_symptoms_metric WHERE user_id=$1 AND symptoms_id=$2 AND date=$3 AND deleted_at IS NULL`, goldenUserID, goldenSymptom, date).Scan(&revivedID); err != nil {
		t.Fatalf("read revived symptom: %v", err)
	}
	if revivedID != symsID {
		t.Fatalf("revive should reuse the same row/id: got id %s, want id %s", revivedID, symsID)
	}
}
