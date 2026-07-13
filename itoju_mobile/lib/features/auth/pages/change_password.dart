import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/auth/notifiers/change_password_notifier.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/margins.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/custom_text_field.dart';
import 'package:itoju_mobile/features/widgets/validation_checks.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  /// The password-rules checklist is only shown while the new-password field
  /// is being edited (focused), so the form stays compact otherwise. Same idea
  /// for the "Passwords match" indicator under Confirm Password.
  bool _newPasswordFieldActive = false;
  bool _confirmPasswordFieldActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpaceLarge,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomBackButton(),
                  verticalSpaceMedium,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        "Change Password",
                        color: AppColors.primaryColorPurple,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpaceMedium,
              CustomTextField(
                filled: true,
                title: "Current Password",
                hintText: "8+ strong characters",
                controller: passwordController,
              ),
              10.ph,
              // Focus wraps the field so the checklist below can show only
              // while the user is actually editing the new password.
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() => _newPasswordFieldActive = hasFocus);
                },
                child: CustomTextField(
                  filled: true,
                  title: "New Password",
                  hintText: "8+ strong characters",
                  controller: newPasswordController,
                ),
              ),
              Visibility(
                visible: _newPasswordFieldActive,
                child: ValueListenableBuilder(
                    valueListenable: newPasswordController,
                    builder: (context, textEditingValue, _) {
                      final password = textEditingValue.text;
                      final hasAtLeastEightChars = password.length >= 8;
                      final hasUpperAndLowerCaseChars =
                          password.contains(RegExp('[A-Z]'));
                      final hasNumber = password.contains(RegExp('[0-9]'));
                      final hasSpecialChar =
                          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                      return PasswordValidator(
                        hasAtLeastEightChars: hasAtLeastEightChars,
                        hasUpperAndLowerCaseChars: hasUpperAndLowerCaseChars,
                        hasNumber: hasNumber,
                        hasSpecialChar: hasSpecialChar,
                      );
                    }),
              ),
              15.ph,
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() => _confirmPasswordFieldActive = hasFocus);
                },
                child: CustomTextField(
                  filled: true,
                  title: "Confirm Password",
                  hintText: "8+ strong characters",
                  controller: confirmPasswordController,
                ),
              ),
              Visibility(
                visible: _confirmPasswordFieldActive,
                child: ListenableBuilder(
                    // Merge both fields so editing either updates the match
                    // indicator live.
                    listenable: Listenable.merge([
                      newPasswordController,
                      confirmPasswordController,
                    ]),
                    builder: (context, _) {
                      final confirm = confirmPasswordController.text;
                      final matches = confirm.isNotEmpty &&
                          confirm == newPasswordController.text;
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
              20.ph,
              Consumer(builder: (context, ref, child) {
                return CurvedButton(
                  text: "Save",
                  loading: ref.watch(changePasswordNotifier).loadStatus ==
                      Loader.loading,
                  onPressed: () async {
                    if (newPasswordController.text.length < 8 ||
                        !newPasswordController.text.contains(RegExp('[A-Z]')) ||
                        !newPasswordController.text.contains(RegExp('[0-9]')) ||
                        !newPasswordController.text
                            .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                      getAlert('Passwords must met all required conditions');
                      return;
                    }

                    if (passwordController.text.isEmpty ||
                        newPasswordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      getAlert('All Password fields are required');
                      return;
                    }
                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      getAlert('Password field don\'t match');
                      return;
                    }
                    final response = await ref
                        .read(changePasswordNotifier.notifier)
                        .changePassword(
                            passwordController.text,
                            newPasswordController.text,
                            confirmPasswordController.text);
                    if (response.successMessage.isNotEmpty) {
                      if (!mounted) return;
                      getAlert(response.successMessage, isWarning: false);
                    } else if (response.responseMessage!.isNotEmpty) {
                      getAlert(response.responseMessage!);
                    } else {
                      getAlert(response.errorMessage);
                    }
                  },
                );
              }),
              20.ph,
            ],
          ),
        ),
      ),
    );
  }
}
