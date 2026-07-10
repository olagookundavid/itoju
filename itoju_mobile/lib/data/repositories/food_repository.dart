import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../account_service.dart';
import '../db/app_database.dart';
import '../ids.dart';
import '../models/food_model.dart';
import '../providers.dart';

final foodRepositoryProvider = Provider<FoodRepository>(
  (ref) => FoodRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(accountServiceProvider),
  ),
);

/// Food is one-per-day: its id is a deterministic UUIDv5 of (account, date), so
/// "set today's food" always upserts the same physical row (reviving a tombstone
/// if the day was cleared). Mirrors the backend's food upsert semantics.
class FoodRepository {
  FoodRepository(this._db, this._account);
  final AppDatabase _db;
  final AccountService _account;

  Future<FoodMetricModel?> getForDate(String date) async {
    final row = await (_db.select(_db.foodMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  Future<void> upsert(String date, FoodMetricModel m) async {
    final account = await _account.deterministicNamespaceId();
    final id = IdMinter.food(account, date);
    final now = DateTime.now();
    final existed = await getForDate(date) != null;

    await _db.into(_db.foodMetrics).insertOnConflictUpdate(
          FoodMetricsCompanion.insert(
            id: id,
            localUpdatedAt: now,
            date: date,
            breakfastMeal: Value(m.breakfastMeal ?? ''),
            lunchMeal: Value(m.lunchMeal ?? ''),
            dinnerMeal: Value(m.dinnerMeal ?? ''),
            breakfastExtra: Value(m.breakfastExtra ?? ''),
            lunchExtra: Value(m.lunchExtra ?? ''),
            dinnerExtra: Value(m.dinnerExtra ?? ''),
            breakfastFruit: Value(m.breakfastFruit ?? ''),
            lunchFruit: Value(m.lunchFruit ?? ''),
            dinnerFruit: Value(m.dinnerFruit ?? ''),
            breakfastTags: Value(_strList(m.breakfastTags)),
            lunchTags: Value(_strList(m.lunchTags)),
            dinnerTags: Value(_strList(m.dinnerTags)),
            snackName: Value(m.snackName ?? ''),
            snackTags: Value(_strList(m.snackTags)),
            glassNo: Value(m.glassNo ?? 0),
            updatedAt: Value(now),
            deletedAt: const Value(null),
            syncState: const Value('pending'),
          ),
        );

    if (!existed) {
      await _db.into(_db.pointRecords).insert(PointRecordsCompanion.insert(
            id: IdMinter.v7(),
            localUpdatedAt: now,
            point: 2,
            scope: 'Food',
            date: date,
          ));
    }
  }

  List<String> _strList(List? v) => v == null ? const [] : List<String>.from(v);

  FoodMetricModel _toModel(FoodMetric r) => FoodMetricModel(
        id: r.id,
        breakfastMeal: r.breakfastMeal,
        lunchMeal: r.lunchMeal,
        dinnerMeal: r.dinnerMeal,
        breakfastExtra: r.breakfastExtra,
        lunchExtra: r.lunchExtra,
        dinnerExtra: r.dinnerExtra,
        breakfastFruit: r.breakfastFruit,
        lunchFruit: r.lunchFruit,
        dinnerFruit: r.dinnerFruit,
        snackName: r.snackName,
        breakfastTags: r.breakfastTags,
        lunchTags: r.lunchTags,
        dinnerTags: r.dinnerTags,
        snackTags: r.snackTags,
        glassNo: r.glassNo,
      );
}
