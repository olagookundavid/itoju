import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/analytics/charts/month_charts/bowel_month_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/month_charts/exercise_month_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/month_charts/food_month_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/month_charts/syms_month_chart.dart';
import 'package:itoju_mobile/features/analytics/week_chart_screen.dart';
import 'package:itoju_mobile/features/analytics/widgets/yellow_warning.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class MonthAnalyticChart extends ConsumerStatefulWidget {
  const MonthAnalyticChart({
    super.key,
  });

  @override
  ConsumerState<MonthAnalyticChart> createState() => _DaysAnalyticChartState();
}

class _DaysAnalyticChartState extends ConsumerState<MonthAnalyticChart>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const YellowWarning(
            text: 'Please scroll sideways to view all data in each chart',
          ),
          15.ph,
          const AnalyticHeaderText(text: 'Exercise'),
          5.ph,
          const ExerciseMonthChart(),
          20.ph,
          const AnalyticHeaderText(text: 'Symptoms'),
          20.ph,
          const SymptomsMonthChart(),
          20.ph,
          const AnalyticHeaderText(text: 'Food Diary'),
          20.ph,
          const FoodMonthChart(),
          20.ph,
          const AnalyticHeaderText(text: 'Bowel Movement'),
          20.ph,
          const BowelMonthChart(),
          50.ph
        ],
      ),
    );
  }
}
