import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: 30.h,
        width: 30.w,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
            width: 2.r,
            color: AppColors.primaryColorPurple,
          ),
        ),
        child: const Icon(
          Icons.add,
          color: AppColors.primaryColorPurple,
        ));
  }
}
