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

  /// Whether the user has opted in to signing in with biometrics. OFF by
  /// default. While ON, the password (and email) are kept in the platform
  /// keystore so a fingerprint/face check can sign them back in.
  static bool isBiometricLoginEnabled() =>
      HiveStorage.get(HiveKeys.showBiometrics) == true;

  /// Switches biometric sign-in on or off. Turning it OFF deletes the stored
  /// password immediately. (Turning it ON stores nothing by itself: the password
  /// is saved by the next successful password login, which Settings performs as
  /// part of enabling.)
  static Future<void> setBiometricLoginEnabled(bool enabled) async {
    await HiveStorage.put(HiveKeys.showBiometrics, enabled);
    if (!enabled) {
      try {
        await SecureStore.delete(SecureKeys.password);
      } catch (_) {}
    }
  }

  /// Clears the local session (token + cached profile). Used both by explicit
  /// logout and the 401 bounce. If biometric sign-in is ON the stored password
  /// and email are kept — being able to sign back in after logout or expiry is
  /// exactly what that feature is for.
  static Future<void> clearLocal() async {
    final keep = isBiometricLoginEnabled();
    await SecureStore.clearAuth(keepPassword: keep);
    if (!keep) await HiveStorage.delete(HiveKeys.userName);
    await HiveStorage.delete(HiveKeys.profileCache);
  }

  /// Startup hygiene: a password may only be stored while biometric sign-in is
  /// on. Older versions kept one for every user; this removes any such stray copy.
  /// Never throws.
  static Future<void> purgeLegacySecrets() async {
    try {
      if (!isBiometricLoginEnabled()) {
        await SecureStore.delete(SecureKeys.password);
      }
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
