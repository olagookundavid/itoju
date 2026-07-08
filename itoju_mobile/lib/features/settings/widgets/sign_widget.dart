import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';

class SignWigdet extends StatelessWidget {
  const SignWigdet({super.key, required this.onTap, required this.isAdd});
  final Function onTap;
  final bool isAdd;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.primaryColorPurple,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          isAdd ? Icons.add : Icons.remove,
          size: 30.r,
          color: Colors.white,
        ),
      ),
    );
  }
}
