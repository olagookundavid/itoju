package models

import (
	"context"
	"fmt"
	"strings"
	"testing"
	"time"
)

// TestSyncPullKeysetPaginationDB is the regression for the audit's critical
// finding: a table with more changed rows than one page must be fully pullable
// with no loss and no duplicates — including when many rows share the SAME
// server_updated_at (one bulk backfill/push tx), which a bare timestamp cursor
// would skip past at a page boundary.
func TestSyncPullKeysetPaginationDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "sync-pages@example.com")
	ctx := context.Background()

	// Seed 120 bowel rows in ONE statement so they all share one
	// server_updated_at (mimicking the 032 backfill / a single push tx).
	var sb strings.Builder
	sb.WriteString(`INSERT INTO user_bowel_metric (user_id, date, type, pain, time, tags) VALUES `)
	args := []any{uid}
	for i := 0; i < 120; i++ {
		if i > 0 {
			sb.WriteString(", ")
		}
		day := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC).AddDate(0, 0, i%28)
		sb.WriteString(fmt.Sprintf("($1, '%s', %d, 0.1, '08:00', '{}')", day.Format("2006-01-02"), i%7))
	}
	if _, err := db.ExecContext(ctx, sb.String(), args...); err != nil {
		t.Fatalf("seed: %v", err)
	}

	// Sweep with a page size of 50 → 120 rows must arrive in 3 pages, no
	// loss/dup at the tie boundaries. Use a fixed `until` like the handler does.
	until := time.Now().Add(time.Second) // everything seeded is in the past
	seen := map[string]bool{}
	since, cursorID := time.Time{}, ""
	pages := 0
	for {
		rows, hasMore, err := m.Sync.Pull(ctx, uid, "user_bowel_metric", since, cursorID, until, 50)
		if err != nil {
			t.Fatalf("pull page %d: %v", pages, err)
		}
		pages++
		for _, r := range rows {
			id := r["id"].(string)
			if seen[id] {
				t.Fatalf("duplicate row %s on page %d", id, pages)
			}
			seen[id] = true
		}
		if !hasMore {
			break
		}
		last := rows[len(rows)-1]
		ts, err := time.Parse(time.RFC3339, last["server_updated_at"].(string))
		if err != nil {
			t.Fatalf("cursor ts: %v", err)
		}
		since, cursorID = ts, last["id"].(string)
		if pages > 10 {
			t.Fatal("pagination did not terminate")
		}
	}
	if len(seen) != 120 {
		t.Fatalf("keyset sweep lost rows: want 120, got %d in %d pages", len(seen), pages)
	}
	if pages < 3 {
		t.Fatalf("expected >=3 pages for 120 rows at limit 50, got %d", pages)
	}
}

// TestSyncPushHealDB is the regression for the push-wedge finding: a client
// pushing a NEW deterministic id for a day that already has a live server row
// under a different (legacy) id must converge onto that row — newer client data
// takes it over; older client data adopts only the id — instead of aborting the
// whole batch with a unique violation.
func TestSyncPushHealDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "sync-heal@example.com")
	ctx := context.Background()

	// Legacy server row via REST path (gets its own deterministic id from the
	// trigger — so simulate a PRE-034 legacy id by overriding it to a random v4).
	if err := m.FoodMetric.InsertFoodMetric(ctx, &FoodMetric{
		UserID: uid, Date: mustDate("2026-06-01"), BreakfastMeal: "legacy-eggs",
		BreakfastTags: []string{}, LunchTags: []string{}, DinnerTags: []string{}, SnackTags: []string{},
	}); err != nil {
		t.Fatalf("legacy insert: %v", err)
	}
	if _, err := db.ExecContext(ctx,
		`UPDATE user_food_metric SET id = uuid_generate_v4() WHERE user_id = $1 AND date = '2026-06-01'`, uid); err != nil {
		t.Fatalf("legacy id override: %v", err)
	}
	var legacyUpdated time.Time
	if err := db.QueryRowContext(ctx,
		`SELECT updated_at FROM user_food_metric WHERE user_id = $1 AND date = '2026-06-01'`, uid).Scan(&legacyUpdated); err != nil {
		t.Fatalf("read legacy updated_at: %v", err)
	}

	clientID := "0192b000-0000-7000-8000-00000000aaaa"

	// --- client edit NEWER than the legacy row → heal takes over id AND data ---
	res := pushRows(t, m, uid, "user_food_metric", map[string]any{
		"id": clientID, "date": "2026-06-01",
		"breakfast_meal": "client-toast", "lunch_meal": "", "dinner_meal": "",
		"breakfast_extra": "", "lunch_extra": "", "dinner_extra": "",
		"breakfast_fruit": "", "lunch_fruit": "", "dinner_fruit": "",
		"breakfast_tags": []string{}, "lunch_tags": []string{}, "dinner_tags": []string{},
		"snack_name": "", "snack_tags": []string{}, "glass_no": 2.0,
		"updated_at": legacyUpdated.Add(time.Hour).UTC().Format(time.RFC3339), "deleted_at": nil,
	})
	if res[0].Status != "applied" {
		t.Fatalf("heal take-over: want applied, got %+v", res[0])
	}
	var n int
	db.QueryRowContext(ctx, `SELECT count(*) FROM user_food_metric WHERE user_id = $1 AND date = '2026-06-01'`, uid).Scan(&n)
	if n != 1 {
		t.Fatalf("heal must converge to ONE row, got %d", n)
	}
	var gotID, meal string
	db.QueryRowContext(ctx, `SELECT id, breakfast_meal FROM user_food_metric WHERE user_id = $1 AND date = '2026-06-01'`, uid).Scan(&gotID, &meal)
	if gotID != clientID || meal != "client-toast" {
		t.Fatalf("heal take-over: want (id=%s, meal=client-toast), got (%s, %s)", clientID, gotID, meal)
	}

	// --- second scenario: client edit OLDER than server row → id-only adoption ---
	// Reset to a fresh legacy row with a random id and a FUTURE updated_at.
	if _, err := db.ExecContext(ctx,
		`UPDATE user_food_metric SET id = uuid_generate_v4(), breakfast_meal = 'server-newer', updated_at = now() + interval '1 hour'
		 WHERE user_id = $1 AND date = '2026-06-01'`, uid); err != nil {
		t.Fatalf("reset legacy: %v", err)
	}
	res = pushRows(t, m, uid, "user_food_metric", map[string]any{
		"id": clientID, "date": "2026-06-01",
		"breakfast_meal": "client-older", "lunch_meal": "", "dinner_meal": "",
		"breakfast_extra": "", "lunch_extra": "", "dinner_extra": "",
		"breakfast_fruit": "", "lunch_fruit": "", "dinner_fruit": "",
		"breakfast_tags": []string{}, "lunch_tags": []string{}, "dinner_tags": []string{},
		"snack_name": "", "snack_tags": []string{}, "glass_no": 0.0,
		"updated_at": time.Now().UTC().Format(time.RFC3339), "deleted_at": nil,
	})
	if res[0].Status != "stale" {
		t.Fatalf("heal id-adoption: want stale, got %+v", res[0])
	}
	db.QueryRowContext(ctx, `SELECT id, breakfast_meal FROM user_food_metric WHERE user_id = $1 AND date = '2026-06-01'`, uid).Scan(&gotID, &meal)
	if gotID != clientID || meal != "server-newer" {
		t.Fatalf("heal id-adoption: want (id=%s, meal=server-newer), got (%s, %s)", clientID, gotID, meal)
	}

	// A batch containing the healed row plus a normal row must fully apply
	// (regression for the whole-batch-abort behavior).
	res = pushRows(t, m, uid, "user_bowel_metric", map[string]any{
		"id": "0192b000-0000-7000-8000-00000000bbbb", "date": "2026-06-01", "type": 2.0,
		"pain": 0.2, "time": "10:00", "tags": []string{},
		"updated_at": time.Now().UTC().Format(time.RFC3339), "deleted_at": nil,
	})
	if res[0].Status != "applied" {
		t.Fatalf("post-heal batch health: want applied, got %+v", res[0])
	}
}

// TestCycleDeterministicIDsDB verifies migration 038: REST-created cycles and
// their day rows get deterministic v5 ids matching the client recipe, so
// client-minted ids converge with server rows.
func TestCycleDeterministicIDsDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "sync-cycle-ids@example.com")
	ctx := context.Background()

	start := time.Date(2026, 7, 1, 0, 0, 0, 0, time.UTC)
	cycleID, err := m.UserPeriod.CreateCycle(ctx, uid, start, 28, 5)
	if err != nil {
		t.Fatalf("create cycle: %v", err)
	}

	// The cycle id must equal the deterministic recipe.
	var want string
	if err := db.QueryRowContext(ctx, `SELECT uuid_generate_v5(
		uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app'),
		$1 || ':menstrual_cycles:2026-07-01')`, uid).Scan(&want); err != nil {
		t.Fatalf("compute want: %v", err)
	}
	if cycleID != want {
		t.Fatalf("cycle id: want deterministic %s, got %s", want, cycleID)
	}

	// Every day row must equal its deterministic recipe too.
	var mismatches int
	if err := db.QueryRowContext(ctx, `SELECT count(*) FROM cycles_days d
		WHERE d.cycle_id = $1 AND d.id <> uuid_generate_v5(
			uuid_generate_v5(uuid_ns_dns(), 'sync.itoju.app'),
			d.user_id::text || ':cycles_days:' || d.cycle_id::text || ':' || to_char(d.date, 'YYYY-MM-DD'))`,
		cycleID).Scan(&mismatches); err != nil {
		t.Fatalf("check days: %v", err)
	}
	if mismatches != 0 {
		t.Fatalf("%d cycle days have non-deterministic ids", mismatches)
	}
}
