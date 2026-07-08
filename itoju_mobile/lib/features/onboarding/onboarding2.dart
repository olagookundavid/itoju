// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/onboarding/clippers/onboard3_underlay.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/components/asset/constants/images.dart';
import 'package:itoju_mobile/features/onboarding/onboarding_text.dart';

// import 'package:itojume/clippers/onboard3_underlay.dart';
// import 'package:itojume/constants/images.dart';
// import 'package:itojume/utils/colors.dart';
// import 'package:itojume/utils/margins.dart';

// import 'onBoardingText.dart';

class OnBoarding2 extends StatefulWidget {
  const OnBoarding2({Key? key}) : super(key: key);

  @override
  _OnBoarding2State createState() => _OnBoarding2State();
}

class _OnBoarding2State extends State<OnBoarding2> {
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
              clipper: Onboard3Underlay(),
              child: Container(
                height: 460.h,
                width: 500.w,
                color: AppColors.opaquePurple,
              ),
            ),
          ),
          Positioned(
            top: 80.h,
            left: 15.w,
            right: 15.w,
            child: Image.asset(
              Images.onBoard2,
              height: 360.h,
              // scale: 1,
              fit: BoxFit.cover,
            ),
          ),
          const OnBoardText(
            title: "Identify your potential Triggers",
            description:
                "Find out if there are habits, lifestyles or even medications that aggravate or improve your symptoms",
          )
        ],
      ),
    );
  }
}
