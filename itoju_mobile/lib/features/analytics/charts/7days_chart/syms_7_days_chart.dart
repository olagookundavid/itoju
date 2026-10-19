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

/// Catalog id of "Headache", the chart's starting symptom until the user (or the
/// analytics screen, from what they actually log) picks another.
const int kDefaultSymptomId = 21;

final symsIdProvider = StateProvider<SymptomsModel>((ref) {
  return SymptomsModel(kDefaultSymptomId, "Headache");
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
                            barGroups: chartSymsData(state.syms7ChartModel!),
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

List<BarChartGroupData> chartSymsData(Syms7ChartModel model) {
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
