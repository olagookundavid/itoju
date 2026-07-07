import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/dialog.dart';
import 'package:itoju_mobile/features/widgets/margins.dart';

/// Shows a "coming soon" popup for sign-in providers that are visible in the UI
/// but not yet enabled (currently Facebook and Apple). Google is fully working.
void showComingSoonDialog(BuildContext context, String provider) {
  customDialog(
    context,
    _ComingSoonDialog(provider: provider),
    dialogHeight: 260,
    dialogWidth: 400,
  );
}

class _ComingSoonDialog extends StatelessWidget {
  final String provider;
  const _ComingSoonDialog({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            color: AppColors.primaryColorPurple,
            size: 40.r,
          ),
          verticalSpaceMedium,
          const CustomText(
            "Coming soon",
            color: AppColors.primaryColorPurple,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
          verticalSpaceSmall,
          CustomText(
            "$provider sign-in isn't available yet. For now, please continue with Google or your email and password.",
            color: Colors.black,
            fontSize: 14,
            textAlign: TextAlign.center,
          ),
          verticalSpaceLarge,
          CustomButton(
            onPressed: () => Navigator.pop(context),
            buttonStyle: buttonStyle(buttonWidth: 100, radius: 10),
            child: CustomText(
              "Got it",
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
