import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/analytics/charts/7days_chart/food_7_days_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/week_charts/syms_week_chart.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/bowel_7_day_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/month_chart_notifier/bowel_month_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/widgets/color_tile.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

final bowelYearProvider = StateProvider<String>((ref) {
  return DateTime.now().year.toString();
});

class BowelMonthChart extends ConsumerStatefulWidget {
  const BowelMonthChart({
    super.key,
  });

  @override
  ConsumerState<BowelMonthChart> createState() => _BowelMonthChartState();
}

class _BowelMonthChartState extends ConsumerState<BowelMonthChart> {
  List<String> yearDropdownItems = [...getLastNYears(5)];
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bowelMonthChartProvider);
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
                  if (ref.watch(bowelYearProvider) == val) {
                    return;
                  }
                  ref.read(bowelYearProvider.notifier).state = val!;
                  ref
                      .read(bowelMonthChartProvider.notifier)
                      .getBowelMonthDaysChart(ref.watch(bowelYearProvider));
                  setState(() {});
                },
                items: yearDropdownItems,
                hint: const Text(''),
                width: 70.w,
                value: ref.watch(bowelYearProvider),
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
                            .read(bowelMonthChartProvider.notifier)
                            .getBowelMonthDaysChart(
                                ref.watch(bowelYearProvider));
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
                        width: 600.w,
                        height: 200.h,
                        child: BarChart(
                          BarChartData(
                              borderData: FlBorderData(
                                show: false,
                              ),
                              gridData: const FlGridData(show: false),
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [
                                  ...transformToBarChartRodData(
                                      state.bowelMonthChartModel!.jan!)
                                ]),
                                BarChartGroupData(x: 1, barRods: [
                                  ...transformToBarChartRodData(
                                      state.bowelMonthChartModel!.feb!)
                                ]),
                                BarChartGroupData(x: 2, barRods: [
                                  ...transformToBarChartRodData(
                                      state.bowelMonthChartModel!.mar!)
                                ]),
                                BarChartGroupData(x: 3, barRods: [
                                  ...transformToBarChartRodData(
                                      state.bowelMonthChartModel!.apr!)
                                ]),
                                BarChartGroupData(x: 4, barRods: [
                                  ...transformToBarChartRodData(
                                      state.bowelMonthChartModel!.may!)
                                ]),
                                BarChartGroupData(x: 5, barRods: [
                                  ...transformToBarChartRodData(
                                      state.bowelMonthChartModel!.jun!)
                                ]),
                                BarChartGroupData(x: 6, barRods: [
                                  ...transformToBarChartRodData(
                                      state.bowelMonthChartModel!.jul!)
                                ]),
                                BarChartGroupData(x: 7, barRods: [
                                  ...transformToBarChartRodData(
                                      state.bowelMonthChartModel!.aug!)
                                ]),
                                BarChartGroupData(x: 8, barRods: [
                                  ...transformToBarChartRodData(
                                      state.bowelMonthChartModel!.sept!)
                                ]),
                                BarChartGroupData(x: 9, barRods: [
                                  ...transformToBarChartRodData(
                                      state.bowelMonthChartModel!.oct!)
                                ]),
                                BarChartGroupData(x: 10, barRods: [
                                  ...transformToBarChartRodData(
                                      state.bowelMonthChartModel!.nov!)
                                ]),
                                BarChartGroupData(x: 11, barRods: [
                                  ...transformToBarChartRodData(
                                      state.bowelMonthChartModel!.dec!)
                                ]),
                              ],
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                    axisNameWidget: CustomText(
                                      'Number of movements',
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
        20.ph,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.start,
            runSpacing: 10.h,
            spacing: 20.w,
            direction: Axis.horizontal,
            children: [
              ColorTile(
                color: getColorForBowelDiary(1),
                text: 'Type 1',
              ),
              ColorTile(
                color: getColorForBowelDiary(2),
                text: 'Type 2',
              ),
              ColorTile(
                color: getColorForBowelDiary(3),
                text: 'Type 3',
              ),
              ColorTile(
                color: getColorForBowelDiary(4),
                text: 'Type 4',
              ),
              ColorTile(
                color: getColorForBowelDiary(5),
                text: 'Type 5',
              ),
              ColorTile(
                color: getColorForBowelDiary(6),
                text: 'Type 6',
              ),
              ColorTile(
                color: getColorForBowelDiary(7),
                text: 'Type 7',
              ),
            ],
          ),
        )
      ],
    );
  }

  List<BarChartRodData> transformToBarChartRodData(
      List<BowelAnalyticsKeyValue> analyticsData) {
    return analyticsData.map((data) {
      return BarChartRodData(
        toY: data.value.toDouble(),
        color: getColorForBowelDiary(data.key),
      );
    }).toList();
  }
}

Color getColorForBowelDiary(int bowel) {
  return switch (bowel) {
    1 => const Color(0xffFBD490),
    2 => const Color(0xff99E6FF),
    3 => const Color(0xff6A6AFB),
    4 => const Color(0xffFF6963),
    5 => const Color(0xff6B88C7),
    6 => const Color(0xff3FEACB),
    7 => const Color(0xff02A437),
    _ => Colors.white,
  };
}
