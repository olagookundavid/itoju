package models

import (
	"context"
	"testing"
	"time"

	sqlembed "github.com/olagookundavid/itoju/internal/sql"
	"github.com/pressly/goose/v3"
)

// Golden vectors shared with SYNC_ID_SPEC.md and the Dart ids_test.dart. The
// SQL trigger/backfill, the Go side and the client MUST all produce these.
const (
	goldenUser           = "00000000-0000-0000-0000-000000000001"
	goldenTrackedMetric3 = "00eab78b-ee0b-59d8-9e07-3782c64789fd" // metric 3
	goldenCondition5     = "39678ede-24d4-5239-b247-74dbd24cbc39" // condition 5
	goldenSettings       = "930a21fa-7f84-5cfd-b659-88f739d0a3f9"
)

// Legacy REST inserts (which never supply an id) must get the deterministic id,
// so a server-created row and the client's row for the same selection converge.
func TestSelectionTriggersMintGoldenIDsDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	db.Exec(`DELETE FROM users WHERE id = $1`, goldenUser)
	if _, err := db.Exec(`INSERT INTO users (id, first_name, last_name, date_of_birth, email, password_hash, activated)
		VALUES ($1,'G','V', now() - interval '30 years', 'golden-sel@example.com', 'x', true)`, goldenUser); err != nil {
		t.Fatalf("seed user: %v", err)
	}
	t.Cleanup(func() { db.Exec(`DELETE FROM users WHERE id = $1`, goldenUser) })
	ctx := context.Background()

	if err := m.Metrics.SetUserMetricsBatch(ctx, goldenUser, []int{3}); err != nil {
		t.Fatal(err)
	}
	if err := m.Conditions.SetUserConditionsBatch(ctx, goldenUser, []int{5}); err != nil {
		t.Fatal(err)
	}
	h, w := 170, 60
	p, c := 5, 28
	if _, err := m.Menses.UpsertMenses(ctx, goldenUser, &p, &c); err != nil {
		t.Fatal(err)
	}
	if _, err := m.BodyMeasure.UpsertBodyMeasure(ctx, goldenUser, &h, &w); err != nil {
		t.Fatal(err)
	}

	for _, tc := range []struct{ table, want string }{
		{"user_trackedmetric", goldenTrackedMetric3},
		{"user_conditions", goldenCondition5},
		{"menstruation", goldenSettings},
		{"bodymeasure", goldenSettings},
	} {
		var got string
		if err := db.QueryRow(`SELECT id::text FROM `+tc.table+` WHERE user_id = $1`, goldenUser).Scan(&got); err != nil {
			t.Fatalf("%s: %v", tc.table, err)
		}
		if got != tc.want {
			t.Errorf("%s id = %s, want golden %s", tc.table, got, tc.want)
		}
	}
}

// Existing rows get their deterministic ids when the migration runs on a live DB.
func TestMigration042BackfillsLegacyRowsDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	goose.SetDialect("postgres")
	goose.SetBaseFS(sqlembed.EmbedMigrations)
	t.Cleanup(func() { goose.Up(db, "migrations") }) // always leave the schema current

	if err := goose.DownTo(db, "migrations", 41); err != nil {
		t.Fatalf("down to 41: %v", err)
	}
	db.Exec(`DELETE FROM users WHERE id = $1`, goldenUser)
	if _, err := db.Exec(`INSERT INTO users (id, first_name, last_name, date_of_birth, email, password_hash, activated)
		VALUES ($1,'G','V', now() - interval '30 years', 'golden-mig@example.com', 'x', true)`, goldenUser); err != nil {
		t.Fatalf("seed user: %v", err)
	}
	t.Cleanup(func() { db.Exec(`DELETE FROM users WHERE id = $1`, goldenUser) })
	for _, q := range []string{
		`INSERT INTO user_trackedmetric (user_id, metric_id) VALUES ('` + goldenUser + `', 3)`,
		`INSERT INTO user_conditions (user_id, conditions_id) VALUES ('` + goldenUser + `', 5)`,
		`INSERT INTO menstruation (user_id, period_len, cycle_len) VALUES ('` + goldenUser + `', 5, 28)`,
		`INSERT INTO bodymeasure (user_id, height, weight) VALUES ('` + goldenUser + `', 170, 60)`,
	} {
		if _, err := db.Exec(q); err != nil {
			t.Fatalf("legacy seed %q: %v", q, err)
		}
	}
	if err := goose.UpTo(db, "migrations", 42); err != nil {
		t.Fatalf("up to 42: %v", err)
	}
	for _, tc := range []struct{ table, want string }{
		{"user_trackedmetric", goldenTrackedMetric3},
		{"user_conditions", goldenCondition5},
		{"menstruation", goldenSettings},
		{"bodymeasure", goldenSettings},
	} {
		var got string
		if err := db.QueryRow(`SELECT id::text FROM `+tc.table+` WHERE user_id = $1`, goldenUser).Scan(&got); err != nil {
			t.Fatalf("%s: %v", tc.table, err)
		}
		if got != tc.want {
			t.Errorf("backfilled %s id = %s, want %s", tc.table, got, tc.want)
		}
	}
}

// End to end through the sync protocol: selections and settings round-trip, a
// deselect travels as a tombstone, and legacy REST stays consistent with it.
func TestSelectionsAndSettingsSyncDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	ctx := context.Background()
	uid := mkUser(t, db, m, "sync-sel@example.com")
	now := time.Now().UTC()
	ts := func(d time.Duration) string { return now.Add(d).Format(time.RFC3339) }

	tmID := "0192d000-0000-5000-8000-000000000001"
	cdID := "0192d000-0000-5000-8000-000000000002"
	stID := "0192d000-0000-5000-8000-000000000003"

	res := pushRows(t, m, uid, "user_trackedmetric", map[string]any{
		"id": tmID, "metric_id": 2.0, "granted_at": ts(-time.Hour), "updated_at": ts(0), "deleted_at": nil})
	if res[0].Status != "applied" {
		t.Fatalf("tracked metric: %+v", res)
	}
	res = pushRows(t, m, uid, "user_conditions", map[string]any{
		"id": cdID, "conditions_id": 4.0, "updated_at": ts(0), "deleted_at": nil})
	if res[0].Status != "applied" {
		t.Fatalf("condition: %+v", res)
	}
	// ONE client settings row id is pushed to both server tables.
	res = pushRows(t, m, uid, "menstruation", map[string]any{
		"id": stID, "period_len": 4.0, "cycle_len": 30.0, "updated_at": ts(0), "deleted_at": nil})
	if res[0].Status != "applied" {
		t.Fatalf("menstruation: %+v", res)
	}
	res = pushRows(t, m, uid, "bodymeasure", map[string]any{
		"id": stID, "height": 165.0, "weight": 58.0, "updated_at": ts(0), "deleted_at": nil})
	if res[0].Status != "applied" {
		t.Fatalf("bodymeasure: %+v", res)
	}

	// legacy REST reads see what sync wrote
	mets, _ := m.Metrics.GetUserMetrics(ctx, uid)
	if len(mets) != 1 || mets[0].Id != 2 {
		t.Fatalf("legacy GetUserMetrics after sync push: %+v", mets)
	}
	me, err := m.Menses.GetMenses(ctx, uid)
	if err != nil || me.Period_len != 4 || me.Cycle_len != 30 {
		t.Fatalf("legacy GetMenses: %+v %v", me, err)
	}

	// a deselect arrives as a tombstone: hidden from legacy reads, visible to pull
	res = pushRows(t, m, uid, "user_trackedmetric", map[string]any{
		"id": tmID, "metric_id": 2.0, "granted_at": ts(-time.Hour), "updated_at": ts(time.Minute), "deleted_at": ts(time.Minute)})
	if res[0].Status != "applied" {
		t.Fatalf("tombstone: %+v", res)
	}
	if mets, _ = m.Metrics.GetUserMetrics(ctx, uid); len(mets) != 0 {
		t.Fatalf("deselected metric must disappear from legacy reads: %+v", mets)
	}
	rows, _, err := m.Sync.Pull(ctx, uid, "user_trackedmetric", time.Time{}, "", time.Now().Add(time.Minute), 100)
	if err != nil || len(rows) != 1 || rows[0]["deleted_at"] == nil {
		t.Fatalf("pull must return the tombstone: %v %v", rows, err)
	}
	// legacy re-select revives the SAME row (no duplicate)
	if err := m.Metrics.SetUserMetricsBatch(ctx, uid, []int{2}); err != nil {
		t.Fatal(err)
	}
	if mets, _ = m.Metrics.GetUserMetrics(ctx, uid); len(mets) != 1 {
		t.Fatalf("legacy re-select must revive: %+v", mets)
	}
	var n int
	db.QueryRow(`SELECT count(*) FROM user_trackedmetric WHERE user_id = $1`, uid).Scan(&n)
	if n != 1 {
		t.Fatalf("re-select must not duplicate the row, have %d", n)
	}
	// legacy deselect is a soft delete
	if err := m.Conditions.DeleteUserConditionsBatch(ctx, uid, []int{4}); err != nil {
		t.Fatal(err)
	}
	rows, _, _ = m.Sync.Pull(ctx, uid, "user_conditions", time.Time{}, "", time.Now().Add(time.Minute), 100)
	if len(rows) != 1 || rows[0]["deleted_at"] == nil {
		t.Fatalf("legacy delete must leave a tombstone for sync: %v", rows)
	}

	// settings pulled back from both tables
	for table, key := range map[string]string{"menstruation": "period_len", "bodymeasure": "height"} {
		rows, _, err := m.Sync.Pull(ctx, uid, table, time.Time{}, "", time.Now().Add(time.Minute), 100)
		if err != nil || len(rows) != 1 || rows[0]["id"] != stID || rows[0][key] == nil {
			t.Fatalf("%s pull: %v %v", table, rows, err)
		}
	}

	// A different client id for the same user's settings heals onto the one row
	// instead of failing on UNIQUE(user_id).
	res = pushRows(t, m, uid, "menstruation", map[string]any{
		"id": "0192d000-0000-5000-8000-0000000000aa", "period_len": 6.0, "cycle_len": 31.0,
		"updated_at": ts(2 * time.Minute), "deleted_at": nil})
	if res[0].Status != "applied" {
		t.Fatalf("singleton heal should take over (newer): %+v", res)
	}
	db.QueryRow(`SELECT count(*) FROM menstruation WHERE user_id = $1`, uid).Scan(&n)
	if n != 1 {
		t.Fatalf("still exactly one menstruation row, have %d", n)
	}
}
