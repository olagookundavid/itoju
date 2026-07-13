package models

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"os"
	"testing"
	"time"

	_ "github.com/lib/pq"
	sqlembed "github.com/olagookundavid/itoju/internal/sql"
	"github.com/pressly/goose/v3"
)

func syncTestDB(t *testing.T) *sql.DB {
	t.Helper()
	dsn := os.Getenv("ITOJU_TEST_DB")
	if dsn == "" {
		t.Skip("ITOJU_TEST_DB not set; skipping DB-backed sync test")
	}
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		t.Fatalf("open db: %v", err)
	}
	goose.SetDialect("postgres")
	goose.SetBaseFS(sqlembed.EmbedMigrations)
	if err := goose.Up(db, "migrations"); err != nil {
		t.Fatalf("migrate: %v", err)
	}
	return db
}

func mkUser(t *testing.T, db *sql.DB, m Models, email string) string {
	t.Helper()
	ctx := context.Background()
	db.Exec(`DELETE FROM users WHERE email = $1`, email)
	u := &User{FirstName: "S", LastName: "Y", Dob: time.Now().AddDate(-25, 0, 0), Email: email, Activated: true}
	if err := u.Password.Set("syncpass123"); err != nil {
		t.Fatalf("pw: %v", err)
	}
	if err := m.Users.Insert(ctx, u); err != nil {
		t.Fatalf("insert user: %v", err)
	}
	t.Cleanup(func() { db.Exec(`DELETE FROM users WHERE email = $1`, email) })
	return u.ID
}

func pushRows(t *testing.T, m Models, userID, table string, rows ...map[string]any) []PushResult {
	t.Helper()
	raws := make([]json.RawMessage, len(rows))
	for i, r := range rows {
		b, _ := json.Marshal(r)
		raws[i] = b
	}
	res, err := m.Sync.Push(context.Background(), userID, table, raws)
	if err != nil {
		t.Fatalf("push %s: %v", table, err)
	}
	return res
}

func TestSyncPushPullDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "sync-a@example.com")
	now := time.Now().UTC()

	bowelID := "0192a000-0000-7000-8000-000000000001"

	// --- new insert applies ---
	res := pushRows(t, m, uid, "user_bowel_metric", map[string]any{
		"id": bowelID, "date": "2026-05-01", "type": 3.0, "pain": 0.4,
		"time": "08:00", "tags": []string{"morning"},
		"updated_at": now.Format(time.RFC3339), "deleted_at": nil,
	})
	if len(res) != 1 || res[0].Status != "applied" {
		t.Fatalf("insert: want applied, got %+v", res)
	}

	// --- re-push identical (same updated_at) is stale (not > existing) ---
	res = pushRows(t, m, uid, "user_bowel_metric", map[string]any{
		"id": bowelID, "date": "2026-05-01", "type": 3.0, "pain": 0.4,
		"time": "08:00", "tags": []string{"morning"},
		"updated_at": now.Format(time.RFC3339), "deleted_at": nil,
	})
	if res[0].Status != "stale" {
		t.Fatalf("re-push: want stale, got %s", res[0].Status)
	}

	// --- newer updated_at applies (LWW) ---
	newer := now.Add(time.Minute)
	res = pushRows(t, m, uid, "user_bowel_metric", map[string]any{
		"id": bowelID, "date": "2026-05-01", "type": 5.0, "pain": 0.9,
		"time": "09:00", "tags": []string{"updated"},
		"updated_at": newer.Format(time.RFC3339), "deleted_at": nil,
	})
	if res[0].Status != "applied" {
		t.Fatalf("newer: want applied, got %s", res[0].Status)
	}

	// --- older updated_at is stale ---
	res = pushRows(t, m, uid, "user_bowel_metric", map[string]any{
		"id": bowelID, "date": "2026-05-01", "type": 1.0, "pain": 0.1,
		"time": "01:00", "tags": []string{"old"},
		"updated_at": now.Add(-time.Hour).Format(time.RFC3339), "deleted_at": nil,
	})
	if res[0].Status != "stale" {
		t.Fatalf("older: want stale, got %s", res[0].Status)
	}

	// --- cross-user id is rejected ---
	uid2 := mkUser(t, db, m, "sync-b@example.com")
	res = pushRows(t, m, uid2, "user_bowel_metric", map[string]any{
		"id": bowelID, "date": "2026-05-01", "type": 2.0, "pain": 0.2,
		"time": "02:00", "tags": []string{"intruder"},
		"updated_at": now.Add(2 * time.Hour).Format(time.RFC3339), "deleted_at": nil,
	})
	if res[0].Status != "rejected" {
		t.Fatalf("cross-user: want rejected, got %s", res[0].Status)
	}

	// --- tombstone push soft-deletes ---
	res = pushRows(t, m, uid, "user_bowel_metric", map[string]any{
		"id": bowelID, "date": "2026-05-01", "type": 5.0, "pain": 0.9,
		"time": "09:00", "tags": []string{"updated"},
		"updated_at": newer.Add(time.Minute).Format(time.RFC3339),
		"deleted_at": newer.Add(time.Minute).Format(time.RFC3339),
	})
	if res[0].Status != "applied" {
		t.Fatalf("tombstone: want applied, got %s", res[0].Status)
	}
	// the row is gone from the normal read path
	live, err := m.BowelMetric.GetUserBowelMetrics(context.Background(), uid, mustDate("2026-05-01"))
	if err != nil || len(live) != 0 {
		t.Fatalf("tombstoned bowel should not read live, got %d (err %v)", len(live), err)
	}

	// --- pull since epoch returns the row incl. the tombstone ---
	// Wait past the pull grace window (server_updated_at was stamped just now).
	time.Sleep(pullGrace + time.Second)
	rows, _, err := m.Sync.Pull(context.Background(), uid, "user_bowel_metric", time.Time{}, "", time.Now(), 500)
	if err != nil {
		t.Fatalf("pull: %v", err)
	}
	if len(rows) != 1 {
		t.Fatalf("pull: want 1 row, got %d", len(rows))
	}
	got := rows[0]
	if got["id"] != bowelID {
		t.Fatalf("pull id mismatch: %v", got["id"])
	}
	if got["deleted_at"] == nil {
		t.Fatalf("pull: expected tombstone deleted_at to be set")
	}
	if fmt.Sprint(got["date"]) != "2026-05-01" {
		t.Fatalf("pull: date want 2026-05-01, got %v", got["date"])
	}
	tags, _ := got["tags"].([]string)
	if len(tags) != 1 || tags[0] != "updated" {
		t.Fatalf("pull: tags want [updated], got %v", got["tags"])
	}
}

// TestSyncDeterministicConvergenceDB proves a server row created via the legacy
// REST path and a client push carrying the SAME deterministic id converge onto
// one physical row instead of duplicating.
func TestSyncDeterministicConvergenceDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "sync-conv@example.com")
	ctx := context.Background()

	// Legacy REST insert — the BEFORE INSERT trigger mints the deterministic id.
	if err := m.FoodMetric.InsertFoodMetric(ctx, &FoodMetric{
		UserID: uid, Date: mustDate("2026-05-02"), BreakfastMeal: "legacy",
		BreakfastTags: []string{}, LunchTags: []string{}, DinnerTags: []string{}, SnackTags: []string{},
	}); err != nil {
		t.Fatalf("legacy insert: %v", err)
	}
	var serverSyncID string
	if err := db.QueryRow(`SELECT id FROM user_food_metric WHERE user_id=$1 AND date=$2`, uid, mustDate("2026-05-02")).Scan(&serverSyncID); err != nil {
		t.Fatalf("read id: %v", err)
	}

	// Client push with the same deterministic id + a newer updated_at → converge.
	res := pushRows(t, m, uid, "user_food_metric", map[string]any{
		"id": serverSyncID, "date": "2026-05-02", "breakfast_meal": "from-device",
		"lunch_meal": "", "dinner_meal": "", "breakfast_extra": "", "lunch_extra": "",
		"dinner_extra": "", "breakfast_fruit": "", "lunch_fruit": "", "dinner_fruit": "",
		"breakfast_tags": []string{}, "lunch_tags": []string{}, "dinner_tags": []string{},
		"snack_name": "", "snack_tags": []string{}, "glass_no": 6.0,
		"updated_at": time.Now().Add(time.Hour).UTC().Format(time.RFC3339), "deleted_at": nil,
	})
	if res[0].Status != "applied" {
		t.Fatalf("converge push: want applied, got %s", res[0].Status)
	}
	var count int
	db.QueryRow(`SELECT count(*) FROM user_food_metric WHERE user_id=$1 AND date=$2`, uid, mustDate("2026-05-02")).Scan(&count)
	if count != 1 {
		t.Fatalf("want 1 converged food row, got %d", count)
	}
	food, _ := m.FoodMetric.GetUserFoodMetric(ctx, uid, mustDate("2026-05-02"))
	if food.BreakfastMeal != "from-device" {
		t.Fatalf("converged row should carry device value, got %q", food.BreakfastMeal)
	}
}

func TestEntitlementWebhookDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "sync-ent@example.com")
	ctx := context.Background()

	// no subscription → not entitled
	ok, err := m.Subscriptions.HasActiveEntitlement(ctx, uid, "sync")
	if err != nil || ok {
		t.Fatalf("fresh user should not be entitled (ok=%v err=%v)", ok, err)
	}

	future := time.Now().Add(30 * 24 * time.Hour)
	if err := m.Subscriptions.UpsertFromWebhook(ctx, Subscription{
		UserID: uid, RCAppUserID: uid, Entitlement: "sync", Status: "active",
		ExpiresAt: &future, LastEventID: "evt-1", LastEventAt: time.Now(),
	}); err != nil {
		t.Fatalf("upsert active: %v", err)
	}
	ok, _ = m.Subscriptions.HasActiveEntitlement(ctx, uid, "sync")
	if !ok {
		t.Fatal("active subscription should be entitled")
	}

	// stale (older) event must not regress the newer active state
	past := time.Now().Add(-time.Hour)
	if err := m.Subscriptions.UpsertFromWebhook(ctx, Subscription{
		UserID: uid, RCAppUserID: uid, Entitlement: "sync", Status: "expired",
		ExpiresAt: &past, LastEventID: "evt-0", LastEventAt: time.Now().Add(-2 * time.Hour),
	}); err != nil {
		t.Fatalf("upsert stale: %v", err)
	}
	ok, _ = m.Subscriptions.HasActiveEntitlement(ctx, uid, "sync")
	if !ok {
		t.Fatal("stale expired event must not revoke a newer active entitlement")
	}

	// a newer EXPIRATION event lapses access
	if err := m.Subscriptions.UpsertFromWebhook(ctx, Subscription{
		UserID: uid, RCAppUserID: uid, Entitlement: "sync", Status: "expired",
		ExpiresAt: &past, LastEventID: "evt-2", LastEventAt: time.Now().Add(time.Hour),
	}); err != nil {
		t.Fatalf("upsert expiration: %v", err)
	}
	ok, _ = m.Subscriptions.HasActiveEntitlement(ctx, uid, "sync")
	if ok {
		t.Fatal("newer expiration should revoke entitlement")
	}
}

func mustDate(s string) time.Time {
	t, _ := time.Parse("2006-01-02", s)
	return t
}
