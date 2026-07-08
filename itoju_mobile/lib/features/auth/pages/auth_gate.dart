import 'package:flutter/material.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/auth/session.dart';
import 'package:itoju_mobile/features/auth/pages/app_lock.dart';
import 'package:itoju_mobile/features/auth/pages/login.dart';
import 'package:itoju_mobile/features/landing/landing_page.dart';
import 'package:itoju_mobile/features/onboarding/onboardng.dart';

/// AuthGate is the app's entry decision point:
///  - first launch ever            -> onboarding
///  - has a valid session token     -> app (behind the app-lock if enabled)
///  - otherwise                     -> sign in
///
/// This is what lets a still-valid token skip the login screen entirely.
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
    Widget dest;
    if (firstTime) {
      dest = const OnBoarding();
    } else if (await Session.hasToken()) {
      dest = Session.isAppLockEnabled()
          ? const AppLockScreen(child: LandingPage())
          : const LandingPage();
    } else {
      dest = const SignInPage();
    }
    if (mounted) setState(() => _destination = dest);
  }

  @override
  Widget build(BuildContext context) {
    return _destination ??
        const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
