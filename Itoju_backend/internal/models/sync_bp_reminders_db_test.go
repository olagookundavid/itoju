package models

import (
	"context"
	"math"
	"testing"
	"time"
)

func pullOne(t *testing.T, m Models, uid, table string) map[string]any {
	t.Helper()
	rows, _, err := m.Sync.Pull(context.Background(), uid, table, time.Time{}, "", time.Now().Add(time.Minute), 100)
	if err != nil {
		t.Fatalf("pull %s: %v", table, err)
	}
	if len(rows) != 1 {
		t.Fatalf("pull %s: want 1 row, got %d (%v)", table, len(rows), rows)
	}
	return rows[0]
}

// The Blood Pressure metric must be catalog id 9: the app seeds its catalog by
// position, so a different id would make every user's selection point at the
// wrong metric.
func TestBloodPressureCatalogIDDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	var name string
	if err := db.QueryRow(`SELECT name FROM trackedmetrics WHERE id = 9`).Scan(&name); err != nil {
		t.Fatal(err)
	}
	if name != "Blood Pressure" {
		t.Fatalf("trackedmetrics id 9 = %q, want Blood Pressure", name)
	}
}

func TestBloodPressureSyncDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "sync-bp@example.com")
	now := time.Now().UTC().Format(time.RFC3339)

	good := "0192b000-0000-7000-8000-000000000001"
	bad := "0192b000-0000-7000-8000-000000000002"
	res := pushRows(t, m, uid, "user_bp_metric",
		map[string]any{"id": good, "date": "2026-10-01", "time": "08:15", "systolic": 122.0,
			"diastolic": 81.0, "pulse": 68.0, "updated_at": now, "deleted_at": nil},
		// systolic 500 violates the CHECK: this one row is quarantined, the batch survives.
		map[string]any{"id": bad, "date": "2026-10-01", "time": "09:00", "systolic": 500.0,
			"diastolic": 81.0, "pulse": 68.0, "updated_at": now, "deleted_at": nil},
	)
	if res[0].Status != "applied" || res[1].Status != "rejected" {
		t.Fatalf("want [applied rejected], got %+v", res)
	}

	row := pullOne(t, m, uid, "user_bp_metric")
	if row["id"] != good || row["systolic"] != 122.0 || row["diastolic"] != 81.0 ||
		row["pulse"] != 68.0 || row["time"] != "08:15" || row["date"] != "2026-10-01" {
		t.Fatalf("bp round trip mismatch: %v", row)
	}

	// Soft delete syncs as a tombstone.
	later := time.Now().UTC().Add(time.Minute).Format(time.RFC3339)
	pushRows(t, m, uid, "user_bp_metric",
		map[string]any{"id": good, "date": "2026-10-01", "time": "08:15", "systolic": 122.0,
			"diastolic": 81.0, "pulse": 68.0, "updated_at": later, "deleted_at": later})
	if row := pullOne(t, m, uid, "user_bp_metric"); row["deleted_at"] == nil {
		t.Fatalf("expected tombstone, got %v", row)
	}
}

func TestMedReminderSyncDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "sync-rem@example.com")
	now := time.Now().UTC().Format(time.RFC3339)

	id := "0192b000-0000-7000-8000-0000000000a1"
	res := pushRows(t, m, uid, "user_med_reminder", map[string]any{
		"id": id, "name": "Metformin", "dosage": 500.0, "unit": "mg", "quantity": 1.0,
		"days": 31.0, "times": []string{"08:00", "20:00"}, "enabled": true,
		"updated_at": now, "deleted_at": nil})
	if res[0].Status != "applied" {
		t.Fatalf("want applied, got %+v", res)
	}

	row := pullOne(t, m, uid, "user_med_reminder")
	times, _ := row["times"].([]string)
	if row["name"] != "Metformin" || row["days"] != 31.0 || row["enabled"] != true ||
		len(times) != 2 || times[0] != "08:00" || times[1] != "20:00" {
		t.Fatalf("reminder round trip mismatch: %v", row)
	}

	// days outside the 7-bit mask is refused per row, not per batch.
	res = pushRows(t, m, uid, "user_med_reminder", map[string]any{
		"id": "0192b000-0000-7000-8000-0000000000a2", "name": "X", "dosage": 1.0, "unit": "mg",
		"quantity": 1.0, "days": 200.0, "times": []string{}, "enabled": true,
		"updated_at": now, "deleted_at": nil})
	if res[0].Status != "rejected" {
		t.Fatalf("days=200: want rejected, got %+v", res)
	}
}

// 1.1.x builds sync `bodymeasure` (whole numbers); 1.2 syncs `bodymeasure_v2`
// (decimal cm/kg). Both hit one table, kept coherent by a trigger.
func TestBodyMeasureDecimalAndLegacyCompatDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "sync-body@example.com")
	t0 := time.Now().UTC()
	rowID := "0192b000-0000-7000-8000-0000000000b1"

	// New build writes decimals; the legacy columns follow, rounded.
	res := pushRows(t, m, uid, "bodymeasure_v2", map[string]any{
		"id": rowID, "height_cm": 175.5, "weight_kg": 70.3,
		"updated_at": t0.Format(time.RFC3339), "deleted_at": nil})
	if res[0].Status != "applied" {
		t.Fatalf("v2 insert: %+v", res)
	}
	var h, w int
	if err := db.QueryRow(`SELECT height, weight FROM bodymeasure WHERE user_id = $1`, uid).Scan(&h, &w); err != nil {
		t.Fatal(err)
	}
	if h != 176 || w != 70 {
		t.Fatalf("legacy columns = %d/%d, want 176/70", h, w)
	}

	// A 1.1.x build then pushes only a new height: it lands in height_cm and the
	// decimal weight is untouched.
	res = pushRows(t, m, uid, "bodymeasure", map[string]any{
		"id": rowID, "height": 180.0, "weight": 70.0,
		"updated_at": t0.Add(time.Minute).Format(time.RFC3339), "deleted_at": nil})
	if res[0].Status != "applied" {
		t.Fatalf("legacy update: %+v", res)
	}
	row := pullOne(t, m, uid, "bodymeasure_v2")
	if row["height_cm"] != 180.0 || math.Abs(row["weight_kg"].(float64)-70.3) > 1e-9 {
		t.Fatalf("after legacy write v2 = %v, want 180 / 70.3", row)
	}

	// The legacy view stays whole numbers, so an old build can always parse it.
	legacy := pullOne(t, m, uid, "bodymeasure")
	if legacy["height"] != 180.0 || legacy["weight"] != 70.0 {
		t.Fatalf("legacy pull = %v, want 180 / 70", legacy)
	}

	// A legacy build re-pushing its (rounded) unchanged values must not clobber decimals.
	pushRows(t, m, uid, "bodymeasure", map[string]any{
		"id": rowID, "height": 180.0, "weight": 70.0,
		"updated_at": t0.Add(2 * time.Minute).Format(time.RFC3339), "deleted_at": nil})
	if row := pullOne(t, m, uid, "bodymeasure_v2"); math.Abs(row["weight_kg"].(float64)-70.3) > 1e-9 {
		t.Fatalf("legacy re-push clobbered decimal weight: %v", row)
	}
}

// A legacy REST-style insert (which only knows the old columns) is mirrored into
// the new ones by the trigger.
func TestBodyMeasureLegacyInsertMirroredDB(t *testing.T) {
	db := syncTestDB(t)
	defer db.Close()
	m := NewModels(db)
	uid := mkUser(t, db, m, "mig-body@example.com")
	if _, err := db.Exec(`INSERT INTO bodymeasure (user_id, height, weight) VALUES ($1, 168, 59)`, uid); err != nil {
		t.Fatal(err)
	}
	var hc, wk float64
	if err := db.QueryRow(`SELECT height_cm, weight_kg FROM bodymeasure WHERE user_id = $1`, uid).Scan(&hc, &wk); err != nil {
		t.Fatal(err)
	}
	if hc != 168 || wk != 59 {
		t.Fatalf("legacy insert not mirrored: %v/%v", hc, wk)
	}
}
