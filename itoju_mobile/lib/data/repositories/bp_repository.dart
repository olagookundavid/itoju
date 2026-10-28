import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../blood_pressure.dart';
import '../db/app_database.dart';
import '../ids.dart';
import '../limits.dart';
import '../models/bp_model.dart';
import '../providers.dart';

final bpRepositoryProvider = Provider<BpRepository>(
  (ref) => BpRepository(ref.watch(appDatabaseProvider)),
);

/// Local source of truth for blood-pressure readings. Like the other list
/// metrics: every write marks the row pending and bumps local_updated_at for the
/// SyncEngine, deletes are soft, and there is no network here.
class BpRepository {
  BpRepository(this._db);
  final AppDatabase _db;

  static final _day = DateFormat('yyyy-MM-dd');

  Future<List<BpModel>> getForDate(String date) async {
    final rows = await (_db.select(_db.bpMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.time)]))
        .get();
    return rows.map(_toModel).toList();
  }

  /// The most recent live reading (by date, then time), or null if none.
  Future<BpModel?> latest() async {
    final row = await (_db.select(_db.bpMetrics)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.time),
          ])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Per-day averages for the trend chart over the inclusive range [from, to].
  /// Days with no reading are simply absent. Sorted by date.
  Future<List<BpDayPoint>> dailyAverages(DateTime from, DateTime to) async {
    final rows = await (_db.select(_db.bpMetrics)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(_day.format(from)) &
              t.date.isSmallerOrEqualValue(_day.format(to)) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
    final byDay = <String, List<BpMetric>>{};
    for (final r in rows) {
      byDay.putIfAbsent(r.date, () => []).add(r);
    }
    double avg(List<BpMetric> l, int Function(BpMetric) f) =>
        l.fold<int>(0, (s, r) => s + f(r)) / l.length;
    return [
      for (final e in byDay.entries)
        BpDayPoint(
          date: e.key,
          systolic: avg(e.value, (r) => r.systolic),
          diastolic: avg(e.value, (r) => r.diastolic),
          pulse: avg(e.value, (r) => r.pulse),
          readings: e.value.length,
        ),
    ];
  }

  /// Throws [ArgumentError] (message is user-facing) for an implausible reading.
  Future<void> create(String date, BpModel m) async {
    _check(m);
    final now = DateTime.now();
    await _db.into(_db.bpMetrics).insert(BpMetricsCompanion.insert(
          id: IdMinter.v7(),
          localUpdatedAt: now,
          date: date,
          time: Value(clipText(m.time, kMaxShortText)),
          systolic: m.systolic,
          diastolic: m.diastolic,
          pulse: Value(m.pulse),
          updatedAt: Value(now),
        ));
    await _awardPoints(date, 2, 'BloodPressure');
  }

  Future<void> update(BpModel m) async {
    _check(m);
    final now = DateTime.now();
    await (_db.update(_db.bpMetrics)..where((t) => t.id.equals(m.id!))).write(
      BpMetricsCompanion(
        time: Value(clipText(m.time, kMaxShortText)),
        systolic: Value(m.systolic),
        diastolic: Value(m.diastolic),
        pulse: Value(m.pulse),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
  }

  Future<void> delete(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.bpMetrics)..where((t) => t.id.equals(id))).write(
      BpMetricsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
  }

  void _check(BpModel m) {
    final problem = validateBp(
        systolic: m.systolic, diastolic: m.diastolic, pulse: m.pulse);
    if (problem != null) throw ArgumentError(problem);
  }

  Future<void> _awardPoints(String date, int points, String scope) async {
    await _db.into(_db.pointRecords).insert(PointRecordsCompanion.insert(
          id: IdMinter.v7(),
          localUpdatedAt: DateTime.now(),
          point: points,
          scope: scope,
          date: date,
        ));
  }

  BpModel _toModel(BpMetric r) => BpModel(
        id: r.id,
        date: r.date,
        time: r.time,
        systolic: r.systolic,
        diastolic: r.diastolic,
        pulse: r.pulse,
      );
}
