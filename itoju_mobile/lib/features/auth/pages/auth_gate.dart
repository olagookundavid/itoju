import 'package:flutter/material.dart';
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
    // owner and deterministic ids have a stable namespace.
    await AccountService().localAccountId();

    // Legacy migration: installs from before the staged flow only have the
    // firstTime boolean — a completed old-style onboarding maps to `done` so
    // existing users go straight to the app and never see the new flow.
    if (HiveStorage.get(HiveKeys.onboardingStage) == null &&
        (HiveStorage.get(HiveKeys.firstTime) as bool? ?? true) == false) {
      await OnboardingStage.set(OnboardingStage.done);
    }

    // Route by stage: the dashboard is reachable ONLY once the flow completed,
    // so killing the app mid-onboarding resumes at the exact step.
    final Widget dest;
    switch (OnboardingStage.current()) {
      case OnboardingStage.done:
        dest = Session.isAppLockEnabled()
            ? const AppLockScreen(child: LandingPage())
            : const LandingPage();
      case OnboardingStage.setup:
        dest = const AddTrackedMetrics();
      case OnboardingStage.name:
        dest = const NameStep();
      case OnboardingStage.auth:
        dest = const WelcomePage();
      default: // OnboardingStage.slides / unset
        dest = const OnBoarding();
    }
    if (mounted) setState(() => _destination = dest);
  }

  @override
  Widget build(BuildContext context) {
    return _destination ??
        const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
