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
    // Ordered + limit 1 rather than getSingleOrNull: during the sign-in binding
    // window a duplicate row for the same date can transiently exist (old vs
    // new account namespace id) until the re-key merges them — the read must
    // show the newest edit, not throw.
    final row = await (_db.select(_db.foodMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Partial merge, NOT a blind overwrite: each meal-section widget (Meal,
  /// Snack, Water) only ever passes the fields it owns and leaves every other
  /// field `null` on [m] — that `null` means "untouched", not "clear this".
  /// So a missing field always falls back to the existing row's value; only
  /// an explicit (non-null) value — including an explicitly emptied string or
  /// tag list — overwrites it. Without this, saving e.g. Water would wipe out
  /// Breakfast/Lunch/Dinner/Snack for the day back to blank.
  Future<void> upsert(String date, FoodMetricModel m) async {
    final account = await _account.deterministicNamespaceId();
    final id = IdMinter.food(account, date);
    final now = DateTime.now();
    final existing = await getForDate(date);

    await _db.into(_db.foodMetrics).insertOnConflictUpdate(
          FoodMetricsCompanion.insert(
            id: id,
            localUpdatedAt: now,
            date: date,
            breakfastMeal:
                Value(m.breakfastMeal ?? existing?.breakfastMeal ?? ''),
            lunchMeal: Value(m.lunchMeal ?? existing?.lunchMeal ?? ''),
            dinnerMeal: Value(m.dinnerMeal ?? existing?.dinnerMeal ?? ''),
            breakfastExtra:
                Value(m.breakfastExtra ?? existing?.breakfastExtra ?? ''),
            lunchExtra: Value(m.lunchExtra ?? existing?.lunchExtra ?? ''),
            dinnerExtra: Value(m.dinnerExtra ?? existing?.dinnerExtra ?? ''),
            breakfastFruit:
                Value(m.breakfastFruit ?? existing?.breakfastFruit ?? ''),
            lunchFruit: Value(m.lunchFruit ?? existing?.lunchFruit ?? ''),
            dinnerFruit: Value(m.dinnerFruit ?? existing?.dinnerFruit ?? ''),
            breakfastTags:
                Value(_strList(m.breakfastTags ?? existing?.breakfastTags)),
            lunchTags: Value(_strList(m.lunchTags ?? existing?.lunchTags)),
            dinnerTags: Value(_strList(m.dinnerTags ?? existing?.dinnerTags)),
            snackName: Value(m.snackName ?? existing?.snackName ?? ''),
            snackTags: Value(_strList(m.snackTags ?? existing?.snackTags)),
            glassNo: Value(m.glassNo ?? existing?.glassNo ?? 0),
            updatedAt: Value(now),
            deletedAt: const Value(null),
            syncState: const Value('pending'),
          ),
        );

    if (existing == null) {
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
