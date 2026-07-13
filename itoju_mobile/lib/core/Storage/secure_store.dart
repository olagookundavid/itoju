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

  /// Wipes EVERY secure key (token, biometric password, local account id, and
  /// the device→account binding). Used by the factory reset that backs both
  /// "Erase data" and "Delete account".
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

class SecureKeys {
  static const token = 'token';
  static const password = 'password';

  /// Anonymous local account id (UUIDv4), minted on first launch. Owns all local
  /// data and is the namespace for deterministic ids until cloud sync binds this
  /// device to a server user.
  static const localAccountId = 'local_account_id';

  /// Server user id this device is bound to once cloud sync is enabled.
  static const boundServerUserId = 'bound_server_user_id';

  /// Server user id of the CURRENT session's token (written on every login).
  /// When it differs from [boundServerUserId], a different person signed in on
  /// this device — sync is refused until the switch is resolved (keep-or-erase)
  /// so two users' health data can never mix.
  static const currentServerUserId = 'current_server_user_id';
}
