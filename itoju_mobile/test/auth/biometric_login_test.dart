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
import 'package:itoju_mobile/features/auth/notifiers/change_password_notifier.dart';
import 'package:itoju_mobile/features/auth/notifiers/login_notifier.dart';

/// Biometric sign-in is OPT-IN. The password is only kept (in the platform
/// keystore) while the user has switched the feature on; it survives logout and
/// session expiry (that is the whole point); it is released only after a
/// biometric check; and it is wiped when the feature is switched off.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('itoju_hive').path);
    await Hive.openBox(HiveKeys.appBox);
  });

  late int loginCalls;
  late Map<String, String> lastLoginBody;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    await HiveStorage.clear();
    loginCalls = 0;
    lastLoginBody = {};
  });

  /// A fake server: [status] 200 = logs in, 401 = wrong password.
  Dio fakeServerDio({int status = 200}) {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
      loginCalls++;
      lastLoginBody = Map<String, String>.from(o.data as Map);
      if (status == 200) {
        h.resolve(Response(requestOptions: o, statusCode: 200, data: {
          'message': 'Successfully logged in User',
          'data': {'token': 'SESSION-TOKEN'},
        }));
      } else {
        h.reject(DioException(
            requestOptions: o,
            response: Response(
                requestOptions: o,
                statusCode: status,
                data: {'error': 'invalid authentication credentials'}),
            type: DioExceptionType.badResponse));
      }
    }));
    return dio;
  }

  LoginNotifier notifier(
    Dio dio, {
    String bio = 'success',
    Future<void> Function()? duringBio,
  }) {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    return container.read(
        Provider((ref) => LoginNotifier(ref, dio, biometricAuth: () async {
              await duringBio?.call();
              return bio;
            })));
  }

  Future<void> setUpEnabled() async {
    await Session.setBiometricLoginEnabled(true);
    await HiveStorage.put(HiveKeys.userName, 'a@b.com');
    await SecureStore.write(SecureKeys.password, 'secret-pass-1');
  }

  group('opt-in storage', () {
    test('by default a login keeps the token but NOT the password', () async {
      final res =
          await notifier(fakeServerDio()).login('a@b.com', 'secret-pass-1');
      expect(res.successMessage, isNotEmpty);
      expect(await SecureStore.read(SecureKeys.token), 'SESSION-TOKEN');
      expect(await SecureStore.read(SecureKeys.password), isNull);
    });

    test('with biometric login ON, a login stores the password', () async {
      await Session.setBiometricLoginEnabled(true);
      await notifier(fakeServerDio()).login('a@b.com', 'secret-pass-1');
      expect(await SecureStore.read(SecureKeys.password), 'secret-pass-1');
    });

    test('turning it OFF wipes the stored password', () async {
      await Session.setBiometricLoginEnabled(true);
      await notifier(fakeServerDio()).login('a@b.com', 'secret-pass-1');
      await Session.setBiometricLoginEnabled(false);
      expect(await SecureStore.read(SecureKeys.password), isNull);
      expect(Session.isBiometricLoginEnabled(), isFalse);
    });
  });

  group('surviving logout and expiry', () {
    test('ON: logout / 401 clears the token but keeps what biometrics needs',
        () async {
      await Session.setBiometricLoginEnabled(true);
      await notifier(fakeServerDio()).login('a@b.com', 'secret-pass-1');
      await Session.clearLocal(); // what logout and the 401 handler both call
      expect(await SecureStore.read(SecureKeys.token), isNull);
      expect(await SecureStore.read(SecureKeys.password), 'secret-pass-1');
      expect(HiveStorage.get(HiveKeys.userName), 'a@b.com');
    });

    test('OFF: logout wipes the password and the remembered email', () async {
      await HiveStorage.put(HiveKeys.userName, 'a@b.com');
      await SecureStore.write(SecureKeys.password, 'left-behind');
      await Session.clearLocal();
      expect(await SecureStore.read(SecureKeys.password), isNull);
      expect(HiveStorage.get(HiveKeys.userName), isNull);
    });

    test('startup purge removes a stray password unless the feature is on',
        () async {
      await SecureStore.write(SecureKeys.password, 'stray');
      await Session.purgeLegacySecrets();
      expect(await SecureStore.read(SecureKeys.password), isNull);

      await Session.setBiometricLoginEnabled(true);
      await SecureStore.write(SecureKeys.password, 'wanted');
      await Session.purgeLegacySecrets();
      expect(await SecureStore.read(SecureKeys.password), 'wanted');
    });
  });

  group('signing in with biometrics', () {
    test('success: logs in with the stored credentials', () async {
      await setUpEnabled();
      final res = await notifier(fakeServerDio()).loginWithBioMetric();
      expect(res.successMessage, isNotEmpty);
      expect(lastLoginBody, {'email': 'a@b.com', 'password': 'secret-pass-1'});
      expect(await SecureStore.read(SecureKeys.token), 'SESSION-TOKEN');
    });

    test('a failed/cancelled biometric check never contacts the server',
        () async {
      await setUpEnabled();
      final res = await notifier(fakeServerDio(), bio: "Couldn't use Biometric")
          .loginWithBioMetric();
      expect(res.successMessage, isEmpty);
      expect(res.errorMessage, "Couldn't use Biometric");
      expect(loginCalls, 0);
    });

    test('the stored password is read only AFTER the biometric check passes',
        () async {
      await setUpEnabled();
      // Remove the password while the biometric prompt is "on screen". If the
      // code had already read it, the login would still succeed with the old value.
      final res = await notifier(fakeServerDio(),
              duringBio: () => SecureStore.write(SecureKeys.password, null))
          .loginWithBioMetric();
      expect(res.successMessage, isEmpty,
          reason: 'password was read before the biometric check');
      expect(loginCalls, 0);
    });

    test('not enabled: refuses and does not prompt or call the server',
        () async {
      var prompted = false;
      final res = await notifier(fakeServerDio(), duringBio: () async {
        prompted = true;
      }).loginWithBioMetric();
      expect(res.successMessage, isEmpty);
      expect(res.errorMessage, contains('Settings'));
      expect(prompted, isFalse);
      expect(loginCalls, 0);
    });

    test('enabled but no saved credentials yet: explains how to finish setup',
        () async {
      await Session.setBiometricLoginEnabled(true);
      final res = await notifier(fakeServerDio()).loginWithBioMetric();
      expect(res.successMessage, isEmpty);
      expect(res.errorMessage, contains('password'));
      expect(loginCalls, 0);
    });

    test('password changed elsewhere (401): feature switches itself off',
        () async {
      await setUpEnabled();
      final res =
          await notifier(fakeServerDio(status: 401)).loginWithBioMetric();
      expect(res.successMessage, isEmpty);
      expect(res.responseMessage, contains('password'));
      expect(Session.isBiometricLoginEnabled(), isFalse);
      expect(await SecureStore.read(SecureKeys.password), isNull,
          reason: 'a stale password must not linger');
    });
  });

  group('changing the password in the app', () {
    ChangePasswordNotifier changer(Dio dio) {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
          overrides: [appDatabaseProvider.overrideWithValue(db)]);
      addTearDown(container.dispose);
      return container
          .read(Provider((ref) => ChangePasswordNotifier(ref, dio)));
    }

    Dio okDio() {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(onRequest: (o, h) {
        h.resolve(Response(
            requestOptions: o,
            statusCode: 200,
            data: {'message': 'your password was successfully changed'}));
      }));
      return dio;
    }

    test('ON: the saved password follows the change (no stale secret)',
        () async {
      await setUpEnabled();
      final res = await changer(okDio())
          .changePassword('secret-pass-1', 'brand-new-2', 'brand-new-2');
      expect(res.successMessage, isNotEmpty);
      expect(await SecureStore.read(SecureKeys.password), 'brand-new-2');
    });

    test('OFF: a password change stores nothing', () async {
      await changer(okDio())
          .changePassword('old-pass-123', 'brand-new-2', 'brand-new-2');
      expect(await SecureStore.read(SecureKeys.password), isNull);
    });
  });
}
