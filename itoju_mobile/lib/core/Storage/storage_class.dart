import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  static final box = Hive.box(HiveKeys.appBox);

  static FutureOr<dynamic> put(dynamic key, dynamic value) async {
    return await box.put(key, value);
  }

  static dynamic get(String key) {
    return box.get(key);
  }

  static dynamic getAt(int key) {
    return box.getAt(key);
  }

  static Future<int> add(value) async {
    return await box.add(value);
  }

  static Future<int> clear() async {
    return await box.clear();
  }

  static Future<void> delete(value) async {
    return await box.delete(value);
  }

  static Future<void> putAll(Map<String, dynamic> entries) async {
    return await box.putAll(entries);
  }
}

class HiveKeys {
  static const appBox = 'appBox';
  static const token = 'token';
  static const userName = 'username';
  static const firstTime = 'firstTime';
  static const setMetrics = 'setMetrics';
  static const hideBal = 'hideBal';
  static const rememberMe = 'rememberMe';
  static const showBiometrics = 'biometrics';
  static const password = 'password';
  static const weightMetric = 'weightMetric';
  static const heightMetric = 'heightMetric';
  static const appLock = 'appLock';

  /// Local-first onboarding: the name the user gave before creating any account.
  /// Used to greet them and to prefill sign-up when they later enable sync.
  static const localName = 'localName';

  /// Cloud-sync cadence prefs (catch-up-on-open scheduling).
  static const syncCadence = 'syncCadence'; // off | daily | weekly | monthly
  static const syncDailyHour = 'syncDailyHour'; // hour-of-day for daily (0-23)
  static const lastSyncAt = 'lastSyncAt'; // ISO-8601 of last successful sync
}
