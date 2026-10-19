import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:itoju_mobile/core/Storage/secure_store.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/auth/session.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/providers.dart';
import 'package:itoju_mobile/features/auth/notifiers/login_notifier.dart';

/// The app used to keep the user's plaintext password in secure storage so a
/// "biometric login" could replay it. A password copy on the device is a liability
/// for no benefit (sessions last 90 days; the app lock already uses biometrics),
/// so it is never stored, and any copy from an older install is purged.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('itoju_hive').path);
    await Hive.openBox(HiveKeys.appBox);
  });
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  Dio fakeServerDio() {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      h.resolve(Response(
        requestOptions: o,
        statusCode: 200,
        data: {
          'message': 'Successfully logged in User',
          'data': {'token': 'SESSION-TOKEN'},
        },
      ));
    }));
    return dio;
  }

  test('a successful login stores the session token but never the password',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    final notifier = container.read(
        Provider((ref) => LoginNotifier(ref, fakeServerDio())));

    final res = await notifier.login('a@b.com', 'my-secret-password');

    expect(res.successMessage, isNotEmpty);
    expect(await SecureStore.read(SecureKeys.token), 'SESSION-TOKEN');
    expect(await SecureStore.read(SecureKeys.password), isNull);
  });

  test('a password left by an older install is purged on startup', () async {
    FlutterSecureStorage.setMockInitialValues({
      'password': 'legacy-plaintext',
      'token': 'keep-me',
    });
    await HiveStorage.put(HiveKeys.showBiometrics, true);

    await Session.purgeLegacySecrets();

    expect(await SecureStore.read(SecureKeys.password), isNull);
    expect(HiveStorage.get(HiveKeys.showBiometrics), isNull);
    expect(await SecureStore.read(SecureKeys.token), 'keep-me',
        reason: 'only the password is removed, not the session');
  });
}
