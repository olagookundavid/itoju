import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/Storage/secure_store.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/auth/session.dart';
import 'package:itoju_mobile/data/providers.dart';
import 'package:itoju_mobile/features/auth/notifiers/profile_notifier.dart';
import 'package:itoju_mobile/features/auth/pages/auth_gate.dart';
import 'package:itoju_mobile/features/dashboard/notifiers/getSmiley_notifier.dart';
import 'package:itoju_mobile/features/dashboard/notifiers/get_most_tracked_syms_notifier.dart';
import 'package:itoju_mobile/features/home/notifer/getTrackedMetrics_notifier.dart';
import 'package:itoju_mobile/features/profile/notifiers/resources_notifiers.dart';
import 'package:itoju_mobile/features/settings/notifier/points_notifier.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

/// Resets the app to a pristine, first-launch state on THIS device.
///
/// Revokes the server session (best-effort), signs out the Firebase/Google
/// providers, wipes all local health data (keeping only seeded catalogs), all
/// secure auth material (token, biometric password, local account id, and the
/// device→account binding), and every Hive pref (onboarding stage, cached
/// names, app-lock, sync prefs). Then routes to the [AuthGate] so a fresh
/// anonymous account is minted and onboarding starts from scratch.
///
/// Cloud backups are NOT deleted here. Shared by Settings → "Erase data" and,
/// after the server account is deleted, Settings → "Delete account".
Future<void> resetToFactory(WidgetRef ref, BuildContext context) async {
  // 1. Best-effort server session revoke + provider sign-out.
  try {
    if (await Session.hasToken()) {
      await ref.read(dioProvider).post('logout');
    }
  } catch (_) {
    // Offline or already-invalid token — local teardown below still applies.
  }
  await Session.signOutProviders();

  // 2. Wipe all local user data (keeps seeded catalogs).
  await ref.read(appDatabaseProvider).eraseAllUserData();

  // 3. Wipe secure auth material (token, password, local id, binding).
  await SecureStore.clearAll();

  // 4. Wipe Hive prefs (onboarding stage, names, app-lock, sync prefs — all).
  await HiveStorage.clear();

  // 5. Drop cached provider state so nothing from the erased account survives
  //    into the fresh app (some of these are long-lived, non-autoDispose
  //    notifiers that would otherwise still hold the previous user's data).
  ref.invalidate(profileProvider);
  ref.invalidate(pointProvider);
  ref.invalidate(getSmileyProvider);
  ref.invalidate(getTrackedSymsProvider);
  ref.invalidate(resourcesProvider);
  ref.invalidate(getUserMetricsProvider);

  // 6. Fresh start at the app root — the AuthGate mints a new anonymous account
  //    and routes onboarding from scratch.
  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const AuthGate()),
    (route) => false,
  );
}
