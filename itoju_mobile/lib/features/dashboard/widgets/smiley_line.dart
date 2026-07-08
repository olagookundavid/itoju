import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';

class SmileyLine extends StatelessWidget {
  const SmileyLine({
    super.key,
    required this.emotes,
    required this.value,
  });
  final String emotes;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            Container(
              height: 140.h,
              width: 5.w,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.r),
                      topRight: Radius.circular(5.r))),
            ),
            Positioned(
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                height: (value * 140.h),
                width: 5.w,
                decoration: BoxDecoration(
                    color: AppColors.primaryColorPurple,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5.r),
                        topRight: Radius.circular(5.r))),
              ),
            ),
          ],
        ),
        Text(
          emotes,
          style: TextStyle(fontSize: 20.r),
        )
      ],
    );
  }
}
