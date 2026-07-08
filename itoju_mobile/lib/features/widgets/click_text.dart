import 'package:flutter/material.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';

class ClickText extends StatelessWidget {
  final String? text;
  final VoidCallback? onTap;
  final Color textColor;
  final double fontSize;
  final double fontWeight;
  const ClickText(
    this.text, {
    Key? key,
    this.onTap,
    this.textColor = AppColors.primaryColorPurple,
    this.fontSize = 14,
    required this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CustomText(
        text,
        color: textColor,
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
