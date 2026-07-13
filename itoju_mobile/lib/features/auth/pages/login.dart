// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/auth/notifiers/login_notifier.dart';
import 'package:itoju_mobile/features/auth/widgets/account_switch_dialog.dart';
import 'package:itoju_mobile/features/auth/pages/forgot_password_screen.dart';
import 'package:itoju_mobile/features/auth/pages/signUp_Page.dart.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/landing/landing_page.dart';
import 'package:itoju_mobile/features/onboarding/name_step.dart';
import 'package:itoju_mobile/features/widgets/coming_soon_dialog.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/margins.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/Storage/secure_store.dart';
import 'package:itoju_mobile/features/widgets/click_text.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/custom_text_field.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  /// Finishes a successful sign-in. When the signed-in account differs from the
  /// one this device's health data is bound to, the user must choose: erase the
  /// previous account's local data and continue, or cancel the sign-in. Without
  /// this, two people's health records could mix on a shared device.
  Future<void> _completeLogin(dynamic response) async {
    final data = response.data;
    final switchPending = data is Map && data['accountSwitch'] == true;
    if (switchPending) {
      final erased = await showAccountSwitchDialog(context, ref);
      if (!erased) {
        // Cancel: the helper already dropped the new session; nothing changed.
        getAlert('Sign-in cancelled — nothing was changed');
        return;
      }
    }
    if (!mounted) return;
    // Signing in DURING onboarding continues to the name step (prefilled from
    // the account); signing in later (e.g. Settings → sync) goes to the app.
    if (!OnboardingStage.isDone) {
      await OnboardingStage.set(OnboardingStage.name);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const NameStep()),
        (route) => false,
      );
    } else {
      pushScreen(
        context,
        screen: const LandingPage(),
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    }
    // The first sync after sign-in downloads the account's history in the
    // background — say so, or returning users see screens quietly filling in.
    getAlert(
        'Signed in! Downloading your data in the background — '
        'your history will appear shortly.',
        isWarning: false);
  }

  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool firstObscure = true;
  bool? rememberMe;
  bool showBiometrics = HiveStorage.get(HiveKeys.showBiometrics) ?? false;

  @override
  void initState() {
    super.initState();
    rememberMe = HiveStorage.get(HiveKeys.rememberMe);
    _loadStoredCredentials();
  }

  Future<void> _loadStoredCredentials() async {
    // Password lives in the OS-encrypted secure store now, so load it async.
    password = await SecureStore.read(SecureKeys.password) ?? '';
    if ((rememberMe ?? false) && mounted) {
      emailController.text = initialEmail;
      passwordController.text = password;
      setState(() {});
    }
  }

  String initialEmail = HiveStorage.get(HiveKeys.userName) ?? '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final model = ref.read(loginNotifier.notifier);
    final status = ref.watch(loginNotifier);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Form(
          key: _signInFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                verticalSpaceLarge,
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalSpaceMedium,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              "Welcome back",
                              color: AppColors.primaryColorPurple,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            verticalSpaceSmall,
                            const CustomText(
                              "Log into your account using",
                              color: AppColors.textGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                verticalSpaceLarge,
                CustomTextField(
                  filled: true,
                  title: "Email Address",
                  hintText: "Enter your email",
                  controller: emailController,
                  valdator: (value) {
                    if (value!.isEmpty) {
                      return "Field cannot be empty";
                    }
                    return null;
                  },
                ),
                verticalSpaceTiny,
                CustomTextField(
                  filled: true,
                  title: "Password",
                  hintText: "8+ strong characters",
                  obscure: true,
                  controller: passwordController,
                  valdator: (value) {
                    if (value!.isEmpty) {
                      return "Field cannot be empty";
                    }
                    return null;
                  },
                ),
                verticalSpaceTiny,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClickText(
                      "Forgot Password",
                      fontSize: 13.sp,
                      fontWeight: 400,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return const ForgotPassword();
                          },
                        ));
                      },
                    ),
                    const Spacer(),
                    Checkbox.adaptive(
                      // checkColor: AppColors.primaryColorPurple,
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return AppColors.primaryColorPurple.withOpacity(.25);
                        }
                        return Colors.white;
                      }),
                      side: const BorderSide(
                          width: .4, color: AppColors.primaryColorPurple),
                      value: rememberMe ?? false,
                      onChanged: (value) {
                        HiveStorage.put(HiveKeys.rememberMe, value);
                        rememberMe = value ?? false;
                        setState(() {});
                      },
                      activeColor: AppColors.primaryColorPurple,
                    ),
                    Text(
                      'Remember me',
                      style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                verticalSpaceMedium,
                Consumer(builder: (context, ref, child) {
                  return CurvedButton(
                    text: 'Login',
                    loading: status.loadStatus == Loader.loading,
                    onPressed: () async {
                      if (emailController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        getAlert('Email and Password must not be empty');

                        return;
                      }
                      final response = await model.login(
                          emailController.text, passwordController.text);

                      if (response.successMessage.isNotEmpty) {
                        await _completeLogin(response);
                      } else if (response.responseMessage!.isNotEmpty) {
                        getAlert(response.responseMessage!);
                      } else {
                        getAlert(response.errorMessage);
                      }
                    },
                  );
                }),
                30.ph,
                Center(
                    child: InkWell(
                  onTap: () async {
                    if (!showBiometrics) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Biometrics not enabled',
                                style: TextStyle(fontSize: 20.sp)),
                            content: Text(
                              'You have to login and enable Biometrics Authentication.',
                              style: TextStyle(fontSize: 15.sp),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'OK',
                                  style: TextStyle(fontSize: 15.sp),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }
                    final response =
                        await model.loginWithBioMetric(initialEmail, password);
                    if (response.successMessage.isNotEmpty) {
                      await _completeLogin(response);
                    } else if (response.responseMessage!.isNotEmpty) {
                      getAlert(response.responseMessage!);
                    } else {
                      getAlert(response.errorMessage);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fingerprint,
                        size: 25.r,
                      ),
                      Text(
                        'Login With Biometrics',
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey),
                      ),
                    ],
                  ),
                )),
                20.ph,
                CustomText(
                  "Or Login using your",
                  fontSize: 13.sp,
                  textAlign: TextAlign.center,
                  color: AppColors.primaryColorPurple,
                  fontWeight: FontWeight.w500,
                ),
                verticalSpaceSmall,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          final response = await ref
                              .read(loginNotifier.notifier)
                              .signInWithGoogle();
                          if (response.successMessage.isNotEmpty) {
                            await _completeLogin(response);
                          } else if (response.responseMessage!.isNotEmpty) {
                            getAlert(response.responseMessage!);
                          } else {
                            getAlert(response.errorMessage);
                          }
                        },
                        child: Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white),
                          child: Image.asset(
                            "asset/png/Google.png",
                            height: 30.h,
                            width: 20.w,
                          ),
                        ),
                      ),
                      horizontalSpaceMedium,
                      InkWell(
                        onTap: () => showComingSoonDialog(context, 'Facebook'),
                        child: Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white),
                          child: Image.asset(
                            "asset/png/Facebook.png",
                            height: 30.h,
                            width: 20.w,
                          ),
                        ),
                      ),
                      horizontalSpaceMedium,
                      InkWell(
                        onTap: () => showComingSoonDialog(context, 'Apple'),
                        child: Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black),
                          child: const Center(
                            child: Icon(
                              Icons.apple,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      "Don't have an account? ",
                      fontSize: 13.h,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryColorPurple,
                    ),
                    InkWell(
                      onTap: () {
                        // Swap this page for sign-up, keeping whatever is
                        // beneath (WelcomePage during onboarding, Settings
                        // later) so back still works.
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpPage()),
                        );
                      },
                      child: CustomText(
                        " Sign Up",
                        fontSize: 13.h,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColorPurple,
                      ),
                    ),
                    verticalSpaceLarge,
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
