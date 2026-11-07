package models

import (
	"math"
	"testing"
	"time"

	sqlembed "github.com/olagookundavid/itoju/internal/sql"
	"github.com/pressly/goose/v3"
)

func near(a any, want float64) bool {
	f, ok := a.(float64)
	return ok && math.Abs(f-want) < 1e-9
}

// 1.2.1+ syncs `user_medication_metric_v2` (decimal dose / quantity); older
// builds sync `user_medication_metric` (whole numbers). Both hit one table, kept
// coherent by migration 045's trigger.
func TestMedicationDecimalAndLegacyCompatDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "med-dec@example.com")
	t0 := time.Now().UTC()
	rowID := "0192b000-0000-7000-8000-0000000000d1"

	// New build writes decimals; the legacy columns follow, rounded.
	res := pushRows(t, m, uid, "user_medication_metric_v2", map[string]any{
		"id": rowID, "date": "2026-11-06", "name": "Warfarin", "dosage_dec": 2.5,
		"metric": "mg", "quantity_dec": 0.5, "time": "8:00 AM",
		"updated_at": t0.Format(time.RFC3339), "deleted_at": nil})
	if res[0].Status != "applied" {
		t.Fatalf("v2 insert: %+v", res)
	}
	legacy := pullOne(t, m, uid, "user_medication_metric")
	if !near(legacy["dosage"], 3) || !near(legacy["quantity"], 1) {
		t.Fatalf("legacy view = %v, want whole numbers 3 / 1", legacy)
	}

	// An old build re-pushing its rounded, unchanged values (e.g. after renaming
	// the entry) must not clobber the decimals.
	res = pushRows(t, m, uid, "user_medication_metric", map[string]any{
		"id": rowID, "date": "2026-11-06", "name": "Warfarin 2.5", "dosage": 3.0,
		"metric": "mg", "quantity": 1.0, "time": "8:00 AM",
		"updated_at": t0.Add(time.Minute).Format(time.RFC3339), "deleted_at": nil})
	if res[0].Status != "applied" {
		t.Fatalf("legacy re-push: %+v", res)
	}
	row := pullOne(t, m, uid, "user_medication_metric_v2")
	if !near(row["dosage_dec"], 2.5) || !near(row["quantity_dec"], 0.5) || row["name"] != "Warfarin 2.5" {
		t.Fatalf("after legacy re-push v2 = %v, want 2.5 / 0.5 and the new name", row)
	}

	// An old build that really changes the dose: it lands in the decimal column.
	pushRows(t, m, uid, "user_medication_metric", map[string]any{
		"id": rowID, "date": "2026-11-06", "name": "Warfarin", "dosage": 5.0,
		"metric": "mg", "quantity": 1.0, "time": "8:00 AM",
		"updated_at": t0.Add(2 * time.Minute).Format(time.RFC3339), "deleted_at": nil})
	row = pullOne(t, m, uid, "user_medication_metric_v2")
	if !near(row["dosage_dec"], 5) || !near(row["quantity_dec"], 0.5) {
		t.Fatalf("after legacy dose change v2 = %v, want 5 / 0.5", row)
	}
}

// A row written by an old build (sync or legacy REST) is mirrored into the
// decimal columns.
func TestMedicationLegacyInsertMirroredDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "med-legacy@example.com")
	res := pushRows(t, m, uid, "user_medication_metric", map[string]any{
		"id": "0192b000-0000-7000-8000-0000000000d2", "date": "2026-11-06",
		"name": "Iron", "dosage": 65.0, "metric": "mg", "quantity": 2.0, "time": "",
		"updated_at": time.Now().UTC().Format(time.RFC3339), "deleted_at": nil})
	if res[0].Status != "applied" {
		t.Fatalf("legacy insert: %+v", res)
	}
	row := pullOne(t, m, uid, "user_medication_metric_v2")
	if !near(row["dosage_dec"], 65) || !near(row["quantity_dec"], 2) {
		t.Fatalf("legacy insert not mirrored: %v", row)
	}
}

// Reminders: 1.2.0 syncs `user_med_reminder`, 1.2.1+ `user_med_reminder_v2`.
// quantity defaults to 1 there, which the trigger must not mistake for a write.
func TestMedReminderDecimalAndLegacyCompatDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "rem-dec@example.com")
	now := time.Now().UTC().Format(time.RFC3339)

	pushRows(t, m, uid, "user_med_reminder_v2", map[string]any{
		"id": "0192b000-0000-7000-8000-0000000000d3", "name": "Levothyroxine",
		"dosage_dec": 0.125, "unit": "mg", "quantity_dec": 0.5, "days": 127.0,
		"times": []string{"07:00"}, "enabled": true, "updated_at": now, "deleted_at": nil})
	row := pullOne(t, m, uid, "user_med_reminder_v2")
	if !near(row["dosage_dec"], 0.125) || !near(row["quantity_dec"], 0.5) {
		t.Fatalf("v2 reminder = %v, want 0.125 / 0.5", row)
	}
	legacy := pullOne(t, m, uid, "user_med_reminder")
	if !near(legacy["dosage"], 0) || !near(legacy["quantity"], 1) {
		t.Fatalf("legacy reminder = %v, want rounded 0 / 1", legacy)
	}

	uid2 := mkUser(t, db, m, "rem-legacy@example.com")
	pushRows(t, m, uid2, "user_med_reminder", map[string]any{
		"id": "0192b000-0000-7000-8000-0000000000d4", "name": "Metformin",
		"dosage": 500.0, "unit": "mg", "quantity": 2.0, "days": 127.0,
		"times": []string{"08:00"}, "enabled": true, "updated_at": now, "deleted_at": nil})
	row = pullOne(t, m, uid2, "user_med_reminder_v2")
	if !near(row["dosage_dec"], 500) || !near(row["quantity_dec"], 2) {
		t.Fatalf("1.2.0 reminder not mirrored: %v", row)
	}
}

func TestMigration045RoundTripDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	goose.SetDialect("postgres")
	goose.SetBaseFS(sqlembed.EmbedMigrations)
	t.Cleanup(func() { goose.Up(db, "migrations") })
	if err := goose.DownTo(db, "migrations", 44); err != nil {
		t.Fatalf("down: %v", err)
	}
	if err := goose.Up(db, "migrations"); err != nil {
		t.Fatalf("up again: %v", err)
	}
}

// Existing rows get the decimal columns filled, and the backfill does not bump
// updated_at (which would make the server win against an offline edit).
func TestMigration045BackfillKeepsUpdatedAtDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	goose.SetDialect("postgres")
	goose.SetBaseFS(sqlembed.EmbedMigrations)
	t.Cleanup(func() { goose.Up(db, "migrations") })

	uid := mkUser(t, db, m, "mig045-backfill@example.com")
	if err := goose.DownTo(db, "migrations", 44); err != nil {
		t.Fatalf("down: %v", err)
	}
	old := time.Date(2026, 9, 1, 10, 0, 0, 0, time.UTC)
	if _, err := db.Exec(`INSERT INTO user_medication_metric (id, user_id, name, dosage, metric, quantity)
		VALUES ('0192b000-0000-7000-8000-0000000000d5', $1, 'Iron', 65, 'mg', 2)`, uid); err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`UPDATE user_medication_metric SET updated_at = $2 WHERE user_id = $1`, uid, old); err != nil {
		t.Fatal(err)
	}
	if err := goose.Up(db, "migrations"); err != nil {
		t.Fatalf("up: %v", err)
	}
	var d, q float64
	var upd time.Time
	if err := db.QueryRow(`SELECT dosage_dec, quantity_dec, updated_at FROM user_medication_metric WHERE user_id = $1`, uid).
		Scan(&d, &q, &upd); err != nil {
		t.Fatal(err)
	}
	if d != 65 || q != 2 {
		t.Fatalf("backfill = %v / %v, want 65 / 2", d, q)
	}
	if !upd.Equal(old) {
		t.Fatalf("backfill bumped updated_at to %v", upd)
	}
}
