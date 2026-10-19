import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/auth/session.dart';
import 'package:itoju_mobile/data/account_service.dart';
import 'package:itoju_mobile/features/auth/pages/add_tracked_metrics.dart';
import 'package:itoju_mobile/features/auth/pages/app_lock.dart';
import 'package:itoju_mobile/features/landing/landing_page.dart';
import 'package:itoju_mobile/features/onboarding/name_step.dart';
import 'package:itoju_mobile/features/onboarding/onboardng.dart';
import 'package:itoju_mobile/features/onboarding/welcome_page.dart';

/// AuthGate is the app's entry decision point. Offline-first: the app is fully
/// usable without an account, so a session token no longer gates entry —
///  - first launch ever  -> onboarding
///  - otherwise           -> app (behind the app-lock if enabled)
/// Auth only matters later, to enable (paid) cloud sync.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Widget? _destination;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    // Mint the anonymous local account on first launch so all local data has an
    // owner and deterministic ids have a stable namespace. Best-effort only:
    // this must NEVER gate entry — the app is offline-first, and
    // localAccountId() already self-heals a broken secure store. Any failure
    // here still falls through to routing so the app always opens.
    try {
      // DB-backed instance, so a restored phone recovers its identity here.
      await ProviderScope.containerOf(context)
          .read(accountServiceProvider)
          .localAccountId();
    } catch (_) {}

    // Legacy migration: installs from before the staged flow only have the
    // firstTime boolean — a completed old-style onboarding maps to `done` so
    // existing users go straight to the app and never see the new flow.
    try {
      if (HiveStorage.get(HiveKeys.onboardingStage) == null &&
          (HiveStorage.get(HiveKeys.firstTime) as bool? ?? true) == false) {
        await OnboardingStage.set(OnboardingStage.done);
      }
    } catch (_) {}

    if (mounted) setState(() => _destination = _destinationForStage());
  }

  /// The screen to show for the current onboarding stage. Depends only on Hive
  /// (reliable), never on the network or secure storage — so it can always
  /// produce a destination and the loading spinner is never permanent.
  Widget _destinationForStage() {
    switch (OnboardingStage.current()) {
      case OnboardingStage.done:
        return Session.isAppLockEnabled()
            ? const AppLockScreen(child: LandingPage())
            : const LandingPage();
      case OnboardingStage.setup:
        return const AddTrackedMetrics();
      case OnboardingStage.name:
        return const NameStep();
      case OnboardingStage.auth:
        return const WelcomePage();
      default: // OnboardingStage.slides / unset
        return const OnBoarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _destination ??
        const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
