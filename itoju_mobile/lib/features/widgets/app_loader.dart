import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:itoju_mobile/core/colors/colors.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({Key? key, this.color, this.size = 50.0}) : super(key: key);
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitThreeBounce(
        color: color ?? AppColors.primaryColorPurple,
        size: size,
      ),
    );
  }
}
