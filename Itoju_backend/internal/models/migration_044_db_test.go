package models

import (
	"testing"

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
