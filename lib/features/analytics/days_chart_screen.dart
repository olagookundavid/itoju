import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/analytics/charts/7days_chart/bowel_7_days_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/7days_chart/exercise_7_days_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/7days_chart/food_7_days_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/7days_chart/syms_7_days_chart.dart';
import 'package:itoju_mobile/features/analytics/week_chart_screen.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class DaysAnalyticChart extends ConsumerStatefulWidget {
  const DaysAnalyticChart({
    super.key,
  });

  @override
  ConsumerState<DaysAnalyticChart> createState() => _DaysAnalyticChartState();
}

class _DaysAnalyticChartState extends ConsumerState<DaysAnalyticChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AnalyticHeaderText(text: 'Exercise'),
          5.ph,
          const Exercise7DaysChart(),
          20.ph,
          const AnalyticHeaderText(text: 'Symptoms'),
          20.ph,
          const Symptoms7DaysChart(),
          20.ph,
          const AnalyticHeaderText(text: 'Food Diary'),
          20.ph,
          const Food7DaysChart(),
          20.ph,
          const AnalyticHeaderText(text: 'Bowel Movement'),
          20.ph,
          const Bowel7DaysChart(),
          50.ph
        ],
      ),
    );
  }
}
