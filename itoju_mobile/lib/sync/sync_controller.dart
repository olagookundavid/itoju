import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/Storage/storage_class.dart';
import 'sync_engine.dart';
import 'sync_schedule.dart';

/// SyncController sits above the SyncEngine and applies the user's chosen sync
/// cadence. It owns the (Hive-backed) prefs — cadence, daily hour, last-synced
/// time — so the engine itself stays dependency-light and unit-testable.
class SyncController {
  SyncController(this._ref);
  final Ref _ref;

  static const _defaultCadence = SyncSchedule.daily;
  static const _defaultDailyHour = 17; // 5 PM

  String get cadence =>
      (HiveStorage.get(HiveKeys.syncCadence) as String?) ?? _defaultCadence;

  int get dailyHour =>
      (HiveStorage.get(HiveKeys.syncDailyHour) as int?) ?? _defaultDailyHour;

  DateTime? get lastSyncAt {
    final s = HiveStorage.get(HiveKeys.lastSyncAt) as String?;
    return s == null ? null : DateTime.tryParse(s);
  }

  Future<void> setCadence(String value) async {
    await HiveStorage.put(HiveKeys.syncCadence, value);
  }

  Future<void> setDailyHour(int hour) async {
    await HiveStorage.put(HiveKeys.syncDailyHour, hour);
  }

  /// Run a sync now regardless of cadence (the manual "Back up now" action and
  /// the first-sign-in flush). Returns whether it actually synced (false when
  /// not signed in / not entitled); stamps lastSyncAt on success.
  Future<bool> backupNow() async {
    final did = await _ref.read(syncEngineProvider).syncNow();
    if (did) {
      await HiveStorage.put(
          HiveKeys.lastSyncAt, DateTime.now().toIso8601String());
    }
    return did;
  }

  /// Called from the app-open / resume / connectivity-regained triggers. Runs a
  /// sync only when the configured cadence says one is due.
  Future<void> maybePeriodicSync() async {
    if (!SyncSchedule.isDue(DateTime.now(), lastSyncAt, cadence, dailyHour)) {
      return;
    }
    await backupNow();
  }
}

final syncControllerProvider =
    Provider<SyncController>((ref) => SyncController(ref));
