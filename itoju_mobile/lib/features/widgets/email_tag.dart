import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmailTag extends StatelessWidget {
  const EmailTag({
    super.key,
    this.onTap,
    this.isCancel,
    required this.email,
  });
  final bool? isCancel;
  final Function()? onTap;
  final String email;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      decoration: BoxDecoration(
          color: Colors.grey[350], borderRadius: BorderRadius.circular(50)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12.sp,
            child: Center(child: Text(email[0].toUpperCase())),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              email,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black45),
            ),
          ),
          if (isCancel ?? false)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: InkWell(
                onTap: onTap!,
                child: CircleAvatar(
                  radius: 10.sp,
                  backgroundColor: Colors.transparent,
                  child: const Center(
                      child: Icon(
                    Icons.cancel_sharp,
                    color: Colors.black45,
                  )),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag({
    super.key,
    this.onTap,
    this.isCancel,
    required this.email,
  });
  final bool? isCancel;
  final Function()? onTap;
  final String email;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
          color: Colors.grey[350], borderRadius: BorderRadius.circular(50)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Text(
              email,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black45),
            ),
          ),
          if (isCancel ?? false)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: InkWell(
                onTap: onTap!,
                child: CircleAvatar(
                  radius: 10.sp,
                  backgroundColor: Colors.transparent,
                  child: const Center(
                      child: Icon(
                    Icons.cancel_sharp,
                    color: Colors.black45,
                  )),
                ),
              ),
            )
        ],
      ),
    );
  }
}
