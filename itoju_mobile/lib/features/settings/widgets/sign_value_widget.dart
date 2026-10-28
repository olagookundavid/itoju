import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The big editable number in the +/- steppers. [decimal] allows one digit after
/// the point (body measurements); [suffix] labels the unit inside the box.
class SignValueWigdet extends StatelessWidget {
  const SignValueWigdet({
    super.key,
    required this.ctrl,
    this.decimal = false,
    this.suffix,
    this.width = 80,
    this.hint = '0',
    this.onChanged,
  });

  final TextEditingController ctrl;
  final bool decimal;
  final String? suffix;
  final double width;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: const Color(0xffFFFAEB),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: TextField(
          keyboardType: decimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
          // At most one decimal place; a comma (some keyboards) is accepted and
          // normalised by the caller's parser.
          inputFormatters: [
            decimal
                ? FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,4}([.,]\d?)?'))
                : FilteringTextInputFormatter.digitsOnly,
          ],
          controller: ctrl,
          onChanged: onChanged,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 25.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xffFF9F00).withValues(alpha: 0.35)),
            suffixText: suffix,
            suffixStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xffEEAF4B)),
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
