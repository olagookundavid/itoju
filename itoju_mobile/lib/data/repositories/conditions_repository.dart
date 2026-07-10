import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../account_service.dart';
import '../db/app_database.dart';
import '../ids.dart';
import '../models/conditions_model.dart';
import '../providers.dart';

final conditionsRepositoryProvider = Provider<ConditionsRepository>(
  (ref) => ConditionsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(accountServiceProvider),
  ),
);

/// Condition selections are one-per-condition: each selection row's id is a
/// deterministic UUIDv5 of (account, conditionId), so add/remove is idempotent —
/// re-adding revives the same tombstoned row rather than duplicating. Mirrors
/// the backend's selection semantics.
class ConditionsRepository {
  ConditionsRepository(this._db, this._account);
  final AppDatabase _db;
  final AccountService _account;

  /// The seeded conditions catalog (replaces the old `allconditions` API).
  Future<List<GetConditionsModel>> getCatalog() async {
    final rows = await (_db.select(_db.conditions)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
    return rows.map((r) => GetConditionsModel(id: r.id, name: r.name)).toList();
  }

  /// The user's live (non-deleted) selections, joined to the catalog for names.
  Future<List<GetConditionsModel>> getSelected() async {
    final query = _db.select(_db.userConditions).join([
      innerJoin(
        _db.conditions,
        _db.conditions.id.equalsExp(_db.userConditions.conditionId),
      ),
    ])
      ..where(_db.userConditions.deletedAt.isNull());
    final rows = await query.get();
    return rows.map((r) {
      final c = r.readTable(_db.conditions);
      return GetConditionsModel(id: c.id, name: c.name);
    }).toList();
  }

  /// Select a condition (idempotent): upsert its deterministic row, reviving any
  /// tombstone and marking it pending for sync.
  Future<void> add(int conditionId) async {
    final account = await _account.deterministicNamespaceId();
    final id = IdMinter.condition(account, conditionId);
    final now = DateTime.now();
    await _db.into(_db.userConditions).insertOnConflictUpdate(
          UserConditionsCompanion.insert(
            id: id,
            localUpdatedAt: now,
            conditionId: conditionId,
            updatedAt: Value(now),
            deletedAt: const Value(null),
            syncState: const Value('pending'),
          ),
        );
  }

  /// Deselect a condition: soft-delete its deterministic row.
  Future<void> remove(int conditionId) async {
    final account = await _account.deterministicNamespaceId();
    final id = IdMinter.condition(account, conditionId);
    final now = DateTime.now();
    await (_db.update(_db.userConditions)..where((t) => t.id.equals(id)))
        .write(UserConditionsCompanion(
      deletedAt: Value(now),
      updatedAt: Value(now),
      localUpdatedAt: Value(now),
      syncState: const Value('pending'),
    ));
  }
}
