import 'package:flutter/services.dart';
import 'package:itoju_mobile/core/helpers/logger.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return canCheck && isSupported;
    } on PlatformException {
      return false;
    }
  }

  static Future<List<BiometricType>> getBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  static Future<String> authenticate() async {
    final isAvailable = await hasBiometrics();
    if (isAvailable) {
      try {
        return await _auth.authenticate(
                localizedReason: "Scan Fingerprint or Face ID to authenticate",
                options: const AuthenticationOptions(stickyAuth: true))
            ? "success"
            : "Couldn't use Biometric";
      } catch (e) {
        debugLog(e.toString());
        return "Couldn't use Biometric";
      }
    } else {
      return "Your device doesn't support Biometric";
    }
  }

  /// Unlock the app. Unlike [authenticate], this allows the device passcode as
  /// a fallback (biometricOnly: false), so users without/with failing biometrics
  /// can still get in. Returns true on success.
  static Future<bool> unlockApp() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) {
        // No device credential set up at all — don't hard-lock the user out.
        return true;
      }
      return await _auth.authenticate(
        localizedReason: 'Unlock Itoju to continue',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allow PIN/passcode fallback
        ),
      );
    } catch (e) {
      debugLog(e.toString());
      return false;
    }
  }

  static Future<bool> hasFingerprint() async {
    final biometrics = await LocalAuthApi.getBiometrics();
    if (biometrics.isNotEmpty) {
      for (var item in biometrics) {
        return biometrics.contains(item);
      }
    }
    return false;
  }
}
