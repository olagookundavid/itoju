// ignore_for_file: deprecated_member_use, library_private_types_in_public_api, file_names

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';

class MyCeckBox extends StatefulWidget {
  final String? term;
  final String? linkText;
  final VoidCallback? onTap;
  final Function(bool?)? onChanged;
  final bool isChecked;
  const MyCeckBox(
      {Key? key,
      this.term,
      this.linkText,
      this.onTap,
      this.onChanged,
      this.isChecked = false})
      : super(key: key);

  @override
  _MyCeckBoxState createState() => _MyCeckBoxState();
}

class _MyCeckBoxState extends State<MyCeckBox> {
  // bool? isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      if (widget.isChecked) {
        return Colors.greenAccent.withOpacity(0.2);
      } else {
        return AppColors.primaryColorPurple.withOpacity(0.1);
      }
    }

    return SizedBox(
      height: 30.h,
      width: 350.w,
      child: Row(
        children: [
          Checkbox(
              checkColor: Colors.greenAccent,
              fillColor: MaterialStateProperty.resolveWith(getColor),
              value: widget.isChecked,
              onChanged: widget.onChanged),
          Row(
            children: [
              CustomText(widget.term,
                  fontSize: 10.sp, color: AppColors.greyish_purple),
              InkWell(
                onTap: widget.onTap,
                child: CustomText(
                  "${widget.linkText}",
                  fontSize: 10.sp,
                  color: AppColors.greyish_purple,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SpecialCustomCheckBox extends StatefulWidget {
  final String? firstTerm, secondTerm;
  final String? firstlinkText, secondLinkText;
  final VoidCallback? firstLink, lastLink;
  final Function(bool?)? onChanged;
  final bool isChecked;
  const SpecialCustomCheckBox(
      {Key? key,
      this.firstLink,
      this.lastLink,
      this.firstTerm,
      this.secondTerm,
      this.firstlinkText,
      this.secondLinkText,
      this.onChanged,
      this.isChecked = false})
      : super(key: key);

  @override
  _SpecialCustomCheckBoxState createState() => _SpecialCustomCheckBoxState();
}

class _SpecialCustomCheckBoxState extends State<SpecialCustomCheckBox> {
  // bool? isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      if (widget.isChecked) {
        return Colors.greenAccent.withOpacity(0.2);
      } else {
        return AppColors.primaryColorPurple.withOpacity(0.1);
      }
    }

    return SizedBox(
      height: 40.h,
      width: 350.w,
      child: Row(
        children: [
          Checkbox(
              checkColor: Colors.greenAccent,
              fillColor: MaterialStateProperty.resolveWith(getColor),
              value: widget.isChecked,
              onChanged: widget.onChanged),
          RichText(
            text: TextSpan(
              text: 'I agree to provide my data for',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.greyish_purple,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: widget.firstlinkText,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 10.sp,
                      color: AppColors.greyish_purple,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.firstLink),
                TextSpan(
                  text: widget.firstTerm,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.greyish_purple,
                  ),
                ),
                TextSpan(
                  text: widget.secondTerm,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.greyish_purple,
                  ),
                ),
                TextSpan(
                    text: widget.secondLinkText,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 10.sp,
                      color: AppColors.greyish_purple,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.lastLink),
              ],
            ),
          )
        ],
      ),
    );
  }
}
