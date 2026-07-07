import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

customDialog(BuildContext context, Widget child,
    {double dialogHeight = 500, double dialogWidth = 400}) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
          height: dialogHeight.h,
          width: dialogWidth.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: child),
    ),
  );
}
