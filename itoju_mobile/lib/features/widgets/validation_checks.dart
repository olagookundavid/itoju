import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class PasswordValidator extends StatelessWidget {
  final bool hasAtLeastEightChars;
  final bool hasUpperAndLowerCaseChars;
  final bool hasNumber;
  final bool hasSpecialChar;

  const PasswordValidator(
      {super.key,
      required this.hasAtLeastEightChars,
      required this.hasUpperAndLowerCaseChars,
      required this.hasNumber,
      required this.hasSpecialChar});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        10.ph,
        PasswordConditionIndicator(
          isValid: hasAtLeastEightChars,
          title: 'At least 8 characters',
        ),
        5.ph,
        PasswordConditionIndicator(
          isValid: hasUpperAndLowerCaseChars,
          title: 'Upper and lower case characters',
        ),
        5.ph,
        PasswordConditionIndicator(
          isValid: hasNumber,
          title: '1 or more numbers',
        ),
        5.ph,
        PasswordConditionIndicator(
          isValid: hasSpecialChar,
          title: '1 or more special characters',
        ),
      ],
    );
  }
}

class PasswordConditionIndicator extends StatelessWidget {
  final bool isValid;
  final String title;

  const PasswordConditionIndicator({
    super.key,
    required this.isValid,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return isValid
        ? Row(children: [
            Icon(Icons.check_box_outlined, color: Colors.green, size: 22.r),
            13.pw,
            Text(
              title,
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500),
            ),
          ])
        : Row(children: [
            Icon(
              Icons.check_box_outline_blank_rounded,
              color: Colors.grey,
              size: 22.r,
            ),
            13.pw,
            Text(
              title,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500),
            ),
          ]);
  }
}
