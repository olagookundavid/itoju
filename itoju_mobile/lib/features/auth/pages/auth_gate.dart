import 'package:flutter/material.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/auth/session.dart';
import 'package:itoju_mobile/data/account_service.dart';
import 'package:itoju_mobile/features/auth/pages/app_lock.dart';
import 'package:itoju_mobile/features/landing/landing_page.dart';
import 'package:itoju_mobile/features/onboarding/onboardng.dart';

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
    final firstTime = HiveStorage.get(HiveKeys.firstTime) as bool? ?? true;
    // Mint the anonymous local account on first launch so all local data has an
    // owner and deterministic ids have a stable namespace.
    await AccountService().localAccountId();
    Widget dest;
    if (firstTime) {
      dest = const OnBoarding();
    } else {
      dest = Session.isAppLockEnabled()
          ? const AppLockScreen(child: LandingPage())
          : const LandingPage();
    }
    if (mounted) setState(() => _destination = dest);
  }

  @override
  Widget build(BuildContext context) {
    return _destination ??
        const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
