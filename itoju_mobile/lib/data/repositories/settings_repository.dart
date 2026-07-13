import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../account_service.dart';
import '../db/app_database.dart';
import '../ids.dart';
import '../models/settings_model.dart';
import '../providers.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(accountServiceProvider),
  ),
);

/// The single per-account settings row (cycle/period lengths + body measurements).
/// Reads default to zeros before anything is set, matching the old API shape.
class SettingsRepository {
  SettingsRepository(this._db, this._account);
  final AppDatabase _db;
  final AccountService _account;

  Future<MensesModel> getMenses() async {
    final r = await _row();
    return MensesModel(periodLen: r?.periodLen ?? 0, cycleLen: r?.cycleLen ?? 0);
  }

  Future<void> updateMenses(int periodLen, int cycleLen) =>
      _upsert(periodLen: periodLen, cycleLen: cycleLen);

  Future<BodyDataModel> getBodyData() async {
    final r = await _row();
    return BodyDataModel(height: r?.height ?? 0, weight: r?.weight ?? 0);
  }

  Future<void> updateBodyData(int height, int weight) =>
      _upsert(height: height, weight: weight);

  Future<UserSetting?> _row() async {
    final id = IdMinter.settings(await _account.deterministicNamespaceId());
    // limit(1) guards the sign-in binding window, where the settings row can
    // transiently exist under both the old and new account namespace ids.
    return (_db.select(_db.userSettings)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> _upsert(
      {int? periodLen, int? cycleLen, int? height, int? weight}) async {
    final id = IdMinter.settings(await _account.deterministicNamespaceId());
    final now = DateTime.now();
    final existing =
        await (_db.select(_db.userSettings)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
    if (existing == null) {
      await _db.into(_db.userSettings).insert(UserSettingsCompanion.insert(
            id: id,
            localUpdatedAt: now,
            periodLen: Value(periodLen ?? 0),
            cycleLen: Value(cycleLen ?? 0),
            height: Value(height ?? 0),
            weight: Value(weight ?? 0),
            updatedAt: Value(now),
          ));
    } else {
      await (_db.update(_db.userSettings)..where((t) => t.id.equals(id))).write(
        UserSettingsCompanion(
          periodLen: periodLen != null ? Value(periodLen) : const Value.absent(),
          cycleLen: cycleLen != null ? Value(cycleLen) : const Value.absent(),
          height: height != null ? Value(height) : const Value.absent(),
          weight: weight != null ? Value(weight) : const Value.absent(),
          updatedAt: Value(now),
          localUpdatedAt: Value(now),
          syncState: const Value('pending'),
        ),
      );
    }
  }
}
