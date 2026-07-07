import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class ComingSoonBottomSheet extends StatefulWidget {
  const ComingSoonBottomSheet({
    super.key,
    required this.title,
    required this.icon,
    this.body,
    this.button,
  });
  final String title, icon;
  final String? body, button;
  @override
  State<ComingSoonBottomSheet> createState() => _ComingSoonBottomSheetState();
}

class _ComingSoonBottomSheetState extends State<ComingSoonBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.h),
        child: Column(
          children: [
            20.ph,
            Text(widget.title,
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1D2739))),
            15.ph,
            Card(
              child: Container(
                width: 70.w,
                height: 60.h,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r)),
                child: Center(
                  child: SvgPicture.asset(
                    'asset/svg/${widget.icon}.svg',
                    height: 30.h,
                    width: 30.w,
                  ),
                ),
              ),
            ),
            10.ph,
            Text(widget.body ?? 'This feature is coming soon',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff344054))),
            const Spacer(),
            CurvedButton(
              text: widget.button ?? 'Okay',
              height: 50.h,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            100.ph
          ],
        ),
      ),
    );
  }
}
