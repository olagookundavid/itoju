// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/onboarding/clippers/onboard2_underlay.dart';
import 'package:itoju_mobile/features/onboarding/clippers/onboard3_underlay.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/components/asset/constants/images.dart';
import 'package:itoju_mobile/features/onboarding/onboarding_text.dart';

class OnBoarding1 extends StatefulWidget {
  const OnBoarding1({Key? key}) : super(key: key);

  @override
  _OnBoarding1State createState() => _OnBoarding1State();
}

class _OnBoarding1State extends State<OnBoarding1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 75.h,
            left: 15.w,
            right: 15.w,
            child: ClipPath(
              clipper: Onboard3Underlay(),
              child: Container(
                height: 460.h,
                width: 500.w,
                color: AppColors.opaquePurple,
              ),
            ),
          ),
          Positioned(
              top: 85.h,
              left: 15.w,
              right: 15.w,
              child: ClipPath(
                clipper: Onboard2Underlay(),
                child: Container(
                  height: 425.h,
                  width: 323.w,
                  color: AppColors.opaqueYellow,
                ),
              )),
          Positioned(
            top: 90.h,
            left: 15.w,
            right: 15.w,
            child: Image.asset(
              Images.onBoard1,
              // scale: 1.15,
              height: 365.h,
              // width: 60,
            ),
          ),
          const OnBoardText(
            title: "Track your symptoms",
            description:
                "Easily monitor your symptoms and understand trends and patterns",
          )
        ],
      ),
    );
  }
}
