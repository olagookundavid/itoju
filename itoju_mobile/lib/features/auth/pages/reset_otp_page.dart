import 'dart:async';

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

class ResetOtp extends ConsumerStatefulWidget {
  const ResetOtp({super.key});

  @override
  ConsumerState<ResetOtp> createState() => _ResetOtpState();
}

class _ResetOtpState extends ConsumerState<ResetOtp> {
  TextEditingController otpController = TextEditingController();

  /// The server ignores a new code request within 60 s of the last one (and
  /// says nothing, so it can't be used to spam an inbox). Make the person wait
  /// it out here, or a tap would look like it worked when nothing was sent.
  static const _cooldown = 60;
  int _wait = _cooldown; // a code was just requested on the previous screen
  Timer? _timer;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _wait = _cooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _wait--);
      if (_wait <= 0) t.cancel();
    });
  }

  Future<void> _resend() async {
    final email = ref.read(forgotPasswordNotifier).email;
    if (email == null || email.isEmpty) {
      // Lost the email (shouldn't happen): go back and enter it again.
      Navigator.pop(context);
      return;
    }
    setState(() => _resending = true);
    final response =
        await ref.read(forgotPasswordNotifier.notifier).forgotPassword(email);
    if (!mounted) return;
    setState(() => _resending = false);
    if (response.successMessage.isNotEmpty) {
      _startCountdown();
      getAlert('We sent a new code to $email. Check your spam folder too.',
          isWarning: false);
    } else if (response.responseMessage?.isNotEmpty ?? false) {
      getAlert(response.responseMessage!);
    } else {
      getAlert(response.errorMessage);
    }
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
              inputType: TextInputType.number,
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
              child: _resending
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator())
                  : TextButton(
                      onPressed: _wait > 0 ? null : _resend,
                      child: Text(
                        _wait > 0
                            ? "Didn't get it? Resend in ${_wait}s"
                            : "Didn't receive the code? Resend",
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w600),
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
