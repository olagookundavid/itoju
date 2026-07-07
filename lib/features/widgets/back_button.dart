import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  const CustomBackButton({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 40.h,
        width: 40.w,
        margin: EdgeInsets.all(7.w),
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.alt_border_grey),
            borderRadius: BorderRadius.circular(4)),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios,
            size: 15,
            color: AppColors.primaryColorPurple,
          ),
        ),
      ),
    );
  }
}
