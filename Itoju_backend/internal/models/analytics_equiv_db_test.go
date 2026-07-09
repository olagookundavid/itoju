package models

import (
	"context"
	"database/sql"
	"encoding/json"
	"os"
	"testing"
	"time"

	_ "github.com/lib/pq"
	sqlembed "github.com/olagookundavid/itoju/internal/sql"
	"github.com/pressly/goose/v3"
)

// TestAnalyticsSnapshotDB seeds deterministic metric data and prints a canonical
// JSON snapshot of every analytics method's output between BEGIN/END markers.
// Run it against the CURRENT code, save the snapshot, refactor, run it again,
// and diff — the two must be byte-identical. Gated on ITOJU_TEST_DB.
func TestAnalyticsSnapshotDB(t *testing.T) {
	dsn := os.Getenv("ITOJU_TEST_DB")
	if dsn == "" {
		t.Skip("ITOJU_TEST_DB not set; skipping analytics snapshot test")
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

	// Fixed user so the seed is idempotent across runs on the same day.
	const email = "analytics-equiv@example.com"
	db.Exec(`DELETE FROM users WHERE email = $1`, email)
	user := &User{FirstName: "An", LastName: "Ly", Dob: time.Now().AddDate(-30, 0, 0), Email: email, Activated: true}
	if err := user.Password.Set("analyticspass123"); err != nil {
		t.Fatalf("set pw: %v", err)
	}
	if err := m.Users.Insert(ctx, user); err != nil {
		t.Fatalf("insert user: %v", err)
	}
	uid := user.ID

	// A symptom to reference. Idempotent so leftover rows from an interrupted run
	// don't collide on the unique name. (The id is never part of the output.)
	var symID int
	db.Exec(`DELETE FROM symptoms WHERE name = 'equiv-sym'`)
	if err := db.QueryRow(`INSERT INTO symptoms (name) VALUES ('equiv-sym') RETURNING id`).Scan(&symID); err != nil {
		t.Fatalf("insert symptom: %v", err)
	}
	t.Cleanup(func() {
		db.Exec(`DELETE FROM users WHERE email = $1`, email)
		db.Exec(`DELETE FROM symptoms WHERE id = $1`, symID)
	})

	// Seed rows across a spread of dates: within last 7 days, earlier this month,
	// and earlier this year (different month), so day/month/year windows all hit.
	// Offsets are days back from CURRENT_DATE, evaluated in SQL for determinism.
	offsets := []int{0, 1, 3, 6, 12, 40, 100}
	for i, off := range offsets {
		d := "CURRENT_DATE - " + itoa(off)
		// symptoms metric (severities vary)
		sev := 0.2 + float64(i%4)*0.2
		mustExec(t, db, `INSERT INTO user_symptoms_metric (user_id, symptoms_id, date, morning_severity, afternoon_severity, night_severity)
			VALUES ($1,$2,`+d+`,$3,$3,$3) ON CONFLICT DO NOTHING`, uid, symID, sev)
		// bowel metric (type cycles 1..3)
		mustExec(t, db, `INSERT INTO user_bowel_metric (user_id, date, type, tags) VALUES ($1,`+d+`,$2,$3)`,
			uid, (i%3)+1, pqStrs("fiber"))
		// exercise metric (no_of_times varies)
		mustExec(t, db, `INSERT INTO user_exercise_metric (user_id, date, name, no_of_times) VALUES ($1,`+d+`,$2,$3)`,
			uid, "run", (i%2)+1)
		// food metric with meal tags (breakfast/lunch/dinner/snack)
		mustExec(t, db, `INSERT INTO user_food_metric (user_id, date, breakfast_tags, lunch_tags, dinner_tags, snack_tags)
			VALUES ($1,`+d+`,$2,$3,$4,$5)`,
			uid, pqStrs("apple", "egg"), pqStrs("rice"), pqStrs("apple"), pqStrs("nuts"))
	}

	year := time.Now().Year()
	month := int(time.Now().Month())
	const days = 120 // wide enough to include all seeded rows for the 7-day-style methods

	out := map[string]any{}
	var e error
	grab := func(name string, v any, err error) {
		if err != nil {
			e = err
			t.Errorf("%s: %v", name, err)
			return
		}
		out[name] = v
	}

	daySym, err := m.AnalyticsMetric.GetSymptom7DaysOccurrences(ctx, uid, symID, days)
	grab("day_symptom", daySym, err)
	dayBowel, err := m.AnalyticsMetric.Get7DaysBowelTypeOccurrences(ctx, uid, days)
	grab("day_bowel", dayBowel, err)
	dayEx, err := m.AnalyticsMetric.Get7DaysExerciseOccurrences(ctx, uid, days)
	grab("day_exercise", dayEx, err)
	dayTag, err := m.AnalyticsMetric.Get7DaysTagOccurrences(ctx, uid, days, "")
	grab("day_tag_all", dayTag, err)
	dayTagF, err := m.AnalyticsMetric.Get7DaysTagOccurrences(ctx, uid, days, "apple")
	grab("day_tag_apple", dayTagF, err)

	moSym, err := m.AnalyticsMetric.GetMonthSymptomOccurrences(ctx, uid, symID, year, month)
	grab("month_symptom", moSym, err)
	moBowel, err := m.AnalyticsMetric.GetMonthBowelTypeOccurrences(ctx, uid, year, month)
	grab("month_bowel", moBowel, err)
	moEx, err := m.AnalyticsMetric.GetMonthExerciseTypeOccurrences(ctx, uid, year, month)
	grab("month_exercise", moEx, err)
	moTag, err := m.AnalyticsMetric.GetMonthTagOccurrences(ctx, uid, year, month, "")
	grab("month_tag_all", moTag, err)
	moTagF, err := m.AnalyticsMetric.GetMonthTagOccurrences(ctx, uid, year, month, "apple")
	grab("month_tag_apple", moTagF, err)

	yrSym, err := m.AnalyticsMetric.GetYearSymptomOccurrences(ctx, uid, symID, year)
	grab("year_symptom", yrSym, err)
	yrBowel, err := m.AnalyticsMetric.GetYearBowelTypeOccurrences(ctx, uid, year)
	grab("year_bowel", yrBowel, err)
	yrEx, err := m.AnalyticsMetric.GetYearExerciseTypeOccurrences(ctx, uid, year)
	grab("year_exercise", yrEx, err)
	yrTag, err := m.AnalyticsMetric.GetYearTagOccurrences(ctx, uid, year, "")
	grab("year_tag_all", yrTag, err)
	yrTagF, err := m.AnalyticsMetric.GetYearTagOccurrences(ctx, uid, year, "apple")
	grab("year_tag_apple", yrTagF, err)

	if e != nil {
		t.Fatalf("analytics call failed: %v", e)
	}

	// All 15 calls (12 methods; tag with and without a filter) must be JSON-
	// marshalable and produce a result for every one. The full canonical JSON is
	// emitted under -v (between SNAPSHOT markers) for golden diffing during
	// refactors; day/year buckets depend on CURRENT_DATE so it isn't a static
	// fixture.
	if len(out) != 15 {
		t.Fatalf("expected 15 analytics results, got %d", len(out))
	}
	b, err := json.MarshalIndent(out, "", "  ")
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	t.Logf("\nSNAPSHOT_BEGIN\n%s\nSNAPSHOT_END\n", string(b))
}

func mustExec(t *testing.T, db *sql.DB, q string, args ...any) {
	t.Helper()
	if _, err := db.Exec(q, args...); err != nil {
		t.Fatalf("seed exec failed: %v\nquery: %s", err, q)
	}
}

func itoa(n int) string {
	// small non-negative ints only
	if n == 0 {
		return "0"
	}
	var b []byte
	for n > 0 {
		b = append([]byte{byte('0' + n%10)}, b...)
		n /= 10
	}
	return string(b)
}

func pqStrs(s ...string) any {
	// build a Postgres text[] literal like {"apple","egg"}
	out := "{"
	for i, v := range s {
		if i > 0 {
			out += ","
		}
		out += `"` + v + `"`
	}
	return out + "}"
}
