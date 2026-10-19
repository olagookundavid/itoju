import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../db/app_database.dart';
import '../ids.dart';
import '../providers.dart';

final pointsRepositoryProvider = Provider<PointsRepository>(
  (ref) => PointsRepository(ref.watch(appDatabaseProvider)),
);

/// Local source of truth for the points display. Point rows are written by the
/// metric repositories on create (scope + point + date); here we only read and
/// aggregate them, mirroring the backend's points totals.
class PointsRepository {
  PointsRepository(this._db);
  final AppDatabase _db;

  /// Returns a stream of PointModel that updates whenever the pointRecords table changes.
  Stream<PointModel> watchPoints() {
    return _db.select(_db.pointRecords).watch().asyncMap((_) => getPoints());
  }

  /// Metric tables that earn points, with the scope their award is recorded
  /// under and the per-day amount. Mirrors what each repository's `_awardPoints`
  /// does on create, so a backfilled day looks like a live-awarded one.
  static const _backfillScopes = <({String scope, String table, int points})>[
    (scope: 'Symptoms', table: 'symptom_metrics', points: 10),
    (scope: 'Bowel', table: 'bowel_metrics', points: 2),
    (scope: 'Food', table: 'food_metrics', points: 2),
    (scope: 'Exercise', table: 'exercise_metrics', points: 2),
    (scope: 'Sleep', table: 'sleep_metrics', points: 2),
    (scope: 'Urine', table: 'urine_metrics', points: 2),
    (scope: 'Medication', table: 'medication_metrics', points: 2),
  ];

  Future<void>? _backfillInFlight;

  /// Makes sure registration points (10 pts) exist and that every logged day has
  /// at least one point record for its metric type (e.g. data logged before
  /// points existed, or restored from cloud sync — point records don't sync).
  ///
  /// Safe to call from several places at once: concurrent callers share one run
  /// (the notifier's constructor and the dashboard both fire at startup, and
  /// interleaved runs used to insert the registration award twice). Idempotent —
  /// a day that already has any live record for its scope is left alone, so
  /// multiple same-day entries (each awards its own record) are fine.
  Future<void> ensureBackfill() {
    return _backfillInFlight ??= _runBackfill().whenComplete(() {
      _backfillInFlight = null;
    });
  }

  Future<void> _runBackfill() => _db.transaction(() async {
        final fmt = DateFormat('yyyy-MM-dd');
        final now = DateTime.now();

        final register = await (_db.select(_db.pointRecords)
              ..where((t) => t.scope.equals('Register') & t.deletedAt.isNull())
              ..limit(1))
            .get();
        if (register.isEmpty) {
          await _db.into(_db.pointRecords).insert(PointRecordsCompanion.insert(
                id: IdMinter.v7(),
                localUpdatedAt: now,
                point: 10,
                scope: 'Register',
                date: fmt.format(now),
              ));
        }

        // One query per metric type: distinct live days with no live award yet.
        for (final s in _backfillScopes) {
          final rows = await _db.customSelect(
            'SELECT DISTINCT m.date AS date FROM ${s.table} m '
            'WHERE m.deleted_at IS NULL AND NOT EXISTS ('
            'SELECT 1 FROM point_records p '
            'WHERE p.scope = ?1 AND p.date = m.date AND p.deleted_at IS NULL)',
            variables: [Variable<String>(s.scope)],
          ).get();
          for (final r in rows) {
            await _db.into(_db.pointRecords).insert(PointRecordsCompanion.insert(
                  id: IdMinter.v7(),
                  localUpdatedAt: now,
                  point: s.points,
                  scope: s.scope,
                  date: r.read<String>('date'),
                ));
          }
        }
      });

  /// total = SUM(point) over live rows; today = SUM where date == today;
  /// thisWeek = SUM where date >= Monday. Dates are ISO 'yyyy-MM-dd' so string
  /// comparison sorts correctly.
  Future<PointModel> getPoints() async {
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');
    final todayStr = fmt.format(now);
    final mondayStr = fmt.format(now.subtract(Duration(days: now.weekday - 1)));

    final sum = _db.pointRecords.point.sum();

    Future<int> sumWhere(Expression<bool> extra) async {
      final q = _db.selectOnly(_db.pointRecords)
        ..addColumns([sum])
        ..where(_db.pointRecords.deletedAt.isNull() & extra);
      return (await q.getSingle()).read(sum) ?? 0;
    }

    final total = await sumWhere(const Constant(true));
    final today = await sumWhere(_db.pointRecords.date.equals(todayStr));
    final week =
        await sumWhere(_db.pointRecords.date.isBiggerOrEqualValue(mondayStr));

    return PointModel(total, today, week);
  }
}

class PointModel {
  final int totalPts;
  final int todayPts;
  final int weekPts;

  PointModel(this.totalPts, this.todayPts, this.weekPts);
}
