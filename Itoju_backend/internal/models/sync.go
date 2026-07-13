package models

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/lib/pq"
)

// SyncModel implements the offline-first push/pull protocol over the existing
// per-resource tables. It is data-driven: each syncable table is described by a
// syncSpec (its client-id column and its domain columns), and one generic upsert
// / delta-select is generated from that. All sync writes derive user_id from the
// authenticated request, never the payload, so the surface is IDOR-proof.
type SyncModel struct {
	DB *sql.DB
}

// pullGrace is subtracted from now() to form each pull's upper watermark, so a
// transaction that committed with an slightly-earlier now() can't be skipped
// past by a reader that observes a later clock.
const pullGrace = 5 * time.Second

type colKind int

const (
	kText colKind = iota // TEXT / VARCHAR
	kNum                 // SMALLINT / INT / NUMERIC — carried as JSON number
	kBool                // BOOLEAN
	kDate                // DATE — carried as "yyyy-MM-dd"
	kTags                // TEXT[] — carried as JSON array of strings
	kTs                  // TIMESTAMP(TZ) — carried as RFC3339
)

type syncCol struct {
	name string
	kind colKind
}

// syncSpec describes one table. idCol is the column holding the client-minted
// UUID, which is the primary key `id` on every syncable table after the 036 PK
// cutover. healKey names the natural-key columns of one-per-day tables (guarded
// by a live partial unique index): when a pushed row's id collides with an
// existing live row for the same natural key — e.g. a server-side legacy id vs
// the client's deterministic id for the same day — the push "heals" onto the
// existing row instead of failing the batch.
type syncSpec struct {
	table   string
	idCol   string
	cols    []syncCol
	healKey []string
}

const dateLayout = "2006-01-02"

// syncSpecs is the v1 sync scope: all client-logged health data. Singleton
// settings (menstruation, bodymeasure) and selection sets (user_symptoms,
// user_conditions) are re-asserted by the client and land in a follow-up.
var syncSpecs = map[string]syncSpec{
	"user_symptoms_metric": {table: "user_symptoms_metric", idCol: "id", cols: []syncCol{
		{"symptoms_id", kNum}, {"date", kDate},
		{"morning_severity", kNum}, {"afternoon_severity", kNum}, {"night_severity", kNum},
	}, healKey: []string{"symptoms_id", "date"}},
	"user_food_metric": {table: "user_food_metric", idCol: "id", cols: []syncCol{
		{"date", kDate},
		{"breakfast_meal", kText}, {"lunch_meal", kText}, {"dinner_meal", kText},
		{"breakfast_extra", kText}, {"lunch_extra", kText}, {"dinner_extra", kText},
		{"breakfast_fruit", kText}, {"lunch_fruit", kText}, {"dinner_fruit", kText},
		{"breakfast_tags", kTags}, {"lunch_tags", kTags}, {"dinner_tags", kTags},
		{"snack_name", kText}, {"snack_tags", kTags}, {"glass_no", kNum},
	}, healKey: []string{"date"}},
	"user_sleep_metric": {table: "user_sleep_metric", idCol: "id", cols: []syncCol{
		{"date", kDate}, {"is_night", kBool}, {"time_slept", kText},
		{"time_woke_up", kText}, {"tags", kTags}, {"severity", kNum},
	}},
	"user_medication_metric": {table: "user_medication_metric", idCol: "id", cols: []syncCol{
		{"date", kDate}, {"name", kText}, {"dosage", kNum},
		{"metric", kText}, {"quantity", kNum}, {"time", kText},
	}},
	"user_exercise_metric": {table: "user_exercise_metric", idCol: "id", cols: []syncCol{
		{"date", kDate}, {"name", kText}, {"started", kText},
		{"ended", kText}, {"tags", kTags}, {"no_of_times", kNum},
	}},
	"user_urine_metric": {table: "user_urine_metric", idCol: "id", cols: []syncCol{
		{"date", kDate}, {"type", kNum}, {"pain", kNum},
		{"time", kText}, {"tags", kTags}, {"quantity", kNum},
	}},
	"user_bowel_metric": {table: "user_bowel_metric", idCol: "id", cols: []syncCol{
		{"date", kDate}, {"type", kNum}, {"pain", kNum}, {"time", kText}, {"tags", kTags},
	}},
	"menstrual_cycles": {table: "menstrual_cycles", idCol: "id", cols: []syncCol{
		{"start_date", kDate}, {"cycle_length", kNum}, {"period_length", kNum},
	}, healKey: []string{"start_date"}},
	"cycles_days": {table: "cycles_days", idCol: "id", cols: []syncCol{
		{"cycle_id", kText}, {"date", kDate}, {"is_period", kBool}, {"is_ovulation", kBool},
		{"flow", kNum}, {"pain", kNum}, {"tags", kTags}, {"cmq", kText},
	}},
	"user_smiley": {table: "user_smiley", idCol: "id", cols: []syncCol{
		{"smiley_id", kNum}, {"tags", kTags}, {"granted_at", kTs},
	}},
}

// SyncableTables returns the sorted list of table names the protocol accepts.
func SyncableTables() []string {
	out := make([]string, 0, len(syncSpecs))
	for t := range syncSpecs {
		out = append(out, t)
	}
	return out
}

// PushResult is the per-row outcome returned to the client.
type PushResult struct {
	ID              string    `json:"id"`
	Status          string    `json:"status"` // applied | stale | rejected
	ServerUpdatedAt time.Time `json:"server_updated_at"`
}

// ErrBadSyncRow marks a client-supplied row that failed validation (missing id,
// unparseable timestamps). The handler maps it to a 422 instead of a 500 so a
// malformed row is the client's error, not a server incident.
var ErrBadSyncRow = errors.New("invalid sync row")

// Push upserts a batch of rows for one table inside a single transaction, using
// last-write-wins on updated_at and an ownership guard. Idempotent: re-pushing an
// already-applied row returns "stale". Each row runs under a savepoint so a
// natural-key unique violation (a client id colliding with an existing live row
// for the same day — e.g. a server-backfilled legacy id vs a client-minted
// deterministic id) is healed onto the existing row instead of aborting the
// whole batch.
func (m SyncModel) Push(ctx context.Context, userID, table string, rows []json.RawMessage) ([]PushResult, error) {
	spec, ok := syncSpecs[table]
	if !ok {
		return nil, fmt.Errorf("unknown sync table %q", table)
	}
	results := make([]PushResult, 0, len(rows))
	err := withTx(ctx, m.DB, func(tx *sql.Tx) error {
		upsertSQL := spec.upsertSQL()
		ownerSQL := fmt.Sprintf(`SELECT user_id FROM %s WHERE %s = $1`, spec.table, spec.idCol)
		for i, raw := range rows {
			row, err := spec.parseRow(raw)
			if err != nil {
				return err
			}
			sp := fmt.Sprintf("sync_row_%d", i)
			if _, err := tx.ExecContext(ctx, "SAVEPOINT "+sp); err != nil {
				return err
			}
			res, err := spec.upsertRow(ctx, tx, userID, row, upsertSQL, ownerSQL)
			if err != nil && isUniqueViolation(err, "") {
				// A secondary unique (one-per-day natural key) fired: recover the
				// tx to the savepoint and converge onto the existing live row.
				if _, rerr := tx.ExecContext(ctx, "ROLLBACK TO SAVEPOINT "+sp); rerr != nil {
					return rerr
				}
				res, err = spec.healRow(ctx, tx, userID, row)
			}
			if err != nil {
				return err
			}
			results = append(results, res)
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return results, nil
}

func (s syncSpec) upsertSQL() string {
	insertCols := []string{s.idCol, "user_id"}
	for _, c := range s.cols {
		insertCols = append(insertCols, c.name)
	}
	insertCols = append(insertCols, "updated_at", "deleted_at")

	placeholders := make([]string, len(insertCols))
	for i := range insertCols {
		placeholders[i] = fmt.Sprintf("$%d", i+1)
	}

	setClauses := make([]string, 0, len(s.cols)+2)
	for _, c := range s.cols {
		setClauses = append(setClauses, fmt.Sprintf("%s = EXCLUDED.%s", c.name, c.name))
	}
	setClauses = append(setClauses,
		"updated_at = EXCLUDED.updated_at", "deleted_at = EXCLUDED.deleted_at")

	return fmt.Sprintf(`
		INSERT INTO %s (%s) VALUES (%s)
		ON CONFLICT (%s) DO UPDATE SET %s
		WHERE %s.user_id = EXCLUDED.user_id AND EXCLUDED.updated_at > %s.updated_at
		RETURNING server_updated_at`,
		s.table, strings.Join(insertCols, ", "), strings.Join(placeholders, ", "),
		s.idCol, strings.Join(setClauses, ", "),
		s.table, s.table)
}

// parsedSyncRow is a client row after validation: its id, timestamps, and the
// raw column values keyed by column name.
type parsedSyncRow struct {
	id        string
	updatedAt time.Time
	deletedAt any
	data      map[string]any
}

// parseRow validates a raw client row; malformed input wraps ErrBadSyncRow so
// the handler can answer 422 instead of 500.
func (s syncSpec) parseRow(raw json.RawMessage) (parsedSyncRow, error) {
	var row map[string]any
	if err := json.Unmarshal(raw, &row); err != nil {
		return parsedSyncRow{}, fmt.Errorf("%w: %s: %v", ErrBadSyncRow, s.table, err)
	}
	id, _ := row["id"].(string)
	if id == "" {
		return parsedSyncRow{}, fmt.Errorf("%w: %s row missing id", ErrBadSyncRow, s.table)
	}
	updatedAt, err := parseTime(row["updated_at"])
	if err != nil {
		return parsedSyncRow{}, fmt.Errorf("%w: row %s: bad updated_at: %v", ErrBadSyncRow, id, err)
	}
	var deletedAt any
	if dv, ok := row["deleted_at"]; ok && dv != nil {
		t, err := parseTime(dv)
		if err != nil {
			return parsedSyncRow{}, fmt.Errorf("%w: row %s: bad deleted_at: %v", ErrBadSyncRow, id, err)
		}
		deletedAt = t
	}
	return parsedSyncRow{id: id, updatedAt: updatedAt, deletedAt: deletedAt, data: row}, nil
}

func (s syncSpec) upsertRow(ctx context.Context, tx *sql.Tx, userID string, row parsedSyncRow, upsertSQL, ownerSQL string) (PushResult, error) {
	args := make([]any, 0, len(s.cols)+4)
	args = append(args, row.id, userID)
	for _, c := range s.cols {
		args = append(args, bindArg(c.kind, row.data[c.name]))
	}
	args = append(args, row.updatedAt, row.deletedAt)

	var serverUpdatedAt time.Time
	err := tx.QueryRowContext(ctx, upsertSQL, args...).Scan(&serverUpdatedAt)
	switch {
	case err == nil:
		return PushResult{ID: row.id, Status: "applied", ServerUpdatedAt: serverUpdatedAt}, nil
	case errors.Is(err, sql.ErrNoRows):
		// No row upserted: either a foreign-owned id (reject) or a stale write.
		var owner string
		qerr := tx.QueryRowContext(ctx, ownerSQL, row.id).Scan(&owner)
		if qerr == nil && owner != userID {
			return PushResult{ID: row.id, Status: "rejected"}, nil
		}
		// Existing row is ours and newer (or the lookup failed benignly): stale.
		var srv time.Time
		_ = tx.QueryRowContext(ctx,
			fmt.Sprintf(`SELECT server_updated_at FROM %s WHERE %s = $1`, s.table, s.idCol), row.id).Scan(&srv)
		return PushResult{ID: row.id, Status: "stale", ServerUpdatedAt: srv}, nil
	default:
		return PushResult{}, err
	}
}

// healRow converges a pushed row whose id collided with an existing LIVE row
// for the same natural key (one-per-day tables). Two steps, both keyed on the
// natural key + user_id:
//  1. LWW take-over — if the client's edit is newer, the existing row adopts
//     the client's id AND data ("applied").
//  2. Id-only adoption — if the existing row is newer, it adopts just the
//     client's id so future syncs converge on one physical row; the client
//     keeps its local copy pending-free and pulls the newer data ("stale").
//
// Tables without a healKey (list tables) reject the row rather than poisoning
// the batch — a uniqueness conflict there means a misbehaving client.
func (s syncSpec) healRow(ctx context.Context, tx *sql.Tx, userID string, row parsedSyncRow) (PushResult, error) {
	if len(s.healKey) == 0 {
		return PushResult{ID: row.id, Status: "rejected"}, nil
	}

	kindOf := func(name string) ColKindLookup {
		for _, c := range s.cols {
			if c.name == name {
				return ColKindLookup{c.kind, true}
			}
		}
		return ColKindLookup{}
	}

	// Shared natural-key WHERE (live row owned by this user).
	whereKey := func(startArg int, args *[]any) (string, int) {
		parts := []string{fmt.Sprintf("user_id = $%d", startArg)}
		*args = append(*args, userID)
		n := startArg + 1
		for _, k := range s.healKey {
			kk := kindOf(k)
			parts = append(parts, fmt.Sprintf("%s = $%d", k, n))
			*args = append(*args, bindArg(kk.kind, row.data[k]))
			n++
		}
		parts = append(parts, "deleted_at IS NULL")
		return strings.Join(parts, " AND "), n
	}

	// Step 1: full take-over when the client's edit wins LWW.
	set := []string{fmt.Sprintf("%s = $1", s.idCol)}
	args := []any{row.id}
	n := 2
	for _, c := range s.cols {
		set = append(set, fmt.Sprintf("%s = $%d", c.name, n))
		args = append(args, bindArg(c.kind, row.data[c.name]))
		n++
	}
	set = append(set, fmt.Sprintf("updated_at = $%d", n))
	args = append(args, row.updatedAt)
	n++
	set = append(set, fmt.Sprintf("deleted_at = $%d", n))
	args = append(args, row.deletedAt)
	n++
	where, n := whereKey(n, &args)
	takeover := fmt.Sprintf(`UPDATE %s SET %s WHERE %s AND updated_at < $%d RETURNING server_updated_at`,
		s.table, strings.Join(set, ", "), where, n)
	args = append(args, row.updatedAt)

	var srv time.Time
	err := tx.QueryRowContext(ctx, takeover, args...).Scan(&srv)
	if err == nil {
		return PushResult{ID: row.id, Status: "applied", ServerUpdatedAt: srv}, nil
	}
	if !errors.Is(err, sql.ErrNoRows) {
		return PushResult{}, err
	}

	// Step 2: existing row is newer — adopt the client id only, keep server data.
	args = []any{row.id}
	where2, _ := whereKey(2, &args)
	adopt := fmt.Sprintf(`UPDATE %s SET %s = $1 WHERE %s RETURNING server_updated_at`,
		s.table, s.idCol, where2)
	err = tx.QueryRowContext(ctx, adopt, args...).Scan(&srv)
	switch {
	case err == nil:
		return PushResult{ID: row.id, Status: "stale", ServerUpdatedAt: srv}, nil
	case errors.Is(err, sql.ErrNoRows):
		// No live natural-key row after all — shouldn't happen; reject the row.
		return PushResult{ID: row.id, Status: "rejected"}, nil
	default:
		return PushResult{}, err
	}
}

// ColKindLookup pairs a column kind with whether the lookup found it.
type ColKindLookup struct {
	kind colKind
	ok   bool
}

// PullCursor is a keyset cursor into one table's delta: strictly after the row
// (Ts, ID) in (server_updated_at, id) order. The compound key matters because
// many rows can share one server_updated_at (a single push tx, or the 032
// backfill stamping all legacy rows identically) — a bare timestamp cursor
// would skip the rest of a tie that straddles a page boundary.
type PullCursor struct {
	Ts string `json:"ts"`
	ID string `json:"id"`
}

// Pull returns rows changed strictly after the cursor position — (since) when
// cursorID is empty, else the keyset (cursorTs, cursorID) — up to and including
// `until` (the request-stable watermark), ordered by (server_updated_at, id),
// capped at limit. When hasMore is true the caller resumes from the returned
// last-row cursor with the SAME `until`, and must not advance its persisted
// watermark until a sweep completes with hasMore=false.
func (m SyncModel) Pull(ctx context.Context, userID, table string, since time.Time, cursorID string, until time.Time, limit int) ([]map[string]any, bool, error) {
	spec, ok := syncSpecs[table]
	if !ok {
		return nil, false, fmt.Errorf("unknown sync table %q", table)
	}
	if limit <= 0 || limit > 1000 {
		limit = 500
	}

	selectCols := []string{spec.idCol + " AS id"}
	for _, c := range spec.cols {
		selectCols = append(selectCols, c.name)
	}
	selectCols = append(selectCols, "updated_at", "deleted_at", "server_updated_at")

	// First page uses a plain strict timestamp bound (watermark semantics);
	// subsequent pages use the compound keyset so timestamp ties are not skipped.
	cursorCond := "server_updated_at > $2"
	args := []any{userID, since, until, limit}
	if cursorID != "" {
		cursorCond = fmt.Sprintf("(server_updated_at, %s) > ($2, $5::uuid)", spec.idCol)
		args = append(args, cursorID)
	}

	query := fmt.Sprintf(`
		SELECT %s FROM %s
		WHERE user_id = $1 AND %s AND server_updated_at <= $3
		ORDER BY server_updated_at, %s
		LIMIT $4`,
		strings.Join(selectCols, ", "), spec.table, cursorCond, spec.idCol)

	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	sqlRows, err := m.DB.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, false, err
	}
	defer sqlRows.Close()

	out := []map[string]any{}
	for sqlRows.Next() {
		row, err := spec.scanRow(sqlRows)
		if err != nil {
			return nil, false, err
		}
		out = append(out, row)
	}
	if err := sqlRows.Err(); err != nil {
		return nil, false, err
	}
	return out, len(out) == limit, nil
}

func (s syncSpec) scanRow(rows *sql.Rows) (map[string]any, error) {
	var id string
	dests := []any{&id}
	holders := make([]any, len(s.cols))
	for i, c := range s.cols {
		holders[i] = newHolder(c.kind)
		dests = append(dests, holders[i])
	}
	var updatedAt, serverUpdatedAt sql.NullTime
	var deletedAt sql.NullTime
	dests = append(dests, &updatedAt, &deletedAt, &serverUpdatedAt)

	if err := rows.Scan(dests...); err != nil {
		return nil, err
	}

	row := map[string]any{"id": id}
	for i, c := range s.cols {
		row[c.name] = readHolder(c.kind, holders[i])
	}
	if updatedAt.Valid {
		row["updated_at"] = updatedAt.Time.UTC().Format(time.RFC3339Nano)
	}
	if deletedAt.Valid {
		row["deleted_at"] = deletedAt.Time.UTC().Format(time.RFC3339Nano)
	} else {
		row["deleted_at"] = nil
	}
	if serverUpdatedAt.Valid {
		row["server_updated_at"] = serverUpdatedAt.Time.UTC().Format(time.RFC3339Nano)
	}
	return row, nil
}

// --- value binding / scanning per column kind ---

func bindArg(kind colKind, v any) any {
	switch kind {
	case kTags:
		return pq.Array(toStringSlice(v))
	case kNum:
		f, _ := v.(float64)
		return f
	case kBool:
		b, _ := v.(bool)
		return b
	default: // kText, kDate, kTs — carried as strings
		s, _ := v.(string)
		return s
	}
}

func newHolder(kind colKind) any {
	switch kind {
	case kTags:
		return &pq.StringArray{}
	case kNum:
		return new(float64)
	case kBool:
		return new(bool)
	case kDate, kTs:
		return new(time.Time)
	default:
		return new(string)
	}
}

func readHolder(kind colKind, h any) any {
	switch kind {
	case kTags:
		arr := *h.(*pq.StringArray)
		if arr == nil {
			return []string{}
		}
		return []string(arr)
	case kNum:
		return *h.(*float64)
	case kBool:
		return *h.(*bool)
	case kDate:
		return h.(*time.Time).UTC().Format(dateLayout)
	case kTs:
		return h.(*time.Time).UTC().Format(time.RFC3339Nano)
	default:
		return *h.(*string)
	}
}

func toStringSlice(v any) []string {
	arr, ok := v.([]any)
	if !ok {
		return []string{}
	}
	out := make([]string, 0, len(arr))
	for _, e := range arr {
		if s, ok := e.(string); ok {
			out = append(out, s)
		}
	}
	return out
}

func parseTime(v any) (time.Time, error) {
	s, ok := v.(string)
	if !ok {
		return time.Time{}, fmt.Errorf("expected RFC3339 string, got %T", v)
	}
	return time.Parse(time.RFC3339, s)
}
