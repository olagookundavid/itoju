import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:itoju_mobile/core/Storage/secure_store.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';

/// Session centralizes auth-session state: whether a token exists, the app-lock
/// preference, and clearing/tearing down a session. Kept UI-agnostic so it can
/// be used from the AuthGate, the dio 401 handler, and Settings alike.
class Session {
  /// True when a session token is present in secure storage.
  ///
  /// Never throws: a secure-storage read can fail (e.g. an undecryptable store
  /// after a reinstall). Many call sites gate sync/UI on this, so a failure
  /// must read as "no token" (signed out) rather than crashing the flow.
  static Future<bool> hasToken() async {
    try {
      final token = await SecureStore.read(SecureKeys.token);
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// App-lock is ON by default (health data is sensitive); users can disable it.
  static bool isAppLockEnabled() =>
      HiveStorage.get(HiveKeys.appLock) as bool? ?? true;

  static Future<void> setAppLockEnabled(bool enabled) async {
    await HiveStorage.put(HiveKeys.appLock, enabled);
  }

  /// Clears the local session material only (token + biometric password +
  /// cached username + cached profile). Used both by explicit logout and the
  /// 401 bounce.
  static Future<void> clearLocal() async {
    await SecureStore.clearAuth();
    await HiveStorage.delete(HiveKeys.userName);
    await HiveStorage.delete(HiveKeys.profileCache);
  }

  /// Removes secrets that older versions kept on the device. The app used to
  /// store the user's plaintext password (for a biometric "re-login"); it no
  /// longer stores one, and this clears any copy left by an earlier install.
  /// Never throws.
  static Future<void> purgeLegacySecrets() async {
    try {
      await SecureStore.delete(SecureKeys.password);
    } catch (_) {}
    try {
      await HiveStorage.delete(HiveKeys.showBiometrics);
    } catch (_) {}
  }

  /// Best-effort sign-out of the Firebase/Google provider sessions.
  static Future<void> signOutProviders() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (_) {
      // Not signed in via a provider — nothing to clear.
    }
  }
}
