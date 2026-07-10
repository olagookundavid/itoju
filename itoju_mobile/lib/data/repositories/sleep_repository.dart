import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../ids.dart';
import '../models/sleep_model.dart';
import '../providers.dart';

final sleepRepositoryProvider = Provider<SleepRepository>(
  (ref) => SleepRepository(ref.watch(appDatabaseProvider)),
);

/// Local source of truth for sleep metrics. Every write marks the row
/// sync_state=pending and bumps local_updated_at so the SyncEngine can find it;
/// deletes are soft (tombstones). No network here — the app works fully offline.
class SleepRepository {
  SleepRepository(this._db);
  final AppDatabase _db;

  Future<List<SleepModel>> getForDate(String date) async {
    final rows = await (_db.select(_db.sleepMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.localUpdatedAt, mode: OrderingMode.desc)
          ]))
        .get();
    return rows.map(_toModel).toList();
  }

  Future<void> create(String date, SleepModel m) async {
    final now = DateTime.now();
    await _db.into(_db.sleepMetrics).insert(SleepMetricsCompanion.insert(
          id: IdMinter.v7(),
          localUpdatedAt: now,
          date: date,
          isNight: m.isNight ?? false,
          timeSlept: Value(m.timeSlept ?? ''),
          timeWokeUp: Value(m.timeWokeUp ?? ''),
          tags: Value(List<String>.from(m.tags)),
          severity: Value(m.severity),
          updatedAt: Value(now),
        ));
    await _awardPoints(date, 2, 'Sleep');
  }

  Future<void> update(SleepModel m) async {
    final now = DateTime.now();
    await (_db.update(_db.sleepMetrics)..where((t) => t.id.equals(m.id!)))
        .write(
      SleepMetricsCompanion(
        timeSlept: Value(m.timeSlept ?? ''),
        timeWokeUp: Value(m.timeWokeUp ?? ''),
        tags: Value(List<String>.from(m.tags)),
        severity: Value(m.severity),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
  }

  Future<void> delete(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.sleepMetrics)..where((t) => t.id.equals(id))).write(
      SleepMetricsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
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

  SleepModel _toModel(SleepMetric r) => SleepModel(
        id: r.id,
        timeSlept: r.timeSlept,
        timeWokeUp: r.timeWokeUp,
        tags: r.tags,
        severity: r.severity,
        isNight: r.isNight,
      );
}
