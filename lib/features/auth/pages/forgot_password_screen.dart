// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/auth/notifiers/forgot_password_notifier.dart';
import 'package:itoju_mobile/features/auth/pages/reset_otp_page.dart';
import 'package:itoju_mobile/features/auth/widget/error_dialog.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/margins.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/custom_text_field.dart';
import 'package:itoju_mobile/features/widgets/dialog.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
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
                      "Forgotten Password?",
                      color: AppColors.primaryColorPurple,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    verticalSpaceSmall,
                    CustomText(
                      "Enter your e-mail address for password recovery",
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
              title: "Email Address",
              hintText: "Enter your email",
              controller: emailController,
            ),
            verticalSpaceMassive,
            Consumer(builder: (context, ref, child) {
              return CurvedButton(
                text: "Send Link",
                loading: ref.watch(forgotPasswordNotifier).loadStatus ==
                    Loader.loading,
                onPressed: () async {
                  if (emailController.text.isEmpty) {
                    getAlert('Email field is required');

                    return;
                  }
                  final response = await ref
                      .read(forgotPasswordNotifier.notifier)
                      .forgotPassword(
                        emailController.text,
                      );

                  if (response.successMessage.isNotEmpty) {
                    if (!mounted) return;

                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const ResetOtp();
                        },
                      ));
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
          ],
        ),
      ),
    );
  }

  errorDialog(BuildContext context, String error) {
    return customDialog(
        context,
        ErrorDialog(
          error: error,
        ),
        dialogHeight: 250,
        dialogWidth: 400);
  }
}
