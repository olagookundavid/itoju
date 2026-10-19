import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/core/helpers/utils.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/exercise_7_day_chart_notifier.dart';
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
                            barGroups: chartExerciseData(state.exercise7ChartModel!),
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
                                    final pos = value.toInt();
                                    if (pos < 1 || pos > 7) {
                                      return const SizedBox.shrink();
                                    }
                                    final date = DateTime.now().subtract(
                                        Duration(days: 7 - pos));
                                    final label = switch (date.weekday) {
                                      1 => 'Mon',
                                      2 => 'Tue',
                                      3 => 'Wed',
                                      4 => 'Thur',
                                      5 => 'Fri',
                                      6 => 'Sat',
                                      7 => 'Sun',
                                      _ => '',
                                    };
                                    return SideTitleWidget(
                                      meta: meta,
                                      child: Text(
                                        label,
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

List<BarChartGroupData> chartExerciseData(Exercise7ChartModel model) {
  final now = DateTime.now();
  final groups = <BarChartGroupData>[];
  for (int pos = 1; pos <= 7; pos++) {
    final date = now.subtract(Duration(days: 7 - pos));
    final dow = date.weekday % 7;
    final val = switch (dow) {
      0 => model.sun ?? 0,
      1 => model.mon ?? 0,
      2 => model.tue ?? 0,
      3 => model.wed ?? 0,
      4 => model.thur ?? 0,
      5 => model.fri ?? 0,
      6 => model.sat ?? 0,
      _ => 0,
    };
    groups.add(BarChartGroupData(
      x: pos,
      barRods: [
        BarChartRodData(
          toY: val.toDouble(),
          color: const Color(0xffE34131),
        )
      ],
    ));
  }
  return groups;
}
