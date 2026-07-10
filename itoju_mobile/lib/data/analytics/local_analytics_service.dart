import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../db/app_database.dart';
import '../providers.dart';

final localAnalyticsServiceProvider = Provider<LocalAnalyticsService>(
  (ref) => LocalAnalyticsService(ref.watch(appDatabaseProvider)),
);

/// Local replacement for the server ANALYTICS endpoints. Reads the raw metric
/// rows for the requested date range from Drift and buckets them in Dart, then
/// returns maps shaped exactly like the old server JSON so each notifier keeps
/// using its `Model.fromMap`.
///
/// Bucketing mirrors internal/models/analytics_query.go:
///  - 7-day  : day-of-week 0..6 (Postgres DOW, 0=Sunday) over `date >= today-7d`.
///  - week   : week-of-month 1..5 = isoWeek(date) - isoWeek(1st of month) + 1,
///             for a single calendar month.
///  - month  : calendar month 1..12 for a single calendar year.
/// All queries filter deletedAt IS NULL. Dates are ISO 'yyyy-MM-dd' TEXT, so
/// lexicographic range predicates are exact.
class LocalAnalyticsService {
  LocalAnalyticsService(this._db);
  final AppDatabase _db;

  static final DateFormat _fmt = DateFormat('yyyy-MM-dd');

  // --- date-range helpers -------------------------------------------------

  /// Trailing 7-day predicate: date >= (today - 7 days). No upper bound, matching
  /// the backend's `date >= CURRENT_DATE - make_interval(days => 7)`.
  String _sevenDayCutoff() =>
      _fmt.format(DateTime.now().subtract(const Duration(days: 7)));

  String _monthStart(int year, int month) =>
      '$year-${month.toString().padLeft(2, '0')}-01';

  String _monthEndExclusive(int year, int month) {
    final next =
        month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    return _fmt.format(next);
  }

  String _yearStart(int year) => '$year-01-01';
  String _yearEndExclusive(int year) => '${year + 1}-01-01';

  // --- bucket assignment (Dart mirror of the SQL bucket expressions) ------

  DateTime _parse(String isoDate) {
    final d = DateTime.parse(isoDate);
    return DateTime.utc(d.year, d.month, d.day);
  }

  /// Postgres EXTRACT(DOW FROM date): Sunday=0 .. Saturday=6.
  /// Dart weekday is Monday=1 .. Sunday=7, so `weekday % 7` maps Sunday->0.
  int _dowBucket(String isoDate) => _parse(isoDate).weekday % 7;

  /// Week-of-month = isoWeek(date) - isoWeek(1st of that month) + 1, exactly as
  /// `EXTRACT(WEEK FROM date) - EXTRACT(WEEK FROM date_trunc('month', date)) + 1`.
  /// NOTE: like the backend, this can yield out-of-range buckets around the
  /// Jan/Dec ISO-year boundary (e.g. Jan 1 sitting in the prior year's week 52/53);
  /// those rows land outside 1..5 and are dropped, faithful to the Go formula.
  int _weekOfMonthBucket(String isoDate) {
    final d = _parse(isoDate);
    final firstOfMonth = DateTime.utc(d.year, d.month, 1);
    return _isoWeek(d) - _isoWeek(firstOfMonth) + 1;
  }

  int _monthBucket(String isoDate) => _parse(isoDate).month;

  // ISO 8601 week number (1..53), including the cross-year behaviour Postgres'
  // EXTRACT(WEEK) exhibits (early January can be week 52/53 of the prior year,
  // late December can be week 1 of the next).
  int _isoWeeksInYear(int year) {
    int p(int y) => (y + (y ~/ 4) - (y ~/ 100) + (y ~/ 400)) % 7;
    return (p(year) == 4 || p(year - 1) == 3) ? 53 : 52;
  }

  int _isoWeek(DateTime date) {
    final d = DateTime.utc(date.year, date.month, date.day);
    final dayOfYear = d.difference(DateTime.utc(d.year, 1, 1)).inDays + 1;
    final woy = (dayOfYear - d.weekday + 10) ~/ 7;
    if (woy < 1) return _isoWeeksInYear(d.year - 1);
    if (woy > _isoWeeksInYear(d.year)) return 1;
    return woy;
  }

  double _round2(double v) => double.parse(v.toStringAsFixed(2));

  // ========================================================================
  // SYMPTOMS: AVG over the bucket of (morning+afternoon+night)/3, filtered by
  // symptoms_id. Sparse map (no backfill), matching the server. fromMap x10.
  // ========================================================================

  Future<Map<String, num>> _symsAggregate(
    int symsId,
    Expression<bool> Function($SymptomMetricsTable t) filter,
    int Function(String isoDate) bucketOf,
  ) async {
    final rows = await (_db.select(_db.symptomMetrics)
          ..where((t) =>
              t.deletedAt.isNull() & t.symptomsId.equals(symsId) & filter(t)))
        .get();

    final sums = <int, double>{};
    final counts = <int, int>{};
    for (final r in rows) {
      final bucket = bucketOf(r.date);
      final severity =
          (r.morningSeverity + r.afternoonSeverity + r.nightSeverity) / 3;
      sums[bucket] = (sums[bucket] ?? 0) + severity;
      counts[bucket] = (counts[bucket] ?? 0) + 1;
    }

    final out = <String, num>{};
    sums.forEach((bucket, total) {
      out['$bucket'] = _round2(total / counts[bucket]!);
    });
    return out;
  }

  Future<Map<String, num>> syms7Days(int symsId) {
    final cutoff = _sevenDayCutoff();
    return _symsAggregate(
      symsId,
      (t) => t.date.isBiggerOrEqualValue(cutoff),
      _dowBucket,
    );
  }

  Future<Map<String, num>> symsWeek(int symsId, int month, int year) {
    final start = _monthStart(year, month);
    final end = _monthEndExclusive(year, month);
    return _symsAggregate(
      symsId,
      (t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end),
      _weekOfMonthBucket,
    );
  }

  Future<Map<String, num>> symsMonth(int symsId, int year) {
    final start = _yearStart(year);
    final end = _yearEndExclusive(year);
    return _symsAggregate(
      symsId,
      (t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end),
      _monthBucket,
    );
  }

  // ========================================================================
  // BOWEL: COUNT of rows per `type` per bucket, zero-backfilled buckets.
  // ========================================================================

  Future<Map<String, List<Map<String, dynamic>>>> _bowelAggregate(
    Expression<bool> Function($BowelMetricsTable t) filter,
    int Function(String isoDate) bucketOf,
    List<int> buckets,
  ) async {
    final rows = await (_db.select(_db.bowelMetrics)
          ..where((t) => t.deletedAt.isNull() & filter(t)))
        .get();

    // bucket -> (type -> count)
    final byBucket = <int, Map<int, int>>{};
    for (final r in rows) {
      final b = bucketOf(r.date);
      final byType = byBucket.putIfAbsent(b, () => <int, int>{});
      byType[r.type] = (byType[r.type] ?? 0) + 1;
    }

    final out = <String, List<Map<String, dynamic>>>{};
    for (final b in buckets) {
      final byType = byBucket[b] ?? const <int, int>{};
      final keys = byType.keys.toList()..sort();
      out['$b'] = keys.map((t) => {'key': t, 'value': byType[t]}).toList();
    }
    return out;
  }

  Future<Map<String, List<Map<String, dynamic>>>> bowel7Days() {
    final cutoff = _sevenDayCutoff();
    return _bowelAggregate(
      (t) => t.date.isBiggerOrEqualValue(cutoff),
      _dowBucket,
      const [0, 1, 2, 3, 4, 5, 6],
    );
  }

  Future<Map<String, List<Map<String, dynamic>>>> bowelWeek(
      int month, int year) {
    final start = _monthStart(year, month);
    final end = _monthEndExclusive(year, month);
    return _bowelAggregate(
      (t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end),
      _weekOfMonthBucket,
      const [1, 2, 3, 4, 5],
    );
  }

  Future<Map<String, List<Map<String, dynamic>>>> bowelMonth(int year) {
    final start = _yearStart(year);
    final end = _yearEndExclusive(year);
    return _bowelAggregate(
      (t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end),
      _monthBucket,
      const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    );
  }

  // ========================================================================
  // EXERCISE: SUM(no_of_times) per bucket, zero-backfilled.
  // ========================================================================

  Future<Map<String, num>> _exerciseAggregate(
    Expression<bool> Function($ExerciseMetricsTable t) filter,
    int Function(String isoDate) bucketOf,
    List<int> buckets,
  ) async {
    final rows = await (_db.select(_db.exerciseMetrics)
          ..where((t) => t.deletedAt.isNull() & filter(t)))
        .get();

    final sums = <int, int>{};
    for (final r in rows) {
      final b = bucketOf(r.date);
      sums[b] = (sums[b] ?? 0) + r.noOfTimes;
    }

    final out = <String, num>{};
    for (final b in buckets) {
      out['$b'] = sums[b] ?? 0;
    }
    return out;
  }

  Future<Map<String, num>> exercise7Days() {
    final cutoff = _sevenDayCutoff();
    return _exerciseAggregate(
      (t) => t.date.isBiggerOrEqualValue(cutoff),
      _dowBucket,
      const [0, 1, 2, 3, 4, 5, 6],
    );
  }

  Future<Map<String, num>> exerciseWeek(int month, int year) {
    final start = _monthStart(year, month);
    final end = _monthEndExclusive(year, month);
    return _exerciseAggregate(
      (t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end),
      _weekOfMonthBucket,
      const [1, 2, 3, 4, 5],
    );
  }

  Future<Map<String, num>> exerciseMonth(int year) {
    final start = _yearStart(year);
    final end = _yearEndExclusive(year);
    return _exerciseAggregate(
      (t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end),
      _monthBucket,
      const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    );
  }

  // ========================================================================
  // FOOD TAGS: flatten breakfast+lunch+dinner+snack tags, COUNT per tag per
  // bucket (optionally filtered to one tag), zero-backfilled.
  // ========================================================================

  Future<Map<String, List<Map<String, dynamic>>>> _foodAggregate(
    String? tag,
    Expression<bool> Function($FoodMetricsTable t) filter,
    int Function(String isoDate) bucketOf,
    List<int> buckets,
  ) async {
    final rows = await (_db.select(_db.foodMetrics)
          ..where((t) => t.deletedAt.isNull() & filter(t)))
        .get();

    final filterTag = (tag != null && tag.isNotEmpty) ? tag : null;

    // bucket -> (tag -> count)
    final byBucket = <int, Map<String, int>>{};
    for (final r in rows) {
      final b = bucketOf(r.date);
      final byTag = byBucket.putIfAbsent(b, () => <String, int>{});
      final tags = <String>[
        ...r.breakfastTags,
        ...r.lunchTags,
        ...r.dinnerTags,
        ...r.snackTags,
      ];
      for (final t in tags) {
        if (filterTag != null && t != filterTag) continue;
        byTag[t] = (byTag[t] ?? 0) + 1;
      }
    }

    final out = <String, List<Map<String, dynamic>>>{};
    for (final b in buckets) {
      final byTag = byBucket[b] ?? const <String, int>{};
      final keys = byTag.keys.toList()..sort();
      out['$b'] = keys.map((t) => {'key': t, 'value': byTag[t]}).toList();
    }
    return out;
  }

  Future<Map<String, List<Map<String, dynamic>>>> foodTags7Days(String? tag) {
    final cutoff = _sevenDayCutoff();
    return _foodAggregate(
      tag,
      (t) => t.date.isBiggerOrEqualValue(cutoff),
      _dowBucket,
      const [0, 1, 2, 3, 4, 5, 6],
    );
  }

  Future<Map<String, List<Map<String, dynamic>>>> foodTagsWeek(
      String? tag, int month, int year) {
    final start = _monthStart(year, month);
    final end = _monthEndExclusive(year, month);
    return _foodAggregate(
      tag,
      (t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end),
      _weekOfMonthBucket,
      const [1, 2, 3, 4, 5],
    );
  }

  Future<Map<String, List<Map<String, dynamic>>>> foodTagsMonth(
      String? tag, int year) {
    final start = _yearStart(year);
    final end = _yearEndExclusive(year);
    return _foodAggregate(
      tag,
      (t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end),
      _monthBucket,
      const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    );
  }
}
