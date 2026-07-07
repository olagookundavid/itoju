// ignore_for_file: file_names
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/core/helpers/utils.dart';
import 'package:itoju_mobile/features/analytics/charts/7days_chart/food_7_days_chart.dart';
import 'package:itoju_mobile/features/analytics/notifiers/month_chart_notifier/exercise_month_chart_notifier.dart';
import 'package:itoju_mobile/features/metrics/notifiers/symptoms_notifier.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

final exerciseYearProvider = StateProvider<String>((ref) {
  return DateTime.now().year.toString();
});

class ExerciseMonthChart extends ConsumerStatefulWidget {
  const ExerciseMonthChart({
    super.key,
  });

  @override
  ConsumerState<ExerciseMonthChart> createState() => _ExerciseMonthChartState();
}

class _ExerciseMonthChartState extends ConsumerState<ExerciseMonthChart> {
  SymptomsModel? sym;
  List<String> yearDropdownItems = [...getLastNYears(5)];
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseMonthChartProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: AppColors.primaryColorPurple),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownExample(
                onChanged: (val) {
                  if (ref.watch(exerciseYearProvider) == val) {
                    return;
                  }
                  ref.read(exerciseYearProvider.notifier).state = val!;
                  ref
                      .read(exerciseMonthChartProvider.notifier)
                      .getExerciseMonthDaysChart(
                          ref.watch(exerciseYearProvider));
                  setState(() {});
                },
                items: yearDropdownItems,
                hint: const Text(''),
                width: 70.w,
                value: ref.watch(exerciseYearProvider),
              ),
            ],
          ),
        ),
        15.ph,
        state.status == Loader.loading
            ? const AppLoader()
            : state.status == Loader.error
                ? MiniErrorCon(
                    func: () {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        ref
                            .read(exerciseMonthChartProvider.notifier)
                            .getExerciseMonthDaysChart(
                                ref.watch(exerciseYearProvider));
                      });
                    },
                  )
                : Container(
                    padding:
                        EdgeInsets.only(left: 10.w, top: 20.h, bottom: 20.h),
                    decoration: const BoxDecoration(color: Color(0xffFFF8E5)),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 400.w,
                        height: 400.h,
                        child: BarChart(
                          BarChartData(
                              maxY: getHighestListValue([
                                state.exerciseMonthChartModel!.jan!.toDouble(),
                                state.exerciseMonthChartModel!.feb!.toDouble(),
                                state.exerciseMonthChartModel!.mar!.toDouble(),
                                state.exerciseMonthChartModel!.apr!.toDouble(),
                                state.exerciseMonthChartModel!.may!.toDouble(),
                                state.exerciseMonthChartModel!.jun!.toDouble(),
                                state.exerciseMonthChartModel!.jul!.toDouble(),
                                state.exerciseMonthChartModel!.aug!.toDouble(),
                                state.exerciseMonthChartModel!.sep!.toDouble(),
                                state.exerciseMonthChartModel!.oct!.toDouble(),
                                state.exerciseMonthChartModel!.nov!.toDouble(),
                                state.exerciseMonthChartModel!.dec!.toDouble(),
                              ]),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              gridData: const FlGridData(show: false),
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                        toY: state.exerciseMonthChartModel!.jan!
                                            .toDouble(),
                                        color: const Color(0xffE34131))
                                  ],
                                ),
                                BarChartGroupData(x: 1, barRods: [
                                  BarChartRodData(
                                      toY: state.exerciseMonthChartModel!.feb!
                                          .toDouble(),
                                      color: const Color(0xffE34131))
                                ]),
                                BarChartGroupData(x: 2, barRods: [
                                  BarChartRodData(
                                      toY: state.exerciseMonthChartModel!.mar!
                                          .toDouble(),
                                      color: const Color(0xffE34131))
                                ]),
                                BarChartGroupData(x: 3, barRods: [
                                  BarChartRodData(
                                      toY: state.exerciseMonthChartModel!.apr!
                                          .toDouble(),
                                      color: const Color(0xffE34131))
                                ]),
                                BarChartGroupData(x: 4, barRods: [
                                  BarChartRodData(
                                      toY: state.exerciseMonthChartModel!.may!
                                          .toDouble(),
                                      color: const Color(0xffE34131))
                                ]),
                                BarChartGroupData(x: 5, barRods: [
                                  BarChartRodData(
                                      toY: state.exerciseMonthChartModel!.jun!
                                          .toDouble(),
                                      color: const Color(0xffE34131))
                                ]),
                                BarChartGroupData(x: 6, barRods: [
                                  BarChartRodData(
                                      toY: state.exerciseMonthChartModel!.jul!
                                          .toDouble(),
                                      color: const Color(0xffE34131))
                                ]),
                                BarChartGroupData(x: 7, barRods: [
                                  BarChartRodData(
                                      toY: state.exerciseMonthChartModel!.aug!
                                          .toDouble(),
                                      color: const Color(0xffE34131))
                                ]),
                                BarChartGroupData(x: 8, barRods: [
                                  BarChartRodData(
                                      toY: state.exerciseMonthChartModel!.sep!
                                          .toDouble(),
                                      color: const Color(0xffE34131))
                                ]),
                                BarChartGroupData(x: 9, barRods: [
                                  BarChartRodData(
                                      toY: state.exerciseMonthChartModel!.oct!
                                          .toDouble(),
                                      color: const Color(0xffE34131))
                                ]),
                                BarChartGroupData(x: 10, barRods: [
                                  BarChartRodData(
                                      toY: state.exerciseMonthChartModel!.nov!
                                          .toDouble(),
                                      color: const Color(0xffE34131))
                                ]),
                                BarChartGroupData(x: 11, barRods: [
                                  BarChartRodData(
                                      toY: state.exerciseMonthChartModel!.dec!
                                          .toDouble(),
                                      color: const Color(0xffE34131))
                                ]),
                              ],
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
                                            0 => 'Jan',
                                            1 => 'Feb',
                                            2 => 'Mar',
                                            3 => 'Apr',
                                            4 => 'May',
                                            5 => 'Jun',
                                            6 => 'Jul',
                                            7 => 'Aug',
                                            8 => 'Sep',
                                            9 => 'Oct',
                                            10 => 'Nov',
                                            11 => 'Dec',
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
                  ),
      ],
    );
  }
}

class AnalyticsFilter extends StatelessWidget {
  const AnalyticsFilter({super.key, required this.onTap, required this.name});
  final Function onTap;
  final String name;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: AppColors.primaryColorPurple),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomText(
              name,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
            7.pw,
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}

List<String> getLastNYears(int n) {
  int currentYear = DateTime.now().year;
  List<String> years = [];

  for (int i = 0; i < n; i++) {
    years.add((currentYear - i).toString());
  }

  return years;
}
