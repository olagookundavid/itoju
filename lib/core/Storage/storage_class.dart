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
}
