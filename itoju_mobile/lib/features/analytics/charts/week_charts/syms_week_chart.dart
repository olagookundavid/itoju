import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/analytics/charts/7days_chart/food_7_days_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/7days_chart/syms_7_days_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/syms_chart_bottom_sheet.dart';
import 'package:itoju_mobile/features/analytics/notifiers/week_charts_notifier/syms_week_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/widgets/helper_funcs.dart';
import 'package:itoju_mobile/features/metrics/notifiers/symptoms_notifier.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

final symsWeekProvider = StateProvider<String>((ref) {
  return returnMonth(DateTime.now().month);
});

class SymptomsWeekChart extends ConsumerStatefulWidget {
  const SymptomsWeekChart({
    super.key,
  });

  @override
  ConsumerState<SymptomsWeekChart> createState() => _SymptomsWeekChartState();
}

class _SymptomsWeekChartState extends ConsumerState<SymptomsWeekChart> {
  SymptomsModel? sym;
  List<String> monthDropdownItems = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(symsWeekChartProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              AnalyticsFilter(
                name: ref.watch(symsIdProvider).name!,
                onTap: () async {
                  sym = await showModalBottomSheet(
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                    context: context,
                    builder: (context) => const SymsChartBottomSheet(),
                  );
                  if (sym == null || sym?.id == ref.watch(symsIdProvider).id) {
                    return;
                  }
                  ref.read(symsIdProvider.notifier).state = sym!;
                  ref.read(symsWeekChartProvider.notifier).getSymsWeekDaysChart(
                      ref.watch(symsIdProvider).id!,
                      monthToInt(ref.watch(symsWeekProvider)));
                  setState(() {});
                },
              ),
              10.pw,
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
                        if (ref.watch(symsWeekProvider) == val) {
                          return;
                        }
                        ref.read(symsWeekProvider.notifier).state = val!;
                        ref
                            .read(symsWeekChartProvider.notifier)
                            .getSymsWeekDaysChart(ref.watch(symsIdProvider).id!,
                                monthToInt(ref.watch(symsWeekProvider)));
                        setState(() {});
                      },
                      items: monthDropdownItems,
                      hint: const Text(''),
                      width: 70.w,
                      value: ref.watch(symsWeekProvider),
                    ),
                  ],
                ),
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
                            .read(symsWeekChartProvider.notifier)
                            .getSymsWeekDaysChart(ref.watch(symsIdProvider).id!,
                                monthToInt(ref.watch(symsWeekProvider)));
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
                            maxY: 10,
                            borderData: FlBorderData(
                              show: false,
                            ),
                            gridData: const FlGridData(show: false),
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                      toY: state.symsWeekChartModel!.week1!
                                          .toDouble(),
                                      color: const Color(0xffE34131))
                                ],
                              ),
                              BarChartGroupData(x: 1, barRods: [
                                BarChartRodData(
                                    toY: state.symsWeekChartModel!.week2!
                                        .toDouble(),
                                    color: const Color(0xffE34131))
                              ]),
                              BarChartGroupData(x: 2, barRods: [
                                BarChartRodData(
                                    toY: state.symsWeekChartModel!.week3!
                                        .toDouble(),
                                    color: const Color(0xffE34131))
                              ]),
                              BarChartGroupData(x: 3, barRods: [
                                BarChartRodData(
                                    toY: state.symsWeekChartModel!.week4!
                                        .toDouble(),
                                    color: const Color(0xffE34131))
                              ]),
                              BarChartGroupData(x: 4, barRods: [
                                BarChartRodData(
                                    toY: state.symsWeekChartModel!.week5!
                                        .toDouble(),
                                    color: const Color(0xffE34131))
                              ]),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                  axisNameWidget: CustomText(
                                    'Average Pain Level',
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
                                          0 => 'Week1',
                                          1 => 'Week2',
                                          2 => 'Week3',
                                          3 => 'Week4',
                                          4 => 'Week5',
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
