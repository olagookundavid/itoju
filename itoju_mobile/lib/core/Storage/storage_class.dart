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

  /// Where the user is in the first-launch flow. Written BEFORE navigating to
  /// the next step, so killing the app mid-flow always resumes at the right
  /// screen — the dashboard is reachable only once this is [OnboardingStage.done].
  /// (Supersedes the old boolean [firstTime], which is kept for migration.)
  static const onboardingStage = 'onboardingStage';

  /// Cached copy of the public resources list (JSON). Resources are free for
  /// everyone — even offline/anonymous users — so the last-fetched list is
  /// kept locally and refreshed whenever the app is online.
  static const resourcesCache = 'resourcesCache';

  /// Cached copy of the signed-in user's profile (JSON map). Lets profile
  /// screens and greetings render offline instead of showing null/blank;
  /// refreshed on every successful profile fetch, cleared on logout.
  static const profileCache = 'profileCache';

  /// The user's chosen avatar index (1-based, matches asset/avatars/N.png).
  /// Saved locally first so anonymous/offline users can pick an avatar without
  /// an authenticated server round-trip; pushed to the server best-effort when
  /// signed in.
  static const avatarPicNo = 'avatarPicNo';

  /// Cloud-sync cadence prefs (catch-up-on-open scheduling).
  static const syncCadence = 'syncCadence'; // off | daily | weekly | monthly
  static const syncDailyHour = 'syncDailyHour'; // hour-of-day for daily (0-23)
  static const lastSyncAt = 'lastSyncAt'; // ISO-8601 of last successful sync
}

/// Values of [HiveKeys.onboardingStage] — the resumable first-launch flow:
/// slides → auth choice → name step → setup (track metrics + conditions) → done.
class OnboardingStage {
  static const slides = 'slides'; // (or unset) still on the intro slides
  static const auth = 'auth'; // choosing sign up / log in / no account
  static const name = 'name'; // on the "What should we call you?" step
  // Name entered; now choosing what to track + diagnosed conditions. The
  // dashboard is reachable ONLY at [done], so a kill mid-setup resumes here.
  static const setup = 'setup';
  static const done = 'done'; // flow complete — app routes to the dashboard

  static String current() =>
      (HiveStorage.get(HiveKeys.onboardingStage) as String?) ?? slides;

  static Future<void> set(String stage) =>
      Future.value(HiveStorage.put(HiveKeys.onboardingStage, stage));

  static bool get isDone => current() == done;
}
