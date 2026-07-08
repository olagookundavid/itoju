import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/auth/notifiers/forgot_password_notifier.dart';
import 'package:itoju_mobile/features/auth/pages/create_new_password.dart';
import 'package:itoju_mobile/features/auth/widget/error_dialog.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/margins.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/custom_text_field.dart';
import 'package:itoju_mobile/features/widgets/dialog.dart';

class ResetOtp extends StatefulWidget {
  const ResetOtp({super.key});

  @override
  State<ResetOtp> createState() => _ResetOtpState();
}

class _ResetOtpState extends State<ResetOtp> {
  TextEditingController otpController = TextEditingController();
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
                      "Password Recovery",
                      color: AppColors.primaryColorPurple,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    verticalSpaceSmall,
                    CustomText(
                      "Input the OTP sent to your mail",
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
              title: "Enter OTP",
              hintText: "Enter the otp",
              controller: otpController,
            ),
            verticalSpaceMassive,
            Consumer(builder: (context, ref, child) {
              return CurvedButton(
                text: "Reset Password",
                loading: ref.watch(forgotPasswordNotifier).loadStatus ==
                    Loader.loading,
                onPressed: () async {
                  if (otpController.text.isEmpty) {
                    getAlert('OTP field is required');

                    return;
                  }
                  final response = await ref
                      .read(forgotPasswordNotifier.notifier)
                      .verifyOtp(
                        otpController.text,
                      );
                  if (!mounted) return;
                  if (response.successMessage.isNotEmpty) {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const CreateNewPassword();
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
            20.ph,
            Center(
              child: InkWell(
                onTap: () {},
                child: Text(
                  "Didn't receive the OTP, Resend",
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
            )
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
