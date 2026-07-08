import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomText extends StatelessWidget {
  final String? text;
  final double fontSize;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final Color? color;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final TextDecoration? decoration;
  final int? maxline;
  const CustomText(this.text,
      {Key? key,
      this.fontSize = 27,
      this.fontWeight = FontWeight.normal,
      this.fontStyle = FontStyle.normal,
      this.color = Colors.white,
      this.textAlign = TextAlign.start,
      this.overflow = TextOverflow.ellipsis,
      this.decoration,
      this.maxline})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text!,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxline,
        style: TextStyle(
            fontSize: fontSize.h,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            color: color,
            decoration: decoration)

        // GoogleFonts.montserrat(
        //   fontSize: fontSize.h,
        //   fontWeight: fontWeight,
        //   fontStyle: fontStyle,
        //   color: color,
        //   decoration: decoration,
        // ),
        );
  }
}
