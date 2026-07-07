import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SecureStore keeps sensitive auth material (session token, and the password
/// used for biometric quick-login) in the platform Keychain/Keystore instead of
/// the unencrypted Hive box. Everything here is OS-encrypted at rest.
class SecureStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Future<String?> read(String key) => _storage.read(key: key);

  static Future<void> write(String key, String? value) async {
    if (value == null) {
      await _storage.delete(key: key);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  static Future<void> delete(String key) => _storage.delete(key: key);

  /// Clears all auth material — call on logout.
  static Future<void> clearAuth() async {
    await _storage.delete(key: SecureKeys.token);
    await _storage.delete(key: SecureKeys.password);
  }
}

class SecureKeys {
  static const token = 'token';
  static const password = 'password';
}
