import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../ids.dart';
import '../models/exercise_model.dart';
import '../providers.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (ref) => ExerciseRepository(ref.watch(appDatabaseProvider)),
);

/// Local source of truth for exercise metrics. Every write marks the row
/// sync_state=pending and bumps local_updated_at so the SyncEngine can find it;
/// deletes are soft (tombstones). No network here — the app works fully offline.
class ExerciseRepository {
  ExerciseRepository(this._db);
  final AppDatabase _db;

  Future<List<ExerciseModel>> getForDate(String date) async {
    final rows = await (_db.select(_db.exerciseMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.localUpdatedAt, mode: OrderingMode.desc)
          ]))
        .get();
    return rows.map(_toModel).toList();
  }

  Future<void> create(String date, ExerciseModel m) async {
    final now = DateTime.now();
    await _db.into(_db.exerciseMetrics).insert(ExerciseMetricsCompanion.insert(
          id: IdMinter.v7(),
          localUpdatedAt: now,
          date: date,
          name: Value(m.name ?? ''),
          started: Value(m.started ?? ''),
          ended: Value(m.ended ?? ''),
          tags: Value(List<String>.from(m.tags ?? const [])),
          noOfTimes: Value(m.noOfTimes ?? 0),
          updatedAt: Value(now),
        ));
    await _awardPoints(date, 2, 'Exercise');
  }

  Future<void> update(ExerciseModel m) async {
    final now = DateTime.now();
    await (_db.update(_db.exerciseMetrics)..where((t) => t.id.equals(m.id!)))
        .write(
      ExerciseMetricsCompanion(
        started: Value(m.started ?? ''),
        ended: Value(m.ended ?? ''),
        tags: Value(List<String>.from(m.tags ?? const [])),
        noOfTimes: Value(m.noOfTimes ?? 0),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
  }

  Future<void> delete(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.exerciseMetrics)..where((t) => t.id.equals(id))).write(
      ExerciseMetricsCompanion(
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

  ExerciseModel _toModel(ExerciseMetric r) => ExerciseModel(
        id: r.id,
        name: r.name,
        tags: r.tags,
        noOfTimes: r.noOfTimes,
        started: r.started,
        ended: r.ended,
      );
}
