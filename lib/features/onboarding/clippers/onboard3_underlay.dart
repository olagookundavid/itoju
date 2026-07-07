import 'package:flutter/material.dart';

class Onboard3Underlay extends CustomClipper<Path> {

  @override
  Path getClip(Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.06933333, size.height * 0.1000000);
    path_0.cubicTo(
        size.width * 0.06933333,
        size.height * 0.08300654,
        size.width * 0.08843573,
        size.height * 0.06923077,
        size.width * 0.1120000,
        size.height * 0.06923077);
    path_0.lineTo(size.width * 0.8880000, size.height * 0.06923077);
    path_0.cubicTo(
        size.width * 0.9115653,
        size.height * 0.06923077,
        size.width * 0.9306667,
        size.height * 0.08300654,
        size.width * 0.9306667,
        size.height * 0.1000000);
    path_0.lineTo(size.width * 0.9306667, size.height * 0.6726846);
    path_0.cubicTo(
        size.width * 0.9306667,
        size.height * 0.6822058,
        size.width * 0.9245547,
        size.height * 0.6911904,
        size.width * 0.9141147,
        size.height * 0.6970173);
    path_0.lineTo(size.width * 0.5346773, size.height * 0.9088038);
    path_0.cubicTo(
        size.width * 0.5195573,
        size.height * 0.9172442,
        size.width * 0.4984960,
        size.height * 0.9174000,
        size.width * 0.4831413,
        size.height * 0.9091827);
    path_0.lineTo(size.width * 0.08657733, size.height * 0.6970058);
    path_0.cubicTo(
        size.width * 0.07572933,
        size.height * 0.6912019,
        size.width * 0.06933333,
        size.height * 0.6820346,
        size.width * 0.06933333,
        size.height * 0.6722942);
    path_0.lineTo(size.width * 0.06933333, size.height * 0.1000000);
    path_0.close();

    return path_0;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
