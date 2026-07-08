import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/analytics/charts/7days_chart/food_7_days_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/7days_chart/syms_7_days_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/month_charts/bowel_month_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/month_charts/exercise_month_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/month_charts/food_month_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/month_charts/syms_month_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/week_charts/bowel_week_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/week_charts/exercise_week_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/week_charts/food_week_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/week_charts/syms_week_chart.dart';
import 'package:itoju_mobile/features/analytics/days_chart_screen.dart';
import 'package:itoju_mobile/features/analytics/month_chart_screen.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/bowel_7_day_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/exercise_7_day_chart_notifier%20.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/food_diary_7_day_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/syms_7_day_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/month_chart_notifier/bowel_month_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/month_chart_notifier/exercise_month_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/month_chart_notifier/food_diary_month_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/month_chart_notifier/syms_month_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/week_charts_notifier/bowel_week_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/week_charts_notifier/exercise_week_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/week_charts_notifier/food_week_day_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/week_charts_notifier/syms_week_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/widgets/helper_funcs.dart';
import 'package:itoju_mobile/features/analytics/widgets/tabs.dart';
import 'package:itoju_mobile/features/analytics/week_chart_screen.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  List<AppTabModel> dataTabList = [
    AppTabModel(title: "7 Days"),
    AppTabModel(title: "Month"),
    AppTabModel(title: "Year"),
  ];
  int tabValue = 0;
  Future<void> _handleRefresh() async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      tabValue == 0
          ? refreshDayAnalytics()
          : tabValue == 1
              ? refreshWeekAnalytics()
              : refreshMonthAnalytics();
    });
  }

  // secTimer() async {
  //   await Future.delayed(const Duration(milliseconds: 5));
  // }
  static const time = 2000;

  init() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      refreshDayAnalytics();
      await Future.delayed(const Duration(milliseconds: time));
      refreshWeekAnalytics();
      await Future.delayed(const Duration(milliseconds: time));
      refreshMonthAnalytics();
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  refreshDayAnalytics() async {
    ref
        .read(syms7ChartProvider.notifier)
        .getSyms7DaysChart(ref.watch(symsIdProvider).id!);
    ref
        .read(foodDiary7ChartProvider.notifier)
        .getFoodDiary7DaysChart(ref.watch(foodNameProvider));
    await Future.delayed(const Duration(milliseconds: time));
    ref.read(bowel7ChartProvider.notifier).getBowel7DaysChart();
    ref.read(exercise7ChartProvider.notifier).getExercise7DaysChart();
  }

  refreshWeekAnalytics() async {
    ref.read(symsWeekChartProvider.notifier).getSymsWeekDaysChart(
        ref.watch(symsIdProvider).id!, monthToInt(ref.watch(symsWeekProvider)));
    ref.read(foodDiaryWeekChartProvider.notifier).getFoodDiaryWeekDaysChart(
        ref.watch(foodNameProvider), monthToInt(ref.watch(foodWeekProvider)));
    await Future.delayed(const Duration(milliseconds: time));
    ref
        .read(bowelWeekChartProvider.notifier)
        .getBowelWeekDaysChart(monthToInt(ref.watch(bowelWeekProvider)));
    ref
        .read(exerciseWeekChartProvider.notifier)
        .getExerciseWeekDaysChart(monthToInt(ref.watch(exerciseWeekProvider)));
  }

  refreshMonthAnalytics() async {
    ref.read(symsMonthChartProvider.notifier).getSymsMonthDaysChart(
        ref.watch(symsIdProvider).id!, ref.watch(symsYearProvider));
    ref.read(foodDiaryMonthChartProvider.notifier).getFoodDiaryMonthDaysChart(
        ref.watch(foodNameProvider), ref.watch(foodYearProvider));
    await Future.delayed(const Duration(milliseconds: time));
    ref
        .read(bowelMonthChartProvider.notifier)
        .getBowelMonthDaysChart(ref.watch(bowelYearProvider));
    ref
        .read(exerciseMonthChartProvider.notifier)
        .getExerciseMonthDaysChart(ref.watch(exerciseYearProvider));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primaryColorPurple,
        onRefresh: _handleRefresh,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      color: AppColors.splash_underlay,
                    ),
                    child: Text(
                      'Analytics',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColorPurple),
                    )),
                15.ph,
                Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10.r)),
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    child: Center(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => AppTabHeader(
                          fontSize: 13.sp,
                          width: 105.w,
                          currentTab: tabValue,
                          index: index,
                          item: dataTabList[index],
                          onTap: () {
                            tabValue = index;
                            setState(() {});
                          },
                        ),
                        separatorBuilder: (context, item) => 8.pw,
                        itemCount: dataTabList.length,
                      ),
                    )),
                15.ph,
                Expanded(
                    child: tabValue == 0
                        ? const DaysAnalyticChart()
                        : tabValue == 1
                            ? const WeekAnalyticChart()
                            : const MonthAnalyticChart())
              ],
            ),
          ),
        ),
      ),
    );
  }
}
