import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/auth/notifiers/forgot_password_notifier.dart';
import 'package:itoju_mobile/features/auth/pages/login.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/margins.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/custom_text_field.dart';

class CreateNewPassword extends StatefulWidget {
  const CreateNewPassword({super.key});

  @override
  State<CreateNewPassword> createState() => _CreateNewPasswordState();
}

class _CreateNewPasswordState extends State<CreateNewPassword> {
  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();
  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
                      "Create New Password",
                      color: AppColors.primaryColorPurple,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    verticalSpaceSmall,
                    CustomText(
                      "Create a strong password",
                      color: AppColors.hintGrey,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ],
            ),
            verticalSpaceMedium,
            CustomTextField(
              filled: true,
              title: "New Password",
              hintText: "8+ strong characters",
              controller: passwordController,
            ),
            30.ph,
            CustomTextField(
              filled: true,
              title: "Confirm Password",
              hintText: "8+ strong characters",
              controller: confirmPasswordController,
            ),
            20.ph,
            Consumer(builder: (context, ref, child) {
              return CurvedButton(
                text: "Save",
                loading: ref.watch(forgotPasswordNotifier).loadStatus ==
                    Loader.loading,
                onPressed: () async {
                  if (passwordController.text.isEmpty) {
                    getAlert('Password field is required');

                    return;
                  }
                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    getAlert('Password field don\'t match');

                    return;
                  }
                  final response = await ref
                      .read(forgotPasswordNotifier.notifier)
                      .resetPassword(
                        passwordController.text,
                      );
                  if (response.successMessage.isNotEmpty) {
                    if (!mounted) return;
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const SignInPage();
                          },
                        ),
                        (route) => false,
                      );
                      getAlert(response.successMessage, isWarning: false);
                    });
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
    );
  }
}
