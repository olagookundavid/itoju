/// The per-table sync contract shared with the Go backend (internal/models/sync.go).
/// Column names are the SQLite/Postgres column names (drift stores camelCase Dart
/// getters as snake_case, so these match on both sides). `backend` is the table
/// name the sync API expects; `client` is the local Drift table name.
library;

enum ColKind { text, number, boolean, date, tags, timestamp }

class SyncCol {
  /// Column name in the sync payload / backend table.
  final String name;
  final ColKind kind;

  /// Column name in the local SQLite table when it differs from [name]
  /// (e.g. the backend's `conditions_id` is the local `condition_id`).
  final String local;
  const SyncCol(this.name, this.kind, {String? local}) : local = local ?? name;
}

class SyncTableSpec {
  final String backend; // table name in the sync payload (matches backend)
  final String client; // local Drift/SQLite table name
  final List<SyncCol> cols; // domain columns (excludes id + sync bookkeeping)
  const SyncTableSpec(this.backend, this.client, this.cols);
}

const List<SyncTableSpec> kSyncTables = [
  SyncTableSpec('user_symptoms_metric', 'symptom_metrics', [
    SyncCol('symptoms_id', ColKind.number),
    SyncCol('date', ColKind.date),
    SyncCol('morning_severity', ColKind.number),
    SyncCol('afternoon_severity', ColKind.number),
    SyncCol('night_severity', ColKind.number),
  ]),
  SyncTableSpec('user_food_metric', 'food_metrics', [
    SyncCol('date', ColKind.date),
    SyncCol('breakfast_meal', ColKind.text),
    SyncCol('lunch_meal', ColKind.text),
    SyncCol('dinner_meal', ColKind.text),
    SyncCol('breakfast_extra', ColKind.text),
    SyncCol('lunch_extra', ColKind.text),
    SyncCol('dinner_extra', ColKind.text),
    SyncCol('breakfast_fruit', ColKind.text),
    SyncCol('lunch_fruit', ColKind.text),
    SyncCol('dinner_fruit', ColKind.text),
    SyncCol('breakfast_tags', ColKind.tags),
    SyncCol('lunch_tags', ColKind.tags),
    SyncCol('dinner_tags', ColKind.tags),
    SyncCol('snack_name', ColKind.text),
    SyncCol('snack_tags', ColKind.tags),
    SyncCol('glass_no', ColKind.number),
  ]),
  SyncTableSpec('user_sleep_metric', 'sleep_metrics', [
    SyncCol('date', ColKind.date),
    SyncCol('is_night', ColKind.boolean),
    SyncCol('time_slept', ColKind.text),
    SyncCol('time_woke_up', ColKind.text),
    SyncCol('tags', ColKind.tags),
    SyncCol('severity', ColKind.number),
  ]),
  SyncTableSpec('user_medication_metric', 'medication_metrics', [
    SyncCol('date', ColKind.date),
    SyncCol('name', ColKind.text),
    SyncCol('dosage', ColKind.number),
    SyncCol('metric', ColKind.text),
    SyncCol('quantity', ColKind.number),
    SyncCol('time', ColKind.text),
  ]),
  SyncTableSpec('user_exercise_metric', 'exercise_metrics', [
    SyncCol('date', ColKind.date),
    SyncCol('name', ColKind.text),
    SyncCol('started', ColKind.text),
    SyncCol('ended', ColKind.text),
    SyncCol('tags', ColKind.tags),
    SyncCol('no_of_times', ColKind.number),
  ]),
  SyncTableSpec('user_urine_metric', 'urine_metrics', [
    SyncCol('date', ColKind.date),
    SyncCol('type', ColKind.number),
    SyncCol('pain', ColKind.number),
    SyncCol('time', ColKind.text),
    SyncCol('tags', ColKind.tags),
    SyncCol('quantity', ColKind.number),
  ]),
  SyncTableSpec('user_bowel_metric', 'bowel_metrics', [
    SyncCol('date', ColKind.date),
    SyncCol('type', ColKind.number),
    SyncCol('pain', ColKind.number),
    SyncCol('time', ColKind.text),
    SyncCol('tags', ColKind.tags),
  ]),
  SyncTableSpec('user_bp_metric', 'bp_metrics', [
    SyncCol('date', ColKind.date),
    SyncCol('time', ColKind.text),
    SyncCol('systolic', ColKind.number),
    SyncCol('diastolic', ColKind.number),
    SyncCol('pulse', ColKind.number),
  ]),
  SyncTableSpec('user_med_reminder', 'med_reminders', [
    SyncCol('name', ColKind.text),
    SyncCol('dosage', ColKind.number),
    SyncCol('unit', ColKind.text),
    SyncCol('quantity', ColKind.number),
    SyncCol('days', ColKind.number),
    SyncCol('times', ColKind.tags),
    SyncCol('enabled', ColKind.boolean),
  ]),
  SyncTableSpec('menstrual_cycles', 'menstrual_cycles', [
    SyncCol('start_date', ColKind.date),
    SyncCol('cycle_length', ColKind.number),
    SyncCol('period_length', ColKind.number),
  ]),
  SyncTableSpec('cycles_days', 'cycle_days', [
    SyncCol('cycle_id', ColKind.text),
    SyncCol('date', ColKind.date),
    SyncCol('is_period', ColKind.boolean),
    SyncCol('is_ovulation', ColKind.boolean),
    SyncCol('flow', ColKind.number),
    SyncCol('pain', ColKind.number),
    SyncCol('tags', ColKind.tags),
    SyncCol('cmq', ColKind.text),
  ]),
  // --- selections and settings ---
  // Tracked metrics / conditions are one row per selection with a deterministic
  // id; a deselect syncs as a tombstone.
  SyncTableSpec('user_trackedmetric', 'user_tracked_metrics', [
    SyncCol('metric_id', ColKind.number),
    SyncCol('granted_at', ColKind.timestamp),
  ]),
  SyncTableSpec('user_conditions', 'user_conditions', [
    SyncCol('conditions_id', ColKind.number, local: 'condition_id'),
  ]),
  // The device keeps ONE local settings row; the backend stores it as two tables
  // (menstruation, bodymeasure) that share that row's id. Two specs, one client
  // table — each carries only its own columns. See SyncEngine for how the shared
  // pending flag is kept safe.
  SyncTableSpec('menstruation', 'user_settings', [
    SyncCol('period_len', ColKind.number),
    SyncCol('cycle_len', ColKind.number),
  ]),
  // Decimal cm / kg. The backend's whole-number `bodymeasure` spec is left for
  // 1.1.x builds; both read and write the same server table (migration 044).
  SyncTableSpec('bodymeasure_v2', 'user_settings', [
    SyncCol('height_cm', ColKind.number),
    SyncCol('weight_kg', ColKind.number),
  ]),
  // Points ledger. Synced so a restored device shows the same total (server-only
  // Login awards are filtered out server-side).
  SyncTableSpec('user_point_record', 'point_records', [
    SyncCol('point', ColKind.number),
    SyncCol('scope', ColKind.text),
    SyncCol('date', ColKind.date),
  ]),
  SyncTableSpec('user_smiley', 'smiley_entries', [
    SyncCol('smiley_id', ColKind.number),
    SyncCol('tags', ColKind.tags),
    SyncCol('granted_at', ColKind.timestamp),
  ]),
];
