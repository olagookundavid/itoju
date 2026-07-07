import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class ProfileTiles extends StatelessWidget {
  const ProfileTiles(
      {super.key,
      required this.image,
      required this.label,
      required this.onTap});
  final String image;
  final String label;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
          width: 100.w,
          height: 100.h,
          margin: EdgeInsets.all(7.w),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            color: AppColors.splash_underlay,
          ),
          child: Column(
            children: [
              10.ph,
              SvgPicture.asset(
                'asset/svg/$image.svg',
                width: 30.w,
                height: 30.h,
              ),
              7.ph,
              CustomText(
                label,
                color: AppColors.primaryColorPurple,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              )
            ],
          )),
    );
  }
}
