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
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/exercise_7_day_chart_notifier.dart';
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
import 'package:itoju_mobile/data/repositories/symptoms_repository.dart';
import 'package:itoju_mobile/features/landing/landing_page.dart';
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

  Future<void> _handleRefresh() async => _loadTab(tabValue);

  /// Fetches the charts for the given tab using the CURRENT selections. Called
  /// on first mount and every time a tab is opened, so switching to a tab
  /// always reloads it for the currently-selected symptom/food-tag/month/year
  /// — no manual refresh, and no stale data from a one-time initial fetch.
  /// All reads are local (Drift), so re-fetching on each switch is cheap.
  void _loadTab(int tab) {
    switch (tab) {
      case 0:
        refreshDayAnalytics();
      case 1:
        refreshWeekAnalytics();
      default:
        refreshMonthAnalytics();
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _useMostLoggedSymptomIfDefault();
      if (mounted) _loadTab(tabValue);
    });
  }

  /// The symptom charts default to Headache, which shows an empty chart for
  /// anyone who never logs it. If the user hasn't picked one yet, start from the
  /// symptom they actually log most. Never overrides an explicit choice.
  Future<void> _useMostLoggedSymptomIfDefault() async {
    final current = ref.read(symsIdProvider);
    if (current.id != kDefaultSymptomId) return;
    try {
      final top = await ref.read(symptomsRepositoryProvider).mostLogged();
      if (top != null && mounted) {
        ref.read(symsIdProvider.notifier).state = top;
      }
    } catch (_) {
      // Keep the default; the chart just stays on Headache.
    }
  }

  void refreshDayAnalytics() {
    ref
        .read(syms7ChartProvider.notifier)
        .getSyms7DaysChart(ref.read(symsIdProvider).id!);
    ref
        .read(foodDiary7ChartProvider.notifier)
        .getFoodDiary7DaysChart(ref.read(foodNameProvider));
    ref.read(bowel7ChartProvider.notifier).getBowel7DaysChart();
    ref.read(exercise7ChartProvider.notifier).getExercise7DaysChart();
  }

  void refreshWeekAnalytics() {
    ref.read(symsWeekChartProvider.notifier).getSymsWeekDaysChart(
        ref.read(symsIdProvider).id!, monthToInt(ref.read(symsWeekProvider)));
    ref.read(foodDiaryWeekChartProvider.notifier).getFoodDiaryWeekDaysChart(
        ref.read(foodNameProvider), monthToInt(ref.read(foodWeekProvider)));
    ref
        .read(bowelWeekChartProvider.notifier)
        .getBowelWeekDaysChart(monthToInt(ref.read(bowelWeekProvider)));
    ref
        .read(exerciseWeekChartProvider.notifier)
        .getExerciseWeekDaysChart(monthToInt(ref.read(exerciseWeekProvider)));
  }

  void refreshMonthAnalytics() {
    ref.read(symsMonthChartProvider.notifier).getSymsMonthDaysChart(
        ref.read(symsIdProvider).id!, ref.read(symsYearProvider));
    ref.read(foodDiaryMonthChartProvider.notifier).getFoodDiaryMonthDaysChart(
        ref.read(foodNameProvider), ref.read(foodYearProvider));
    ref
        .read(bowelMonthChartProvider.notifier)
        .getBowelMonthDaysChart(ref.read(bowelYearProvider));
    ref
        .read(exerciseMonthChartProvider.notifier)
        .getExerciseMonthDaysChart(ref.read(exerciseYearProvider));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(routeStateProvider, (previous, next) {
      if (next.index == 1) {
        _loadTab(tabValue);
      }
    });

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
                            // Reload the opened tab for the current selection,
                            // so Month/Year reflect the symptom/food-tag you
                            // picked on another tab (no manual refresh needed).
                            _loadTab(index);
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
