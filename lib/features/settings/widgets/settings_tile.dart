import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile(
      {super.key,
      required this.image,
      required this.text,
      required this.onTap});
  final String image, text;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Card(
          elevation: .3,
          child: Container(
            width: double.infinity,
            height: 55.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                10.pw,
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                      color: AppColors.splash_underlay,
                      borderRadius: BorderRadius.circular(5.r)),
                  child: SvgPicture.asset(
                    'asset/svg/$image.svg',
                    width: 20.w,
                    height: 20.h,
                  ),
                ),
                20.pw,
                CustomText(
                  text,
                  color: AppColors.primaryColorPurple,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
