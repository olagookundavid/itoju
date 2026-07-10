/// The per-table sync contract shared with the Go backend (internal/models/sync.go).
/// Column names are the SQLite/Postgres column names (drift stores camelCase Dart
/// getters as snake_case, so these match on both sides). `backend` is the table
/// name the sync API expects; `client` is the local Drift table name.
library;

enum ColKind { text, number, boolean, date, tags, timestamp }

class SyncCol {
  final String name;
  final ColKind kind;
  const SyncCol(this.name, this.kind);
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
  SyncTableSpec('user_smiley', 'smiley_entries', [
    SyncCol('smiley_id', ColKind.number),
    SyncCol('tags', ColKind.tags),
    SyncCol('granted_at', ColKind.timestamp),
  ]),
];
