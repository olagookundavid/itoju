import 'package:uuid/uuid.dart';

/// Client-side id minting for offline-first sync.
///
/// This is one of THREE implementations of the same contract (the others are the
/// Go sync code and the SQL backfill/triggers in the backend). They must agree
/// byte-for-byte. See /SYNC_ID_SPEC.md and the golden vectors in
/// test/data/ids_test.dart (which mirror the backend's det_sync_id_db_test.go).
class IdMinter {
  IdMinter._();

  static const _uuid = Uuid();

  /// uuidv5(NAMESPACE_DNS, "sync.itoju.app") — the app's deterministic namespace.
  /// Hardcoded literal (matches the backend); recomputed value must equal this.
  static const String namespace = 'cda0d494-38a4-51db-b52d-62713a57ad8c';

  /// Random, time-ordered id for list-style rows (exercise, medication, sleep,
  /// urine, bowel, smiley entries, point records).
  static String v7() => _uuid.v7();

  /// Deterministic id for a one-per-day food row.
  /// name = "{accountId}:user_food_metric:{yyyy-MM-dd}"
  static String food(String accountId, String date) =>
      _v5('$accountId:user_food_metric:$date');

  /// Deterministic id for a one-per-(symptom,day) symptoms row.
  /// name = "{accountId}:user_symptoms_metric:{symptomsId}:{yyyy-MM-dd}"
  static String symptoms(String accountId, int symptomsId, String date) =>
      _v5('$accountId:user_symptoms_metric:$symptomsId:$date');

  /// Deterministic id for a one-per-day menstrual cycle row (keyed on start date).
  static String cycle(String accountId, String startDate) =>
      _v5('$accountId:menstrual_cycles:$startDate');

  /// Deterministic id for a cycle-day row (one per (cycle, day)). Includes the
  /// parent cycle id — itself deterministic — so two devices generating the same
  /// cycle produce identical day ids, while days of overlapping cycles stay
  /// distinct. Must match the backend trigger recipe (migration 038).
  static String cycleDay(String accountId, String cycleId, String date) =>
      _v5('$accountId:cycles_days:$cycleId:$date');

  /// Deterministic id for a tracked-metric selection row (one per metric).
  static String trackedMetric(String accountId, int metricId) =>
      _v5('$accountId:user_trackedmetric:$metricId');

  /// Deterministic id for a condition selection row (one per condition).
  static String condition(String accountId, int conditionId) =>
      _v5('$accountId:user_condition:$conditionId');

  /// Deterministic id for the single per-account settings row.
  static String settings(String accountId) => _v5('$accountId:user_settings');

  static String _v5(String name) => _uuid.v5(namespace, name);
}
