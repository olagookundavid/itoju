import 'package:flutter/material.dart';
import 'package:itoju_mobile/core/colors/colors.dart';

class Indicator extends StatelessWidget {
  final int? positionIndex, currentIndex;
  const Indicator({super.key, this.currentIndex, this.positionIndex});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: positionIndex == currentIndex
          ? MediaQuery.of(context).size.width / 15
          : MediaQuery.of(context).size.width / 15,
      height: positionIndex == currentIndex
          ? MediaQuery.of(context).size.height / 100 * 1.2
          : MediaQuery.of(context).size.height / 100 * 1.2,
      decoration: BoxDecoration(
          border: Border.all(
              style: BorderStyle.solid,
              color: positionIndex == currentIndex
                  ? AppColors.primaryColorPurple
                  : AppColors.opaquePurple),
          color: positionIndex == currentIndex
              ? AppColors.primaryColorPurple
              : AppColors.opaquePurple,
          borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.width / 100 * 30)),
    );
  }
}
