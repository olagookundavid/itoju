import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';

class SliderValue extends StatelessWidget {
  const SliderValue({
    super.key,
    required this.serverity,
  });

  final double serverity;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 10.w),
        child: CircleAvatar(
          radius: 12.r,
          child: Center(
              child: Text(
            (serverity * 10).toStringAsFixed(0),
            style: TextStyle(
                color: AppColors.primaryColorPurple,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600),
          )),
        ));
  }
}
