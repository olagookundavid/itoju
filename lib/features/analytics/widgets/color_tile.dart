import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class ColorTile extends StatelessWidget {
  const ColorTile({super.key, required this.color, required this.text});
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 15.w,
          width: 15.w,
          decoration: BoxDecoration(shape: BoxShape.rectangle, color: color),
        ),
        7.pw,
        CustomText(
          text,
          color: const Color(0xff5142AB),
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
        )
      ],
    );
  }
}
