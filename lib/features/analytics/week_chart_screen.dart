import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';

import 'package:itoju_mobile/features/analytics/charts/week_charts/bowel_week_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/week_charts/exercise_week_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/week_charts/food_week_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/week_charts/syms_week_chart.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class WeekAnalyticChart extends ConsumerStatefulWidget {
  const WeekAnalyticChart({
    super.key,
  });

  @override
  ConsumerState<WeekAnalyticChart> createState() => _WeekAnalyticChartState();
}

class _WeekAnalyticChartState extends ConsumerState<WeekAnalyticChart>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AnalyticHeaderText(text: 'Exercise'),
          5.ph,
          const ExerciseWeekChart(),
          20.ph,
          const AnalyticHeaderText(text: 'Symptoms'),
          20.ph,
          const SymptomsWeekChart(),
          20.ph,
          const AnalyticHeaderText(text: 'Food Diary'),
          20.ph,
          const FoodWeekChart(),
          20.ph,
          const AnalyticHeaderText(text: 'Bowel Movement'),
          20.ph,
          const BowelWeekChart(),
          50.ph
        ],
      ),
    );
  }
}

class AnalyticHeaderText extends StatelessWidget {
  const AnalyticHeaderText({
    super.key,
    required this.text,
  });
  final String text;
  @override
  Widget build(BuildContext context) {
    return CustomText(text,
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryColorPurple);
  }
}
