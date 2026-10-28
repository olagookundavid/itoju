import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../account_service.dart';
import '../body_units.dart';
import '../db/app_database.dart';
import '../limits.dart';
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
    return MensesModel(
        periodLen: r?.periodLen ?? 0, cycleLen: r?.cycleLen ?? 0);
  }

  Future<void> updateMenses(int periodLen, int cycleLen) => _upsert(
      periodLen: periodLen.clamp(0, kMaxPeriodLength),
      cycleLen: cycleLen.clamp(0, kMaxCycleLength));

  Future<BodyDataModel> getBodyData() async {
    final r = await _row();
    return BodyDataModel(
        heightCm: r?.heightCm ?? 0, weightKg: r?.weightKg ?? 0);
  }

  Future<void> updateBodyData(double heightCm, double weightKg) => _upsert(
      heightCm: clampBody(heightCm, kMaxHeightCm),
      weightKg: clampBody(weightKg, kMaxWeightKg));

  static const _unitsMigratedKey = 'bodyUnitsMigrated';

  /// One-time fix-up after the 1.1 -> 1.2 database upgrade. Older builds stored a
  /// whole number in whatever unit the toggle was on (inches, pounds) and kept
  /// the unit only in Hive; the upgrade copied those numbers into the cm / kg
  /// columns unconverted. Converts them now that the unit is known. Runs once per
  /// install (flag in SyncMeta) and only touches a row that still holds the raw
  /// copy, so a value already corrected or re-entered is never converted twice.
  Future<void> migrateLegacyBodyUnits(
      {required String? heightUnit, required String? weightUnit}) async {
    final done = await (_db.select(_db.syncMeta)
          ..where((t) => t.key.equals(_unitsMigratedKey)))
        .getSingleOrNull();
    if (done != null) return;

    // The device keeps one settings row; read it directly rather than by account
    // id, which can differ transiently while a sign-in re-keys the account.
    final r = await (_db.select(_db.userSettings)
          ..where((t) => t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    if (r != null && (r.height != 0 || r.weight != 0)) {
      final rawHeightCopy = r.heightCm == r.height.toDouble();
      final rawWeightCopy = r.weightKg == r.weight.toDouble();
      final newHeight = (rawHeightCopy && isFeetInches(heightUnit))
          ? legacyInchesToCm(r.height)
          : null;
      final newWeight = (rawWeightCopy && isPounds(weightUnit))
          ? lbToKg(r.weight.toDouble())
          : null;
      if (newHeight != null || newWeight != null) {
        final now = DateTime.now();
        await (_db.update(_db.userSettings)..where((t) => t.id.equals(r.id)))
            .write(
          UserSettingsCompanion(
            heightCm:
                newHeight != null ? Value(newHeight) : const Value.absent(),
            weightKg:
                newWeight != null ? Value(newWeight) : const Value.absent(),
            updatedAt: Value(now),
            localUpdatedAt: Value(now),
            syncState: const Value('pending'),
          ),
        );
      }
    }
    await _db.into(_db.syncMeta).insertOnConflictUpdate(
        SyncMetaCompanion.insert(
            key: _unitsMigratedKey, value: const Value('1')));
  }

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
      {int? periodLen,
      int? cycleLen,
      double? heightCm,
      double? weightKg}) async {
    final id = IdMinter.settings(await _account.deterministicNamespaceId());
    final now = DateTime.now();
    final existing = await (_db.select(_db.userSettings)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) {
      await _db.into(_db.userSettings).insert(UserSettingsCompanion.insert(
            id: id,
            localUpdatedAt: now,
            periodLen: Value(periodLen ?? 0),
            cycleLen: Value(cycleLen ?? 0),
            heightCm: Value(heightCm ?? 0),
            weightKg: Value(weightKg ?? 0),
            updatedAt: Value(now),
          ));
    } else {
      await (_db.update(_db.userSettings)..where((t) => t.id.equals(id))).write(
        UserSettingsCompanion(
          periodLen:
              periodLen != null ? Value(periodLen) : const Value.absent(),
          cycleLen: cycleLen != null ? Value(cycleLen) : const Value.absent(),
          heightCm: heightCm != null ? Value(heightCm) : const Value.absent(),
          weightKg: weightKg != null ? Value(weightKg) : const Value.absent(),
          updatedAt: Value(now),
          localUpdatedAt: Value(now),
          syncState: const Value('pending'),
        ),
      );
    }
  }
}
