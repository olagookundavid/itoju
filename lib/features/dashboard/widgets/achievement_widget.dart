import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class AchievementWidget extends StatelessWidget {
  const AchievementWidget(
      {super.key, required this.text1, required this.text2});
  final String text1, text2;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 115.w,
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40.r,
                backgroundColor: const Color(0xff8662FF),
                child: CircleAvatar(
                  radius: 37.r,
                  backgroundColor: const Color(0xff5142AB),
                  child: Center(
                    child: Text(
                      text1,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 3.h,
                right: 0,
                child: CircleAvatar(
                  radius: 13.r,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    backgroundColor: const Color(0xff5142AB),
                    radius: 10.r,
                    child: SvgPicture.asset(
                      'asset/svg/i.svg',
                      width: 12.w,
                      height: 15.w,
                    ),
                  ),
                ),
              )
            ],
          ),
          5.ph,
          SizedBox(
            width: 115.w,
            child: Text(text2,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                    overflow: TextOverflow.visible,
                    color: AppColors.primaryColorPurple,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }
}
