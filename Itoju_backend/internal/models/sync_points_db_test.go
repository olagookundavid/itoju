package models

import (
	"context"
	"testing"
	"time"
)

// goldenRegisterPoint is v5(NS, "{user}:point_register") for goldenUser. The
// server's registration award and the app's own registration award use this same
// id, so they are ONE row instead of 10 + 10 points. SYNC_ID_SPEC.md + Dart test.
const goldenRegisterPoint = "d03c6ab1-33a6-51fd-9b00-8bc14d721511"

func seedGoldenUser(t *testing.T, email string) {
	t.Helper()
	db := syncTestDB(t)
	defer db.Close()
	db.Exec(`DELETE FROM users WHERE id = $1`, goldenUser)
	if _, err := db.Exec(`INSERT INTO users (id, first_name, last_name, date_of_birth, email, password_hash, activated)
		VALUES ($1,'G','V', now() - interval '30 years', $2, 'x', true)`, goldenUser, email); err != nil {
		t.Fatalf("seed user: %v", err)
	}
	t.Cleanup(func() {
		d := syncTestDB(t)
		defer d.Close()
		d.Exec(`DELETE FROM users WHERE id = $1`, goldenUser)
	})
}

func TestPointRecordsSyncRoundTripDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	ctx := context.Background()
	uid := mkUser(t, db, m, "sync-points@example.com")
	now := time.Now().UTC()
	ts := func(d time.Duration) string { return now.Add(d).Format(time.RFC3339) }

	a := "0192e000-0000-7000-8000-000000000001"
	b := "0192e000-0000-7000-8000-000000000002"
	res := pushRows(t, m, uid, "user_point_record",
		map[string]any{"id": a, "point": 10.0, "scope": "Symptoms", "date": "2026-05-01", "updated_at": ts(0), "deleted_at": nil},
		map[string]any{"id": b, "point": 2.0, "scope": "Bowel", "date": "2026-05-02", "updated_at": ts(0), "deleted_at": nil})
	if len(res) != 2 || res[0].Status != "applied" || res[1].Status != "applied" {
		t.Fatalf("push: %+v", res)
	}

	rows, _, err := m.Sync.Pull(ctx, uid, "user_point_record", time.Time{}, "", time.Now().Add(time.Minute), 100)
	if err != nil || len(rows) != 2 {
		t.Fatalf("pull: %v %v", rows, err)
	}
	total := 0.0
	for _, r := range rows {
		total += r["point"].(float64)
		if r["scope"] == "" || r["date"] == "" {
			t.Fatalf("scope/date missing: %v", r)
		}
	}
	if total != 12 {
		t.Fatalf("pulled points total = %v, want 12", total)
	}

	// a tombstone travels
	res = pushRows(t, m, uid, "user_point_record",
		map[string]any{"id": b, "point": 2.0, "scope": "Bowel", "date": "2026-05-02", "updated_at": ts(time.Minute), "deleted_at": ts(time.Minute)})
	if res[0].Status != "applied" {
		t.Fatalf("tombstone: %+v", res)
	}

	// a legacy row with a NULL scope (pre-migration 026) must not break the pull
	if _, err := db.Exec(`INSERT INTO user_point_record (user_id, point, date) VALUES ($1, 5, '2026-04-01')`, uid); err != nil {
		t.Fatalf("legacy insert: %v", err)
	}
	rows, _, err = m.Sync.Pull(ctx, uid, "user_point_record", time.Time{}, "", time.Now().Add(time.Minute), 100)
	if err != nil {
		t.Fatalf("a NULL-scope legacy row broke the pull: %v", err)
	}
	if len(rows) != 3 {
		t.Fatalf("want 3 rows (2 + legacy), got %d", len(rows))
	}
}

// Server-only Login awards (+5 per login) were never part of what the app shows,
// so they stay out of the sync; per-entry awards from older app builds sync fine.
func TestLoginPointsAreNotSyncedDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "sync-points-login@example.com")

	if err := m.UserPoint.InsertPointsBatch([]PointEvent{
		{UserID: uid, Scope: "Login", Points: 5},
		{UserID: uid, Scope: "Login", Points: 5},
		{UserID: uid, Scope: "Symptoms", Points: 10},
	}); err != nil {
		t.Fatal(err)
	}
	rows, _, err := m.Sync.Pull(context.Background(), uid, "user_point_record", time.Time{}, "", time.Now().Add(time.Minute), 100)
	if err != nil {
		t.Fatal(err)
	}
	if len(rows) != 1 || rows[0]["scope"] != "Symptoms" {
		t.Fatalf("pull should contain only the Symptoms award, got %v", rows)
	}
}

// The server awards 10 on sign-up and the app awards its own 10: same id, ONE row.
func TestRegisterPointIsDeduplicatedDB(t *testing.T) {
	seedGoldenUser(t, "golden-points@example.com")
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	ctx := context.Background()

	if err := m.UserPoint.InsertPointsBatch([]PointEvent{{UserID: goldenUser, Scope: "Register", Points: 10}}); err != nil {
		t.Fatal(err)
	}
	var id string
	if err := db.QueryRow(`SELECT sync_id::text FROM user_point_record WHERE user_id = $1 AND scope = 'Register'`, goldenUser).Scan(&id); err != nil {
		t.Fatal(err)
	}
	if id != goldenRegisterPoint {
		t.Fatalf("server Register award id = %s, want golden %s", id, goldenRegisterPoint)
	}

	// the app now pushes ITS registration award, with the same id
	now := time.Now().UTC().Format(time.RFC3339)
	res := pushRows(t, m, goldenUser, "user_point_record",
		map[string]any{"id": goldenRegisterPoint, "point": 10.0, "scope": "Register", "date": "2026-05-01",
			"updated_at": now, "deleted_at": nil})
	if res[0].Status != "applied" && res[0].Status != "stale" {
		t.Fatalf("client Register push: %+v", res)
	}
	var n int
	db.QueryRow(`SELECT count(*) FROM user_point_record WHERE user_id = $1 AND scope = 'Register'`, goldenUser).Scan(&n)
	if n != 1 {
		t.Fatalf("Register must be one row, got %d (double-counted registration)", n)
	}

	// a second server-side Register award (e.g. a retried batch) doesn't add another
	if err := m.UserPoint.InsertPointsBatch([]PointEvent{{UserID: goldenUser, Scope: "Register", Points: 10}}); err != nil {
		t.Fatal(err)
	}
	db.QueryRow(`SELECT count(*) FROM user_point_record WHERE user_id = $1 AND scope = 'Register'`, goldenUser).Scan(&n)
	if n != 1 {
		t.Fatalf("repeated Register award must stay one row, got %d", n)
	}
	_ = ctx
}
