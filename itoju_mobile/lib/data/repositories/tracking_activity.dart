import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../today_logic.dart';

/// "Has this person logged anything?" questions, answered from the local
/// database. Shared by the Home streak and the evening check-in nudge, so both
/// agree on what counts as tracking.
class TrackingActivity {
  TrackingActivity(this._db);
  final AppDatabase _db;

  /// Consecutive days with a logged entry, ending [today] (or yesterday while
  /// today is still empty). Only the eight trackers count, as on Home.
  Future<int> streak(DateTime today) async {
    final rows = await _db.customSelect('''
      SELECT DISTINCT date FROM (
        SELECT date FROM symptom_metrics    WHERE deleted_at IS NULL UNION
        SELECT date FROM food_metrics       WHERE deleted_at IS NULL UNION
        SELECT date FROM sleep_metrics      WHERE deleted_at IS NULL UNION
        SELECT date FROM medication_metrics WHERE deleted_at IS NULL UNION
        SELECT date FROM exercise_metrics   WHERE deleted_at IS NULL UNION
        SELECT date FROM urine_metrics      WHERE deleted_at IS NULL UNION
        SELECT date FROM bowel_metrics      WHERE deleted_at IS NULL UNION
        SELECT date FROM bp_metrics         WHERE deleted_at IS NULL
      ) ORDER BY date DESC LIMIT 400
    ''').get();
    return computeStreak(rows.map((r) => r.read<String>('date')).toSet(), today);
  }

  /// Whether anything at all was logged on [day]: one of the eight trackers, a
  /// period/cycle entry, or a mood. Wider than the streak on purpose: someone
  /// who only logged their mood today should not be told nothing is logged.
  Future<bool> trackedOn(DateTime day) async {
    final date = _isoDate(day);
    final row = await _db.customSelect('''
      SELECT EXISTS (
        SELECT 1 FROM symptom_metrics    WHERE date = ?1 AND deleted_at IS NULL UNION ALL
        SELECT 1 FROM food_metrics       WHERE date = ?1 AND deleted_at IS NULL UNION ALL
        SELECT 1 FROM sleep_metrics      WHERE date = ?1 AND deleted_at IS NULL UNION ALL
        SELECT 1 FROM medication_metrics WHERE date = ?1 AND deleted_at IS NULL UNION ALL
        SELECT 1 FROM exercise_metrics   WHERE date = ?1 AND deleted_at IS NULL UNION ALL
        SELECT 1 FROM urine_metrics      WHERE date = ?1 AND deleted_at IS NULL UNION ALL
        SELECT 1 FROM bowel_metrics      WHERE date = ?1 AND deleted_at IS NULL UNION ALL
        SELECT 1 FROM bp_metrics         WHERE date = ?1 AND deleted_at IS NULL UNION ALL
        SELECT 1 FROM cycle_days         WHERE date = ?1 AND deleted_at IS NULL
      ) AS found
    ''', variables: [Variable<String>(date)]).getSingle();
    if (row.read<int>('found') == 1) return true;

    // Moods carry a timestamp rather than a date.
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day + 1);
    final mood = await (_db.select(_db.smileyEntries)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.grantedAt.isBiggerOrEqualValue(start) &
              t.grantedAt.isSmallerThanValue(end))
          ..limit(1))
        .getSingleOrNull();
    return mood != null;
  }

  static String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
