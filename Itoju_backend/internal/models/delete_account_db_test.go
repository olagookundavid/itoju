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

// TestDeleteAccountDB verifies that UserModel.Delete removes the user row and
// that dependent rows (tokens, via ON DELETE CASCADE) are removed too. It also
// asserts that deleting an unknown id returns ErrRecordNotFound. Skipped unless
// ITOJU_TEST_DB is set to a DSN, e.g.:
//
//	ITOJU_TEST_DB='postgres://itoju:itoju@localhost:55432/itoju?sslmode=disable' go test ./internal/models -run TestDeleteAccountDB -v
func TestDeleteAccountDB(t *testing.T) {
	dsn := os.Getenv("ITOJU_TEST_DB")
	if dsn == "" {
		t.Skip("ITOJU_TEST_DB not set; skipping DB-backed delete-account test")
	}
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		t.Fatalf("open db: %v", err)
	}
	defer db.Close()
	if err := db.Ping(); err != nil {
		t.Fatalf("ping db: %v", err)
	}
	goose.SetDialect("postgres")
	goose.SetBaseFS(sqlembed.EmbedMigrations)
	if err := goose.Up(db, "migrations"); err != nil {
		t.Fatalf("migrate: %v", err)
	}

	ctx := context.Background()
	m := NewModels(db)

	// Unique email per run so repeated runs don't collide.
	email := "delete-" + time.Now().Format("150405.000000") + "@example.com"
	user := &User{FirstName: "Del", LastName: "Ete", Dob: time.Now().AddDate(-30, 0, 0), Email: email, Activated: true}
	if err := user.Password.Set("originalpass123"); err != nil {
		t.Fatalf("set pw: %v", err)
	}
	if err := m.Users.Insert(ctx, user); err != nil {
		t.Fatalf("insert user: %v", err)
	}
	// Safety net if an assertion fails before the Delete under test runs.
	t.Cleanup(func() { db.Exec(`DELETE FROM users WHERE email = $1`, email) })

	// Insert a child row in a cascading table (tokens references users ON DELETE
	// CASCADE per migration 002).
	if _, err := m.Tokens.New(ctx, user.ID, 1*time.Hour, ScopeAuthentication); err != nil {
		t.Fatalf("create token: %v", err)
	}
	if n := countTokensForUser(t, db, user.ID); n == 0 {
		t.Fatalf("expected at least one token before delete, got 0")
	}

	// --- Delete: removes the user row ---
	if err := m.Users.Delete(ctx, user.ID); err != nil {
		t.Fatalf("delete user: %v", err)
	}
	var exists bool
	if err := db.QueryRow(`SELECT EXISTS(SELECT 1 FROM users WHERE id = $1)`, user.ID).Scan(&exists); err != nil {
		t.Fatalf("check user exists: %v", err)
	}
	if exists {
		t.Fatalf("user row still present after Delete")
	}
	// --- Cascade: dependent token rows are gone ---
	if n := countTokensForUser(t, db, user.ID); n != 0 {
		t.Fatalf("expected 0 tokens after cascade delete, got %d", n)
	}

	// --- Unknown id returns ErrRecordNotFound ---
	// A well-formed UUID that does not exist (the user we just deleted).
	if err := m.Users.Delete(ctx, user.ID); !errors.Is(err, ErrRecordNotFound) {
		t.Fatalf("delete of nonexistent id should return ErrRecordNotFound, got %v", err)
	}

	t.Logf("account delete + cascade verified for %s", email)
}

func countTokensForUser(t *testing.T, db *sql.DB, userID string) int {
	t.Helper()
	var n int
	if err := db.QueryRow(`SELECT count(*) FROM tokens WHERE user_id = $1`, userID).Scan(&n); err != nil {
		t.Fatalf("count tokens: %v", err)
	}
	return n
}
