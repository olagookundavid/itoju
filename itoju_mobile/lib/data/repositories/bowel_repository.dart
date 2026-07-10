import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../ids.dart';
import '../models/bowel_model.dart';
import '../providers.dart';

final bowelRepositoryProvider = Provider<BowelRepository>(
  (ref) => BowelRepository(ref.watch(appDatabaseProvider)),
);

/// Local source of truth for bowel metrics. Every write marks the row
/// sync_state=pending and bumps local_updated_at so the SyncEngine can find it;
/// deletes are soft (tombstones). No network here — the app works fully offline.
class BowelRepository {
  BowelRepository(this._db);
  final AppDatabase _db;

  Future<List<BowelModel>> getForDate(String date) async {
    final rows = await (_db.select(_db.bowelMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.localUpdatedAt, mode: OrderingMode.desc)
          ]))
        .get();
    return rows.map(_toModel).toList();
  }

  Future<void> create(String date, BowelModel m) async {
    final now = DateTime.now();
    await _db.into(_db.bowelMetrics).insert(BowelMetricsCompanion.insert(
          id: IdMinter.v7(),
          localUpdatedAt: now,
          date: date,
          type: Value(m.type),
          pain: Value(m.pain),
          time: Value(m.time ?? ''),
          tags: Value(List<String>.from(m.tags)),
          updatedAt: Value(now),
        ));
    await _awardPoints(date, 2, 'Bowel');
  }

  Future<void> update(BowelModel m) async {
    final now = DateTime.now();
    await (_db.update(_db.bowelMetrics)..where((t) => t.id.equals(m.id!))).write(
      BowelMetricsCompanion(
        type: Value(m.type),
        pain: Value(m.pain),
        time: Value(m.time ?? ''),
        tags: Value(List<String>.from(m.tags)),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
  }

  Future<void> delete(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.bowelMetrics)..where((t) => t.id.equals(id))).write(
      BowelMetricsCompanion(
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

  BowelModel _toModel(BowelMetric r) => BowelModel(
        id: r.id,
        time: r.time,
        tags: r.tags,
        type: r.type,
        pain: r.pain,
      );
}
