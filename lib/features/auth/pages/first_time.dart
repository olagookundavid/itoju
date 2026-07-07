import 'package:flutter/material.dart';
import 'package:itoju_mobile/features/auth/pages/login.dart';
import 'package:itoju_mobile/features/onboarding/onboardng.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';

class FirstTimeScreen extends StatelessWidget {
  FirstTimeScreen({super.key});
  final bool firstTime = HiveStorage.get(HiveKeys.firstTime) ?? true;
  @override
  Widget build(BuildContext context) {
    return firstTime ? const OnBoarding() : const SignInPage();
  }
}
