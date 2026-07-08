import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/core/helpers/utils.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/exercise_7_day_chart_notifier%20.dart';
import 'package:itoju_mobile/features/metrics/notifiers/symptoms_notifier.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';

class Exercise7DaysChart extends ConsumerStatefulWidget {
  const Exercise7DaysChart({
    super.key,
  });

  @override
  ConsumerState<Exercise7DaysChart> createState() => _Exercise7DaysChartState();
}

class _Exercise7DaysChartState extends ConsumerState<Exercise7DaysChart> {
  SymptomsModel? sym;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exercise7ChartProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        state.status == Loader.loading
            ? const AppLoader()
            : state.status == Loader.error
                ? MiniErrorCon(
                    func: () {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        ref
                            .read(exercise7ChartProvider.notifier)
                            .getExercise7DaysChart();
                      });
                    },
                  )
                : Container(
                    padding:
                        EdgeInsets.only(left: 10.w, top: 20.h, bottom: 20.h),
                    decoration: const BoxDecoration(color: Color(0xffFFF8E5)),
                    child: AspectRatio(
                      aspectRatio: 1.5,
                      child: BarChart(
                        BarChartData(
                            maxY: getHighestListValue([
                              state.exercise7ChartModel!.mon!.toDouble(),
                              state.exercise7ChartModel!.tue!.toDouble(),
                              state.exercise7ChartModel!.wed!.toDouble(),
                              state.exercise7ChartModel!.thur!.toDouble(),
                              state.exercise7ChartModel!.fri!.toDouble(),
                              state.exercise7ChartModel!.sat!.toDouble(),
                              state.exercise7ChartModel!.sun!.toDouble()
                            ]),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            gridData: const FlGridData(show: false),
                            barGroups: chartSymsData([
                              state.exercise7ChartModel!.mon!.toDouble(),
                              state.exercise7ChartModel!.tue!.toDouble(),
                              state.exercise7ChartModel!.wed!.toDouble(),
                              state.exercise7ChartModel!.thur!.toDouble(),
                              state.exercise7ChartModel!.fri!.toDouble(),
                              state.exercise7ChartModel!.sat!.toDouble(),
                              state.exercise7ChartModel!.sun!.toDouble()
                            ]),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                  axisNameWidget: CustomText(
                                    'Average Total Exercises',
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryColorPurple,
                                  ),
                                  sideTitles: SideTitles(
                                      reservedSize: 40.w, showTitles: true)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Text(
                                        switch (value) {
                                          7 => 'Sun',
                                          1 => 'Mon',
                                          2 => 'Tue',
                                          3 => 'Wed',
                                          4 => 'Thur',
                                          5 => 'Fri',
                                          6 => 'Sat',
                                          _ => '',
                                        },
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                AppColors.primaryColorPurple),
                                      ),
                                    );
                                  },
                                  reservedSize: 38,
                                ),
                              ),
                            ),
                            backgroundColor: const Color(0xffFFF8E5)),
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.linear,
                      ),
                    ),
                  ),
      ],
    );
  }
}

List<BarChartGroupData> chartSymsData(List<double> values) {
  if (values.length != 7) {
    throw ArgumentError('The values list must contain exactly 7 elements.');
  }

  int todayIndex = DateTime.now().weekday;

  // Create the reordered list
  List<BarChartGroupData> reorderedData = [];

  // Append from todayIndex to the end

  for (int i = todayIndex + 1; i <= values.length; i++) {
    reorderedData.add(BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(toY: values[i - 1], color: const Color(0xffE34131))
      ],
    ));
  }

  // Append from the beginning to todayIndex-1

  for (int i = 1; i < todayIndex + 1; i++) {
    reorderedData.add(BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(toY: values[i - 1], color: const Color(0xffE34131))
      ],
    ));
  }

  return reorderedData;
}
