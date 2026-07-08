import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignValueWigdet extends StatelessWidget {
  const SignValueWigdet({super.key, required this.ctrl});

  final TextEditingController ctrl;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: const Color(0xffFFFAEB),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: TextField(
          keyboardType: TextInputType.number,
          controller: ctrl,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xffFF9F00)),
        ),
      ),
    );
  }
}
