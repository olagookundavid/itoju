// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:itoju_mobile/features/metrics/widgets/slider_value.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class SliderAndValue extends StatelessWidget {
  const SliderAndValue({
    Key? key,
    required this.onchanged,
    required this.sev,
  }) : super(key: key);
  final Function(double) onchanged;
  final double sev;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SliderValue(serverity: sev),
        Expanded(
          child: Slider(value: sev, onChanged: onchanged),
        ),
        15.pw,
      ],
    );
  }
}
