import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';

class SmileyBox extends StatelessWidget {
  const SmileyBox(
      {super.key,
      required this.emotes,
      required this.onTap,
      required this.isTapped});
  final String emotes;
  final Function onTap;
  final bool isTapped;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 5.h),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: isTapped ? AppColors.primaryColorPurple : null,
            border: Border.all(color: Colors.grey, width: .5)),
        child: Text(
          emotes,
          style: TextStyle(fontSize: 30.sp),
        ),
      ),
    );
  }
}
