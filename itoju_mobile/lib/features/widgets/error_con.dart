import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class ErrorCon extends StatelessWidget {
  const ErrorCon({super.key, this.text, this.func});
  final Function()? func;
  final String? text;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        500.pw,
        SizedBox(
            width: 150.w,
            child: Image.asset(
              "asset/png/error.png",
              fit: BoxFit.fill,
            )),
        10.ph,
        CustomText(
          'Oops!!!',
          color: AppColors.primaryColorPurple,
          fontWeight: FontWeight.w600,
          fontSize: 24.sp,
        ),
        10.ph,
        SizedBox(
          width: 300.w,
          child: CustomText(
            text ?? 'Please check your connection or try again',
            color: const Color(0xff737B7D),
            maxline: 4,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w500,
            fontSize: 16.sp,
          ),
        ),
        20.ph,
        if (func != null)
          CurvedButton(text: 'Retry', width: 120.w, onPressed: func)
      ],
    );
  }
}

class MiniErrorCon extends StatelessWidget {
  const MiniErrorCon({super.key, this.func});
  final Function()? func;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: func,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          500.pw,
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                'Oops!!!',
                color: AppColors.primaryColorPurple,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
              5.pw,
              CustomText(
                'Retry',
                fontSize: 16.sp,
                color: AppColors.primaryColorPurple,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const Icon(Icons.restart_alt_rounded)
        ],
      ),
    );
  }
}
