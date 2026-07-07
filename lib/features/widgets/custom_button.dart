// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class CustomButton extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final ButtonStyle? buttonStyle;
  final Color? textColor;

  const CustomButton(
      {Key? key, this.onPressed, this.buttonStyle, this.textColor, this.child})
      : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: widget.buttonStyle,
      onPressed: widget.onPressed,
      child: Center(child: widget.child),
    );
  }
}

ButtonStyle buttonStyle(
    {Color color = AppColors.primaryColorPurple,
    double buttonWidth = 362,
    double buttonHeight = 54,
    double elevation = 1,
    double radius = 5,
    Color borderColor = AppColors.alt_border_grey,
    bool showBorder = false}) {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(color),
    elevation: MaterialStateProperty.all<double>(elevation),
    fixedSize: MaterialStateProperty.all<Size>(
      Size(
        buttonWidth.w,
        buttonHeight.h,
      ),
    ),
    shape: MaterialStateProperty.all<OutlinedBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(radius),
        ),
      ),
    ),
    side: showBorder
        ? MaterialStateProperty.all<BorderSide>(
            BorderSide(
              color: borderColor,
            ),
          )
        : null,
  );
}

class CurvedButton extends StatelessWidget {
  const CurvedButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.color = AppColors.primaryColorPurple,
      this.textColor = Colors.white,
      this.icon,
      this.width,
      this.height,
      this.loadText,
      this.loading,
      this.loadTextFont,
      this.radius});
  final String text;
  final String? loadText;
  final Function()? onPressed;
  final Color? color;
  final Color? textColor;
  final Widget? icon;
  final double? width;
  final double? height;
  final double? radius;
  final bool? loading;
  final int? loadTextFont;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (loading ?? false) ? null : onPressed,
      style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(
            color,
          ),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 10.r),
            ),
          ),
          minimumSize: MaterialStatePropertyAll(
            Size(width ?? double.infinity, height ?? 55.h),
          ),
          maximumSize: MaterialStatePropertyAll(
            Size(width ?? double.infinity, height ?? 55.h),
          )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          icon == null
              ? const SizedBox.shrink()
              : Row(
                  children: [icon!, 10.pw],
                ),
          (loading ?? false)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loadText ?? "Loading",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: loadTextFont?.sp ?? 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppLoader(size: 20.sp, color: Colors.white),
                  ],
                )
              : Text(
                  text,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: textColor),
                ),
        ],
      ),
    );
  }
}
