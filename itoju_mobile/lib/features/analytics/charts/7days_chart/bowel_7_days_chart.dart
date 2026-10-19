import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/bowel_7_day_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/widgets/color_tile.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class Bowel7DaysChart extends ConsumerWidget {
  const Bowel7DaysChart({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bowel7ChartProvider);
    return Column(
      children: [
        state.status == Loader.loading
            ? const AppLoader()
            : state.status == Loader.error
                ? MiniErrorCon(
                    func: () {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        ref
                            .read(bowel7ChartProvider.notifier)
                            .getBowel7DaysChart();
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
                            borderData: FlBorderData(
                              show: false,
                            ),
                            gridData: const FlGridData(show: false),
                            barGroups: chartBowelData(state.bowel7ChartModel!),
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

  List<BarChartGroupData> chartBowelData(Bowel7ChartModel model) {
    final now = DateTime.now();
    final groups = <BarChartGroupData>[];
    for (int pos = 1; pos <= 7; pos++) {
      final date = now.subtract(Duration(days: 7 - pos));
      final dow = date.weekday % 7;
      final val = switch (dow) {
        0 => model.sun ?? const [],
        1 => model.mon ?? const [],
        2 => model.tue ?? const [],
        3 => model.wed ?? const [],
        4 => model.thur ?? const [],
        5 => model.fri ?? const [],
        6 => model.sat ?? const [],
        _ => const <BowelAnalyticsKeyValue>[],
      };
      groups.add(BarChartGroupData(
        x: pos,
        barRods: [...transformToBarChartRodData(val)],
      ));
    }
    return groups;
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
