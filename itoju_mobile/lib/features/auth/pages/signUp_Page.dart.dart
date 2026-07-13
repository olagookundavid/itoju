// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/auth/notifiers/signup_notifier.dart';
import 'package:itoju_mobile/features/auth/pages/oauth_signup.dart';
import 'package:itoju_mobile/features/auth/pages/login.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/components/asset/constants/images.dart';
import 'package:itoju_mobile/components/asset/constants/terms_and_conditions.dart';
import 'package:itoju_mobile/features/widgets/coming_soon_dialog.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/date_pick_widget.dart';
import 'package:itoju_mobile/features/widgets/dates.dart';
import 'package:itoju_mobile/features/widgets/margins.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/custom_text_field.dart';
import 'package:itoju_mobile/features/widgets/dialog.dart';
import 'package:itoju_mobile/features/widgets/my_checkBox.dart';
import 'package:itoju_mobile/features/widgets/validation_checks.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prefill the name captured during local-first onboarding.
    final localName = HiveStorage.get(HiveKeys.localName) as String?;
    if (localName != null && localName.isNotEmpty) {
      firstNameController.text = localName;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool terms = false;
  bool privacy = false;
  bool research = false;
  DateTime? dob;
  DateTime? startDate;
  DateTime? endDate;

  /// The password-rules checklist is only shown while the password field is
  /// being edited (focused), so the form stays compact otherwise. Same idea
  /// for the "Passwords match" indicator under Confirm Password.
  bool _passwordFieldActive = false;
  bool _confirmPasswordFieldActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            50.ph,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                20.ph,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "Create your account",
                      color: AppColors.primaryColorPurple,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    verticalSpaceSmall,
                    CustomText(
                      "Join us by Signing Up using",
                      color: AppColors.hintGrey,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ],
            ),
            25.ph,
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _signUpFormKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        filled: true,
                        title: "First Name",
                        hintText: "Your Name",
                        controller: firstNameController,
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
                        title: "Last Name",
                        hintText: "Surname",
                        controller: lastNameController,
                        valdator: (value) {
                          if (value!.isEmpty) {
                            return "Field cannot be empty";
                          }
                          return null;
                        },
                      ),
                      verticalSpaceTiny,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            "Date of Birth",
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColorPurple,
                          ),
                          10.ph,
                          DatePickWidget(
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              ).then((value) {
                                setState(() {});
                                if (value != null) {
                                  dob = value;
                                }
                              });
                            },
                            title: dob != null
                                ? DateFormatter.format(dob.toString())
                                : "Enter date",
                          ),
                        ],
                      ),
                      20.ph,
                      CustomTextField(
                        filled: true,
                        title: "Email Address",
                        hintText: "Enter Email",
                        controller: emailController,
                        valdator: (value) {
                          if (value!.isEmpty) {
                            return "Field cannot be empty";
                          }
                          return null;
                        },
                      ),
                      verticalSpaceTiny,
                      // Focus wraps the field so the checklist below can show
                      // only while the user is actually editing the password.
                      Focus(
                        onFocusChange: (hasFocus) {
                          setState(() => _passwordFieldActive = hasFocus);
                        },
                        child: CustomTextField(
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
                      ),
                      Visibility(
                        visible: _passwordFieldActive,
                        child: ValueListenableBuilder(
                            valueListenable: passwordController,
                            builder: (context, textEditingValue, _) {
                              final password = textEditingValue.text;
                              final hasAtLeastEightChars = password.length >= 8;
                              final hasUpperAndLowerCaseChars =
                                  password.contains(RegExp('[A-Z]'));
                              final hasNumber =
                                  password.contains(RegExp('[0-9]'));
                              final hasSpecialChar = password
                                  .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                              return PasswordValidator(
                                hasAtLeastEightChars: hasAtLeastEightChars,
                                hasUpperAndLowerCaseChars:
                                    hasUpperAndLowerCaseChars,
                                hasNumber: hasNumber,
                                hasSpecialChar: hasSpecialChar,
                              );
                            }),
                      ),
                      25.ph,
                      Focus(
                        onFocusChange: (hasFocus) {
                          setState(
                              () => _confirmPasswordFieldActive = hasFocus);
                        },
                        child: CustomTextField(
                          filled: true,
                          title: "Confirm Password",
                          hintText: "8+ strong characters",
                          obscure: true,
                          controller: confirmPasswordController,
                          valdator: (value) {
                            if (value != passwordController.text) {
                              return "Password does not match";
                            }
                            if (value!.isEmpty) {
                              return "Field cannot be empty";
                            }
                            return null;
                          },
                        ),
                      ),
                      Visibility(
                        visible: _confirmPasswordFieldActive,
                        child: ListenableBuilder(
                            // Merge both fields so editing either updates the
                            // match indicator live.
                            listenable: Listenable.merge([
                              passwordController,
                              confirmPasswordController,
                            ]),
                            builder: (context, _) {
                              final confirm = confirmPasswordController.text;
                              final matches = confirm.isNotEmpty &&
                                  confirm == passwordController.text;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  10.ph,
                                  PasswordConditionIndicator(
                                    isValid: matches,
                                    title: 'Passwords match',
                                  ),
                                ],
                              );
                            }),
                      ),
                      verticalSpaceTiny,
                      MyCeckBox(
                        term: "I agree to the ",
                        linkText: "Terms and Conditions",
                        onTap: () {
                          termsDialog(
                            context,
                          );
                        },
                        onChanged: (bool? value) {
                          setState(() {
                            terms = value!;
                          });
                        },
                        isChecked: terms,
                      ),
                      MyCeckBox(
                        term: "I agree to the",
                        linkText: " Privacy policy",
                        onTap: () {
                          termsDialog(
                            context,
                          );
                        },
                        onChanged: (bool? value) {
                          setState(() {
                            privacy = value!;
                          });
                        },
                        isChecked: privacy,
                      ),
                      SpecialCustomCheckBox(
                        firstTerm: "while\n",
                        firstlinkText: " Research Purposes ",
                        secondTerm: "understanding my rights and ",
                        secondLinkText: "How My Data Is Being Used",
                        firstLink: () {
                          termsDialog(
                            context,
                          );
                        },
                        lastLink: () {
                          termsDialog(
                            context,
                          );
                        },
                        onChanged: (bool? value) {
                          setState(() {
                            research = value!;
                          });
                        },
                        isChecked: research,
                      ),
                      verticalSpaceMedium,
                      Consumer(builder: (context, ref, child) {
                        final state = ref.watch(registerProvider);
                        return CurvedButton(
                          color: (!terms || !privacy)
                              ? Colors.grey
                              : AppColors.primaryColorPurple,
                          loading: state.loadStatus == Loader.loading,
                          text: 'Confirm',
                          onPressed: () async {
                            if (passwordController.text.length < 8 ||
                                !passwordController.text
                                    .contains(RegExp('[A-Z]')) ||
                                !passwordController.text
                                    .contains(RegExp('[0-9]')) ||
                                !passwordController.text.contains(
                                    RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                              getAlert(
                                  'Passwords must met all required conditions');

                              return;
                            }

                            if (!terms || !privacy) {
                              return;
                            }
                            if (passwordController.text !=
                                    confirmPasswordController.text ||
                                passwordController.text.isEmpty) {
                              getAlert(
                                  'Passwords must match and can\'t be empty');

                              return;
                            }
                            if (passwordController.text.isEmpty ||
                                confirmPasswordController.text.isEmpty ||
                                emailController.text.isEmpty ||
                                lastNameController.text.isEmpty ||
                                firstNameController.text.isEmpty ||
                                dob == null) {
                              getAlert('All fields are required');

                              return;
                            }

                            final response = await ref
                                .read(registerProvider.notifier)
                                .register(
                                    firstNameController.text,
                                    lastNameController.text,
                                    emailController.text,
                                    dob!,
                                    passwordController.text);

                            if (response.successMessage.isNotEmpty) {
                              if (!mounted) return;
                              getAlert(response.successMessage,
                                  isWarning: false);

                              Timer(const Duration(seconds: 1), () {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    return SignUpSuccess(
                                      () {
                                        // Registration doesn't start a session
                                        // yet, so log in next — but keep the
                                        // stack so back still works.
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return const SignInPage();
                                            },
                                          ),
                                        );
                                      },
                                      name: response.data,
                                    );
                                  },
                                );
                              });
                            } else if (response.responseMessage!.isNotEmpty) {
                              getAlert(response.responseMessage!);
                            } else {
                              getAlert(response.errorMessage);
                            }
                          },
                        );
                      }),
                      verticalSpaceSmall,
                      CustomText(
                        "Or Sign Up using your",
                        fontSize: 12.h,
                        textAlign: TextAlign.center,
                        color: AppColors.primaryColorPurple,
                        fontWeight: FontWeight.w400,
                      ),
                      verticalSpaceSmall,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () async {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return const OauthSignUpPage(
                                      auth: Oauth.Google,
                                    );
                                  },
                                ));
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
                              onTap: () =>
                                  showComingSoonDialog(context, 'Facebook'),
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
                              onTap: () =>
                                  showComingSoonDialog(context, 'Apple'),
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
                            "Already have an account? ",
                            fontSize: 12.h,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primaryColorPurple,
                          ),
                          InkWell(
                            onTap: () {
                              // Swap for the login page, keeping WelcomePage
                              // beneath during onboarding so back works.
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignInPage()),
                              );
                            },
                            child: CustomText(
                              " Log In",
                              fontSize: 13.h,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColorPurple,
                            ),
                          ),
                        ],
                      ),
                      100.ph
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  termsDialog(BuildContext context) {
    return customDialog(context, const Terms());
  }
}

class Terms extends StatelessWidget {
  const Terms({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpaceMedium,
          const CustomText(
            "Terms and Conditions",
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColorPurple,
          ),
          const CustomText(
            "Last updated: 21st Feb 2024",
            fontSize: 14,
            color: AppColors.primaryColorPurple,
          ),
          verticalSpaceMedium,
          Expanded(
            child: ListView(
              children: [
                const CustomText(
                  TERMS_AND_CONDITIONS,
                  color: AppColors.primaryColorPurple,
                  fontSize: 14,
                ),
                verticalSpaceMedium,
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SignUpSuccess extends StatelessWidget {
  final VoidCallback? onTap;
  final String name;
  const SignUpSuccess(this.onTap, {Key? key, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final authModel = Provider.of<AuthViewModel>(context);
    return AlertDialog(
      insetPadding: EdgeInsets.all(20.sp),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      content: SizedBox(
        height: 350.h,
        width: 1000.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Images.success),
            verticalSpaceSmall,
            CustomText(
              "Congratulations",
              fontSize: 20.sp,
              color: AppColors.primaryColorPurple,
              fontWeight: FontWeight.w600,
            ),
            10.ph,
            Text(
              name,
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColorPurple),
            ),
            10.ph,
            CustomText(
              "Account created successfully",
              fontSize: 12.sp,
              color: AppColors.hintGrey,
              fontWeight: FontWeight.w600,
            ),
            verticalSpaceMedium,
            CustomButton(
              onPressed: () {
                Navigator.pop(context);
                onTap!();
              },
              buttonStyle: buttonStyle(buttonWidth: 160.w, radius: 10),
              child: CustomText(
                "Get Started",
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
