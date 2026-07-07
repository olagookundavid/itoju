import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class YellowWarning extends StatelessWidget {
  const YellowWarning({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xffFEF9E5),
          borderRadius: BorderRadius.circular(7.r)),
      padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 7.w),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.primaryColorPurple),
          7.pw,
          SizedBox(
            width: 300.w,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primaryColorPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
