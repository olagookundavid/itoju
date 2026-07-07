import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class ReoccurringSyms extends ConsumerWidget {
  const ReoccurringSyms(this.image, this.metric, this.no, {super.key});
  final String image;
  final String metric;
  final String no;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: AppColors.primaryColorPurple)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              color: AppColors.splash_underlay,
            ),
            child: Center(
              child: SvgPicture.asset(
                'asset/svg/$image.svg',
                width: 30.w,
                height: 30.w,
              ),
            ),
          ),
          CustomText(
            metric,
            maxline: 2,
            color: AppColors.primaryColorPurple,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomText(
                no,
                color: AppColors.primaryColorPurple,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
              2.pw,
              CustomText(
                'time(s)',
                color: AppColors.primaryColorPurple,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ],
          )
        ],
      ),
    );
  }
}
