import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/margins.dart';

class OnBoardText extends StatelessWidget {
  final String? title, description;
  const OnBoardText({
    Key? key,
    this.title,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 540.h,
      left: 15.w,
      right: 15.w,
      child: Column(
        children: [
          CustomText(
            title,
            maxline: 3,
            color: AppColors.primaryColorPurple,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          verticalSpaceSmall,
          SizedBox(
            height: 100.h,
            width: 260.w,
            child: CustomText(
              maxline: 5,
              description,
              color: AppColors.primaryColorPurple,
              textAlign: TextAlign.center,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    );
  }
}
