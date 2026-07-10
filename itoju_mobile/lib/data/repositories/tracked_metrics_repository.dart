import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../account_service.dart';
import '../db/app_database.dart';
import '../ids.dart';
import '../models/tracked_metrics_model.dart';
import '../providers.dart';

final trackedMetricsRepositoryProvider = Provider<TrackedMetricsRepository>(
  (ref) => TrackedMetricsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(accountServiceProvider),
  ),
);

/// Tracked-metric selections are one-per-metric: each selection row's id is a
/// deterministic UUIDv5 of (account, metricId), so add/remove is idempotent —
/// re-adding revives the same tombstoned row rather than duplicating. Mirrors
/// the backend's selection semantics.
class TrackedMetricsRepository {
  TrackedMetricsRepository(this._db, this._account);
  final AppDatabase _db;
  final AccountService _account;

  /// The seeded tracked-metrics catalog (replaces the old `allmetrics` API).
  Future<List<MetricModel>> getCatalog() async {
    final rows = await (_db.select(_db.trackedMetricsCatalog)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
    return rows.map((r) => MetricModel(id: r.id, name: r.name)).toList();
  }

  /// The user's live (non-deleted) selections, joined to the catalog for names.
  Future<List<MetricModel>> getSelected() async {
    final query = _db.select(_db.userTrackedMetrics).join([
      innerJoin(
        _db.trackedMetricsCatalog,
        _db.trackedMetricsCatalog.id
            .equalsExp(_db.userTrackedMetrics.metricId),
      ),
    ])
      ..where(_db.userTrackedMetrics.deletedAt.isNull());
    final rows = await query.get();
    return rows.map((r) {
      final c = r.readTable(_db.trackedMetricsCatalog);
      return MetricModel(id: c.id, name: c.name);
    }).toList();
  }

  /// Select a metric (idempotent): upsert its deterministic row, reviving any
  /// tombstone and marking it pending for sync.
  Future<void> add(int metricId) async {
    final account = await _account.deterministicNamespaceId();
    final id = IdMinter.trackedMetric(account, metricId);
    final now = DateTime.now();
    await _db.into(_db.userTrackedMetrics).insertOnConflictUpdate(
          UserTrackedMetricsCompanion.insert(
            id: id,
            localUpdatedAt: now,
            metricId: metricId,
            grantedAt: now,
            updatedAt: Value(now),
            deletedAt: const Value(null),
            syncState: const Value('pending'),
          ),
        );
  }

  /// Deselect a metric: soft-delete its deterministic row.
  Future<void> remove(int metricId) async {
    final account = await _account.deterministicNamespaceId();
    final id = IdMinter.trackedMetric(account, metricId);
    final now = DateTime.now();
    await (_db.update(_db.userTrackedMetrics)..where((t) => t.id.equals(id)))
        .write(UserTrackedMetricsCompanion(
      deletedAt: Value(now),
      updatedAt: Value(now),
      localUpdatedAt: Value(now),
      syncState: const Value('pending'),
    ));
  }
}
