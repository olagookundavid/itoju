import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';

class AppTabModel {
  final String title;
  AppTabModel({required this.title});
}

class AppTabHeader extends StatelessWidget {
  const AppTabHeader({
    Key? key,
    required this.currentTab,
    required this.index,
    required this.item,
    this.onTap,
    this.width,
    this.fontSize,
  }) : super(key: key);
  final int currentTab;
  final int index;
  final AppTabModel item;
  final void Function()? onTap;
  final double? width;
  final double? fontSize;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
        alignment: Alignment.center,
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: currentTab == index
              ? AppColors.primaryColorPurple.withOpacity(.85)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: currentTab == index
                ? AppColors.primaryColorPurple.withOpacity(.7)
                : Colors.transparent,
            width: 1.w,
          ),
        ),
        child: Text(
          item.title,
          style: TextStyle(
            fontSize: fontSize ?? 14.sp,
            fontWeight: FontWeight.w600,
            color: currentTab == index
                ? Colors.white
                : AppColors.primaryColorPurple,
          ),
        ),
      ),
    );
  }
}
