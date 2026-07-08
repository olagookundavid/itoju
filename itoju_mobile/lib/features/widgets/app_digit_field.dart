import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:pinput/pinput.dart';

class AppDigitField extends StatelessWidget {
  const AppDigitField({
    super.key,
    this.length = 4,
    this.validator,
    this.onChanged,
    this.onCompleted,
    this.controller,
    this.margin,
    this.focus = false,
    this.primaryColor,
  });

  final int length;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged, onCompleted;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? margin;
  final bool? focus;
  final Color? primaryColor;

  @override
  Widget build(BuildContext context) {
    return Pinput(
      autofocus: focus ?? false,
      obscureText: true,
      length: length,
      onCompleted: onCompleted,
      showCursor: true,
      controller: controller,
      crossAxisAlignment: CrossAxisAlignment.center,
      defaultPinTheme: PinTheme(
          height: 55.h,
          width: 50.w,
          margin: margin,
          textStyle: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(10.r),
          )),
      submittedPinTheme: PinTheme(
          height: 55.h,
          width: 50.w,
          textStyle: TextStyle(
            fontSize: 20.sp,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                color: primaryColor ?? AppColors.primaryColorPurple, width: 2),
            borderRadius: BorderRadius.circular(10.r),
          )),
      followingPinTheme: PinTheme(
          height: 55.h,
          width: 50.w,
          textStyle: TextStyle(
            fontSize: 20.sp,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.r),
          )),
      focusedPinTheme: PinTheme(
          height: 55.h,
          width: 50.w,
          textStyle: TextStyle(
            fontSize: 20.sp,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                color: primaryColor ?? AppColors.primaryColorPurple, width: 2),
            borderRadius: BorderRadius.circular(10.r),
          )),
    );
  }
}
