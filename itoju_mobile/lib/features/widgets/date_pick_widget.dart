import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';

class DatePickWidget extends StatelessWidget {
  const DatePickWidget({
    required this.onTap,
    required this.title,
    Key? key,
  }) : super(key: key);
  final String title;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.primaryColorPurple.withOpacity(.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppColors.primaryColorPurple,
            width: 0.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.hintGrey),
            ),
            SizedBox(
              width: 20.w,
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 16.r,
              color: AppColors.primaryColorPurple,
            )
          ],
        ),
      ),
    );
  }
}

class DatePickerTheme extends StatelessWidget {
  const DatePickerTheme({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          // header background color
          onPrimary: Colors.white, // header text color
          onSurface: Colors.black, // body text color
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(// button text color
              ),
        ),
      ),
      child: child,
    );
  }
}

Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  initialDate ??= DateTime.now();
  firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
  lastDate ??= firstDate.add(const Duration(days: 365 * 200));

  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (selectedDate == null) return null;

  // ignore: use_build_context_synchronously
  if (!context.mounted) return selectedDate;

  final TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(selectedDate),
  );

  return selectedTime == null
      ? selectedDate
      : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
}

Future<DateTime> showOnlyTimePicker({
  required BuildContext context,
  String? text,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  initialDate = DateTime.now();
  firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
  lastDate ??= firstDate.add(const Duration(days: 365 * 200));

  final TimeOfDay? selectedTime = await showTimePicker(
    helpText: text,
    context: context,
    initialTime: TimeOfDay.fromDateTime(DateTime.now()),
  );

  return selectedTime == null
      ? initialDate
      : DateTime(
          initialDate.year,
          initialDate.month,
          initialDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
}

Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  initialDate ??= DateTime.now();
  firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
  lastDate ??= firstDate.add(const Duration(days: 365 * 200));

  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (selectedDate == null) return null;

  // ignore: use_build_context_synchronously
  if (!context.mounted) return selectedDate;

  final TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(selectedDate),
  );

  return selectedTime == null
      ? selectedDate
      : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
}
