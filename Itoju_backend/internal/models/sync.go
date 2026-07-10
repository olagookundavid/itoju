package models

import (
	"context"
	"database/sql"
	"encoding/json"
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
// cutover.
type syncSpec struct {
	table string
	idCol string
	cols  []syncCol
}

const dateLayout = "2006-01-02"

// syncSpecs is the v1 sync scope: all client-logged health data. Singleton
// settings (menstruation, bodymeasure) and selection sets (user_symptoms,
// user_conditions) are re-asserted by the client and land in a follow-up.
var syncSpecs = map[string]syncSpec{
	"user_symptoms_metric": {"user_symptoms_metric", "id", []syncCol{
		{"symptoms_id", kNum}, {"date", kDate},
		{"morning_severity", kNum}, {"afternoon_severity", kNum}, {"night_severity", kNum},
	}},
	"user_food_metric": {"user_food_metric", "id", []syncCol{
		{"date", kDate},
		{"breakfast_meal", kText}, {"lunch_meal", kText}, {"dinner_meal", kText},
		{"breakfast_extra", kText}, {"lunch_extra", kText}, {"dinner_extra", kText},
		{"breakfast_fruit", kText}, {"lunch_fruit", kText}, {"dinner_fruit", kText},
		{"breakfast_tags", kTags}, {"lunch_tags", kTags}, {"dinner_tags", kTags},
		{"snack_name", kText}, {"snack_tags", kTags}, {"glass_no", kNum},
	}},
	"user_sleep_metric": {"user_sleep_metric", "id", []syncCol{
		{"date", kDate}, {"is_night", kBool}, {"time_slept", kText},
		{"time_woke_up", kText}, {"tags", kTags}, {"severity", kNum},
	}},
	"user_medication_metric": {"user_medication_metric", "id", []syncCol{
		{"date", kDate}, {"name", kText}, {"dosage", kNum},
		{"metric", kText}, {"quantity", kNum}, {"time", kText},
	}},
	"user_exercise_metric": {"user_exercise_metric", "id", []syncCol{
		{"date", kDate}, {"name", kText}, {"started", kText},
		{"ended", kText}, {"tags", kTags}, {"no_of_times", kNum},
	}},
	"user_urine_metric": {"user_urine_metric", "id", []syncCol{
		{"date", kDate}, {"type", kNum}, {"pain", kNum},
		{"time", kText}, {"tags", kTags}, {"quantity", kNum},
	}},
	"user_bowel_metric": {"user_bowel_metric", "id", []syncCol{
		{"date", kDate}, {"type", kNum}, {"pain", kNum}, {"time", kText}, {"tags", kTags},
	}},
	"menstrual_cycles": {"menstrual_cycles", "id", []syncCol{
		{"start_date", kDate}, {"cycle_length", kNum}, {"period_length", kNum},
	}},
	"cycles_days": {"cycles_days", "id", []syncCol{
		{"cycle_id", kText}, {"date", kDate}, {"is_period", kBool}, {"is_ovulation", kBool},
		{"flow", kNum}, {"pain", kNum}, {"tags", kTags}, {"cmq", kText},
	}},
	"user_smiley": {"user_smiley", "id", []syncCol{
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

// Push upserts a batch of rows for one table inside a single transaction, using
// last-write-wins on updated_at and an ownership guard. Idempotent: re-pushing an
// already-applied row returns "stale".
func (m SyncModel) Push(ctx context.Context, userID, table string, rows []json.RawMessage) ([]PushResult, error) {
	spec, ok := syncSpecs[table]
	if !ok {
		return nil, fmt.Errorf("unknown sync table %q", table)
	}
	results := make([]PushResult, 0, len(rows))
	err := withTx(ctx, m.DB, func(tx *sql.Tx) error {
		upsertSQL := spec.upsertSQL()
		ownerSQL := fmt.Sprintf(`SELECT user_id FROM %s WHERE %s = $1`, spec.table, spec.idCol)
		for _, raw := range rows {
			res, err := spec.pushRow(ctx, tx, userID, raw, upsertSQL, ownerSQL)
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

func (s syncSpec) pushRow(ctx context.Context, tx *sql.Tx, userID string, raw json.RawMessage, upsertSQL, ownerSQL string) (PushResult, error) {
	var row map[string]any
	if err := json.Unmarshal(raw, &row); err != nil {
		return PushResult{}, err
	}
	id, _ := row["id"].(string)
	if id == "" {
		return PushResult{}, fmt.Errorf("sync row for %s missing id", s.table)
	}
	updatedAt, err := parseTime(row["updated_at"])
	if err != nil {
		return PushResult{}, fmt.Errorf("row %s: bad updated_at: %w", id, err)
	}
	var deletedAt any
	if dv, ok := row["deleted_at"]; ok && dv != nil {
		t, err := parseTime(dv)
		if err != nil {
			return PushResult{}, fmt.Errorf("row %s: bad deleted_at: %w", id, err)
		}
		deletedAt = t
	}

	args := make([]any, 0, len(s.cols)+4)
	args = append(args, id, userID)
	for _, c := range s.cols {
		args = append(args, bindArg(c.kind, row[c.name]))
	}
	args = append(args, updatedAt, deletedAt)

	var serverUpdatedAt time.Time
	err = tx.QueryRowContext(ctx, upsertSQL, args...).Scan(&serverUpdatedAt)
	switch {
	case err == nil:
		return PushResult{ID: id, Status: "applied", ServerUpdatedAt: serverUpdatedAt}, nil
	case err == sql.ErrNoRows:
		// No row upserted: either a foreign-owned id (reject) or a stale write.
		var owner string
		qerr := tx.QueryRowContext(ctx, ownerSQL, id).Scan(&owner)
		if qerr == nil && owner != userID {
			return PushResult{ID: id, Status: "rejected"}, nil
		}
		// Existing row is ours and newer (or the lookup failed benignly): stale.
		var srv time.Time
		_ = tx.QueryRowContext(ctx,
			fmt.Sprintf(`SELECT server_updated_at FROM %s WHERE %s = $1`, s.table, s.idCol), id).Scan(&srv)
		return PushResult{ID: id, Status: "stale", ServerUpdatedAt: srv}, nil
	default:
		return PushResult{}, err
	}
}

// Pull returns rows changed after `since` (exclusive) up to the per-request
// watermark (now-grace), ordered by server_updated_at, capped at limit. hasMore
// signals the client to pull again advancing `since` to the last row's
// server_updated_at.
func (m SyncModel) Pull(ctx context.Context, userID, table string, since time.Time, limit int) ([]map[string]any, bool, error) {
	spec, ok := syncSpecs[table]
	if !ok {
		return nil, false, fmt.Errorf("unknown sync table %q", table)
	}
	if limit <= 0 || limit > 1000 {
		limit = 500
	}
	watermark := time.Now().Add(-pullGrace)

	selectCols := []string{spec.idCol + " AS id"}
	for _, c := range spec.cols {
		selectCols = append(selectCols, c.name)
	}
	selectCols = append(selectCols, "updated_at", "deleted_at", "server_updated_at")

	query := fmt.Sprintf(`
		SELECT %s FROM %s
		WHERE user_id = $1 AND server_updated_at > $2 AND server_updated_at <= $3
		ORDER BY server_updated_at, %s
		LIMIT $4`,
		strings.Join(selectCols, ", "), spec.table, spec.idCol)

	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	sqlRows, err := m.DB.QueryContext(ctx, query, userID, since, watermark, limit)
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
		row["updated_at"] = updatedAt.Time.UTC().Format(time.RFC3339)
	}
	if deletedAt.Valid {
		row["deleted_at"] = deletedAt.Time.UTC().Format(time.RFC3339)
	} else {
		row["deleted_at"] = nil
	}
	if serverUpdatedAt.Valid {
		row["server_updated_at"] = serverUpdatedAt.Time.UTC().Format(time.RFC3339)
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
		return h.(*time.Time).UTC().Format(time.RFC3339)
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
