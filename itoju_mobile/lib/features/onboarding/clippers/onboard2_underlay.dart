import 'package:flutter/material.dart';

class Onboard2Underlay extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.06933333, size.height * 0.1048387);
    path_0.cubicTo(
        size.width * 0.06933333,
        size.height * 0.08702298,
        size.width * 0.08843573,
        size.height * 0.07258065,
        size.width * 0.1120000,
        size.height * 0.07258065);
    path_0.lineTo(size.width * 0.8880000, size.height * 0.07258065);
    path_0.cubicTo(
        size.width * 0.9115653,
        size.height * 0.07258065,
        size.width * 0.9306667,
        size.height * 0.08702298,
        size.width * 0.9306667,
        size.height * 0.1048387);
    path_0.lineTo(size.width * 0.9306667, size.height * 0.7959617);
    path_0.cubicTo(
        size.width * 0.9306667,
        size.height * 0.8104073,
        size.width * 0.9179627,
        size.height * 0.8230927,
        size.width * 0.8995707,
        size.height * 0.8270101);
    path_0.lineTo(size.width * 0.5153707, size.height * 0.9088488);
    path_0.cubicTo(
        size.width * 0.5078693,
        size.height * 0.9104456,
        size.width * 0.4999333,
        size.height * 0.9104597,
        size.width * 0.4924213,
        size.height * 0.9088891);
    path_0.lineTo(size.width * 0.1006227, size.height * 0.8269315);
    path_0.cubicTo(
        size.width * 0.08213493,
        size.height * 0.8230645,
        size.width * 0.06933333,
        size.height * 0.8103448,
        size.width * 0.06933333,
        size.height * 0.7958427);
    path_0.lineTo(size.width * 0.06933333, size.height * 0.1048387);
    path_0.close();

    return path_0;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
