// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/onboarding/clippers/onboard2_underlay.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/components/asset/constants/images.dart';
import 'package:itoju_mobile/features/onboarding/onboarding_text.dart';

class OnBoarding3 extends StatefulWidget {
  const OnBoarding3({Key? key}) : super(key: key);

  @override
  _OnBoarding3State createState() => _OnBoarding3State();
}

class _OnBoarding3State extends State<OnBoarding3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 65.h,
            left: 15.w,
            right: 15.w,
            child: ClipPath(
              clipper: Onboard2Underlay(),
              child: Container(
                height: 420.h,
                width: 323.w,
                color: AppColors.opaqueYellow,
              ),
            ),
          ),
          Positioned(
            top: 35.h,
            left: 15.w,
            right: 15.w,
            child: Image.asset(
              Images.onBoard3,
              // scale: 1.2,
            ),
          ),
          const OnBoardText(
            title: "Control your pain",
            description:
                "Share your insights with your healthcare providers and take action to improve your quality of life",
          )
        ],
      ),
    );
  }
}
