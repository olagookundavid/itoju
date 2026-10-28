package models

import (
	"testing"
	"time"

	sqlembed "github.com/olagookundavid/itoju/internal/sql"
	"github.com/pressly/goose/v3"
)

func TestMigration044RoundTripDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	goose.SetDialect("postgres")
	goose.SetBaseFS(sqlembed.EmbedMigrations)
	t.Cleanup(func() { goose.Up(db, "migrations") })
	if err := goose.DownTo(db, "migrations", 43); err != nil {
		t.Fatalf("down: %v", err)
	}
	if err := goose.Up(db, "migrations"); err != nil {
		t.Fatalf("up again: %v", err)
	}
}

// Existing rows get the new columns filled, and the backfill does not bump
// updated_at (which would make the server "win" against offline 1.1 edits).
func TestMigration044BackfillKeepsUpdatedAtDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	goose.SetDialect("postgres")
	goose.SetBaseFS(sqlembed.EmbedMigrations)
	t.Cleanup(func() { goose.Up(db, "migrations") })

	uid := mkUser(t, db, m, "mig044-backfill@example.com")
	if err := goose.DownTo(db, "migrations", 43); err != nil {
		t.Fatalf("down: %v", err)
	}
	old := time.Date(2026, 9, 1, 10, 0, 0, 0, time.UTC)
	if _, err := db.Exec(`INSERT INTO bodymeasure (user_id, height, weight) VALUES ($1, 70, 150)`, uid); err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(`UPDATE bodymeasure SET updated_at = $2 WHERE user_id = $1`, uid, old); err != nil {
		t.Fatal(err)
	}
	if err := goose.Up(db, "migrations"); err != nil {
		t.Fatalf("up: %v", err)
	}

	var hc, wk float64
	var upd time.Time
	if err := db.QueryRow(`SELECT height_cm, weight_kg, updated_at FROM bodymeasure WHERE user_id = $1`, uid).
		Scan(&hc, &wk, &upd); err != nil {
		t.Fatal(err)
	}
	if hc != 70 || wk != 150 {
		t.Fatalf("backfill = %v/%v, want 70/150", hc, wk)
	}
	if !upd.Equal(old) {
		t.Fatalf("updated_at = %v, want untouched %v", upd, old)
	}
	// The trigger is back on afterwards: a later edit still stamps updated_at.
	if _, err := db.Exec(`UPDATE bodymeasure SET height = 71 WHERE user_id = $1`, uid); err != nil {
		t.Fatal(err)
	}
	if err := db.QueryRow(`SELECT updated_at FROM bodymeasure WHERE user_id = $1`, uid).Scan(&upd); err != nil {
		t.Fatal(err)
	}
	if !upd.After(old) {
		t.Fatalf("sync_touch not re-enabled: updated_at still %v", upd)
	}
}
