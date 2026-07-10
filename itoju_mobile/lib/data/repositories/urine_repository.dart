import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../ids.dart';
import '../models/urine_model.dart';
import '../providers.dart';

final urineRepositoryProvider = Provider<UrineRepository>(
  (ref) => UrineRepository(ref.watch(appDatabaseProvider)),
);

/// Local source of truth for urine metrics. Every write marks the row
/// sync_state=pending and bumps local_updated_at so the SyncEngine can find it;
/// deletes are soft (tombstones). No network here — the app works fully offline.
class UrineRepository {
  UrineRepository(this._db);
  final AppDatabase _db;

  Future<List<UrineModel>> getForDate(String date) async {
    final rows = await (_db.select(_db.urineMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.localUpdatedAt, mode: OrderingMode.desc)
          ]))
        .get();
    return rows.map(_toModel).toList();
  }

  Future<void> create(String date, UrineModel m) async {
    final now = DateTime.now();
    await _db.into(_db.urineMetrics).insert(UrineMetricsCompanion.insert(
          id: IdMinter.v7(),
          localUpdatedAt: now,
          date: date,
          type: Value(m.type),
          pain: Value(m.pain),
          time: Value(m.time ?? ''),
          tags: Value(List<String>.from(m.tags)),
          quantity: Value(m.quantity),
          updatedAt: Value(now),
        ));
    await _awardPoints(date, 2, 'Urine');
  }

  Future<void> update(UrineModel m) async {
    final now = DateTime.now();
    await (_db.update(_db.urineMetrics)..where((t) => t.id.equals(m.id!))).write(
      UrineMetricsCompanion(
        type: Value(m.type),
        pain: Value(m.pain),
        time: Value(m.time ?? ''),
        tags: Value(List<String>.from(m.tags)),
        quantity: Value(m.quantity),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
  }

  Future<void> delete(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.urineMetrics)..where((t) => t.id.equals(id))).write(
      UrineMetricsCompanion(
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

  UrineModel _toModel(UrineMetric r) => UrineModel(
        id: r.id,
        time: r.time,
        tags: r.tags,
        type: r.type,
        pain: r.pain,
        quantity: r.quantity,
      );
}
