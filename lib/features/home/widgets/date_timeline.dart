import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class DateTimeline extends StatelessWidget {
  final DateTime dateTime;
  final bool isSelected;
  final Function? onDateSelected;
  const DateTimeline({
    super.key,
    required this.dateTime,
    this.isSelected = false,
    this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return SizedBox(
      width: 50,
      child: InkWell(
        onTap: () {
          onDateSelected!();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEE').format(dateTime),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 12.sp,
                color: isSelected ? Colors.green : Colors.grey,
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            Container(
              height: 22.h,
              width: 22.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.green : Colors.transparent,
              ),
              child: FittedBox(
                child: Text(
                  '${dateTime.day}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    fontSize: isSelected ? 14.sp : 12.sp,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
