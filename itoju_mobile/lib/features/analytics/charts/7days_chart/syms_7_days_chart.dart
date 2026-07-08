import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/analytics/charts/syms_chart_bottom_sheet.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/syms_7_day_chart_notifier.dart';
import 'package:itoju_mobile/features/metrics/notifiers/symptoms_notifier.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

final symsIdProvider = StateProvider<SymptomsModel>((ref) {
  return SymptomsModel(21, "Headache");
});

class Symptoms7DaysChart extends ConsumerStatefulWidget {
  const Symptoms7DaysChart({
    super.key,
  });

  @override
  ConsumerState<Symptoms7DaysChart> createState() => _Symptoms7DaysChartState();
}

class _Symptoms7DaysChartState extends ConsumerState<Symptoms7DaysChart> {
  SymptomsModel? sym;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(syms7ChartProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
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
            ref
                .read(syms7ChartProvider.notifier)
                .getSyms7DaysChart(ref.watch(symsIdProvider).id!);
            setState(() {});
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
                  ref.watch(symsIdProvider).name,
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
                            .read(syms7ChartProvider.notifier)
                            .getSyms7DaysChart(ref.watch(symsIdProvider).id!);
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
                            barGroups: chartSymsData([
                              state.syms7ChartModel!.mon!.toDouble(),
                              state.syms7ChartModel!.tue!.toDouble(),
                              state.syms7ChartModel!.wed!.toDouble(),
                              state.syms7ChartModel!.thur!.toDouble(),
                              state.syms7ChartModel!.fri!.toDouble(),
                              state.syms7ChartModel!.sat!.toDouble(),
                              state.syms7ChartModel!.sun!.toDouble()
                            ]),
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

  // debugLog(reorderedData);
  return reorderedData;
}
