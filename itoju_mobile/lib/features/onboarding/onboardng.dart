// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/onboarding/welcome_page.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/onboarding/onbaording1.dart';
import 'package:itoju_mobile/features/onboarding/onboard3.dart';
import 'package:itoju_mobile/features/onboarding/onboarding2.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/onboard_indicator.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  PageController? controller;
  int currentIndex = 0;

  @override
  void initState() {
    controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  /// Leaves the slides (Skip or Get Started) for the auth choice step. The
  /// stage is persisted BEFORE navigating so killing the app here resumes at
  /// the WelcomePage, never the dashboard. firstTime stays for legacy installs.
  Future<void> _leaveSlides(BuildContext context) async {
    await HiveStorage.put(HiveKeys.firstTime, false);
    await OnboardingStage.set(OnboardingStage.auth);
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
  }

  // var box = Hive.box('onboarding');

  final List<Widget> _onBoardPages = [
    const OnBoarding1(),
    const OnBoarding2(),
    const OnBoarding3(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged: onPageChanged,
            controller: controller,
            children: [..._onBoardPages],
          ),
          currentIndex == 2
              ? Container()
              : Positioned(
                  top: 70.h,
                  right: 38.w,
                  child: InkWell(
                    onTap: () => _leaveSlides(context),
                    child: Container(
                      height: 36.h,
                      width: 56.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.borderGrey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: CustomText(
                          "Skip",
                          fontSize: 12.sp,
                          color: AppColors.skipGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
          Positioned(
            top: 510.h,
            left: 15.w,
            right: 15.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Indicator(
                      positionIndex: index,
                      currentIndex: currentIndex,
                    ),
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 680.h,
            left: 15.w,
            right: 15.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                currentIndex == 2
                    ? CustomButton(
                        buttonStyle: buttonStyle(
                            color: AppColors.primaryColorPurple,
                            buttonHeight: 56.h,
                            buttonWidth: 160.w,
                            radius: 8),
                        child: const CustomText(
                          "Get Started",
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        onPressed: () => _leaveSlides(context),
                      )
                    : CustomButton(
                        onPressed: () {
                          controller!.nextPage(
                              duration: const Duration(milliseconds: 30),
                              curve: Curves.ease);
                        },
                        buttonStyle: buttonStyle(
                            color: AppColors.primaryColorPurple,
                            buttonHeight: 56.h,
                            buttonWidth: 56.w,
                            radius: 8),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }

  onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }
}
