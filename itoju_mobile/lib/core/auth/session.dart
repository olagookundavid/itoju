import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:itoju_mobile/core/Storage/secure_store.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';

/// Session centralizes auth-session state: whether a token exists, the app-lock
/// preference, and clearing/tearing down a session. Kept UI-agnostic so it can
/// be used from the AuthGate, the dio 401 handler, and Settings alike.
class Session {
  /// True when a session token is present in secure storage.
  static Future<bool> hasToken() async {
    final token = await SecureStore.read(SecureKeys.token);
    return token != null && token.isNotEmpty;
  }

  /// App-lock is ON by default (health data is sensitive); users can disable it.
  static bool isAppLockEnabled() =>
      HiveStorage.get(HiveKeys.appLock) as bool? ?? true;

  static Future<void> setAppLockEnabled(bool enabled) async {
    await HiveStorage.put(HiveKeys.appLock, enabled);
  }

  /// Clears the local session material only (token + biometric password +
  /// cached username). Used both by explicit logout and the 401 bounce.
  static Future<void> clearLocal() async {
    await SecureStore.clearAuth();
    await HiveStorage.delete(HiveKeys.userName);
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
