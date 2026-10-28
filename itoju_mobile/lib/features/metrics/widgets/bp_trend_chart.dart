import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/data/today_logic.dart';
import 'package:itoju_mobile/features/metrics/notifiers/bp_notifier.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

/// Series colours: the first three slots of the validated categorical palette
/// (blue, orange, aqua), which are safe for colour-blind readers when used
/// together. Aqua is under 3:1 against white, so identity is never colour alone:
/// the legend names each line with its latest value, taps show a tooltip, and
/// every number is available in the table under the chart.
const Color kSystolicColor = Color(0xff2a78d6);
const Color kDiastolicColor = Color(0xffeb6834);
const Color kPulseColor = Color(0xff1baf7a);

/// The 3-line chart on its own. [days] is the window length ending on [end];
/// days with no reading have no point (lines join the days that do).
class BpTrendChart extends StatelessWidget {
  const BpTrendChart({
    super.key,
    required this.points,
    required this.end,
    required this.days,
  });

  final List<BpDayPoint> points;
  final DateTime end;
  final int days;

  DateTime get _start => addCalendarDays(end, -(days - 1));

  double _x(String date) =>
      calendarDaysBetween(_start, DateTime.parse(date)).toDouble();

  @override
  Widget build(BuildContext context) {
    final inRange = points
        .where((p) => _x(p.date) >= 0 && _x(p.date) <= days - 1)
        .toList();
    if (inRange.isEmpty) return const SizedBox.shrink();
    final all = [
      for (final p in inRange) ...[p.systolic, p.diastolic, p.pulse]
    ];
    final lo = all.reduce(math.min);
    final hi = all.reduce(math.max);
    final minY = math.max(0, ((lo - 10) / 10).floorToDouble() * 10).toDouble();
    final maxY = ((hi + 10) / 10).ceilToDouble() * 10;
    final step = (maxY - minY) > 120 ? 40.0 : 20.0;

    LineChartBarData line(Color c, double Function(BpDayPoint) v) =>
        LineChartBarData(
          spots: [for (final p in inRange) FlSpot(_x(p.date), v(p))],
          color: c,
          barWidth: 2,
          isCurved: false,
          isStrokeCapRound: true,
          isStrokeJoinRound: true,
          // 8px markers with a 2px white ring so overlapping points stay legible.
          dotData: FlDotData(
            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
              radius: 4,
              color: c,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
        );

    final dayFmt = DateFormat('EEE');
    final longFmt = DateFormat('d MMM');
    final labelEvery = days <= 7 ? 1 : 7;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (days - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          line(kSystolicColor, (p) => p.systolic),
          line(kDiastolicColor, (p) => p.diastolic),
          line(kPulseColor, (p) => p.pulse),
        ],
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: step,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.greyPrimary, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32.w,
              interval: step,
              getTitlesWidget: (v, meta) => SideTitleWidget(
                meta: meta,
                child: Text(v.toInt().toString(),
                    style: TextStyle(color: AppColors.hintGrey, fontSize: 10.sp)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26.h,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                // Whole days only; for 30 days label the first of each week.
                if (v != i.toDouble() || i % labelEvery != 0) {
                  return const SizedBox.shrink();
                }
                final d = addCalendarDays(_start, i);
                return SideTitleWidget(
                  meta: meta,
                  child: Text(days <= 7 ? dayFmt.format(d) : longFmt.format(d),
                      style:
                          TextStyle(color: AppColors.hintGrey, fontSize: 10.sp)),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.textGrey,
            getTooltipItems: (touched) {
              if (touched.isEmpty) return [];
              final d = addCalendarDays(_start, touched.first.x.toInt());
              return [
                for (var i = 0; i < touched.length; i++)
                  LineTooltipItem(
                    // Date once, on the first row; then "Systolic 122" etc.
                    '${i == 0 ? '${longFmt.format(d)}\n' : ''}'
                    '${const ['Systolic', 'Diastolic', 'Pulse'][touched[i].barIndex]} '
                    '${touched[i].y.round()}',
                    const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
              ];
            },
          ),
        ),
      ),
    );
  }
}

/// The card the BP page shows: 7 / 30 day toggle, legend with the latest values,
/// the chart, and a table of the same numbers.
class BpTrendCard extends ConsumerStatefulWidget {
  const BpTrendCard({super.key});

  @override
  ConsumerState<BpTrendCard> createState() => _BpTrendCardState();
}

class _BpTrendCardState extends ConsumerState<BpTrendCard> {
  int _days = 7;

  @override
  Widget build(BuildContext context) {
    final trend = ref.watch(bpTrendProvider(_days));
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8FC),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Trend',
                  style: TextStyle(
                      color: AppColors.primaryColorPurple,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              for (final d in const [7, 30]) ...[
                ChoiceChip(
                  label: Text('$d days'),
                  selected: _days == d,
                  selectedColor: AppColors.primaryColorPurple,
                  labelStyle: TextStyle(
                      fontSize: 11.sp,
                      color: _days == d
                          ? Colors.white
                          : AppColors.primaryColorPurple),
                  onSelected: (_) => setState(() => _days = d),
                ),
                if (d == 7) 6.pw,
              ],
            ],
          ),
          10.ph,
          trend.when(
            loading: () => SizedBox(height: 220.h),
            error: (_, __) => const Text('Could not load your readings'),
            data: (points) {
              if (points.isEmpty) {
                return SizedBox(
                  height: 120.h,
                  child: Center(
                    child: Text(
                      'Add a few readings and your trend will appear here',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.hintGrey, fontSize: 12.sp),
                    ),
                  ),
                );
              }
              final latest = points.last;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 14.w,
                    runSpacing: 4.h,
                    children: [
                      _LegendItem('Systolic', kSystolicColor, latest.systolic),
                      _LegendItem('Diastolic', kDiastolicColor, latest.diastolic),
                      _LegendItem('Pulse', kPulseColor, latest.pulse),
                    ],
                  ),
                  4.ph,
                  Text(
                    'mmHg for blood pressure, beats per minute for pulse',
                    style: TextStyle(color: AppColors.hintGrey, fontSize: 10.sp),
                  ),
                  12.ph,
                  SizedBox(
                    height: 220.h,
                    child: BpTrendChart(
                        points: points, end: DateTime.now(), days: _days),
                  ),
                  _BpTable(points: points),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.label, this.color, this.value);
  final String label;
  final Color color;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Line-key with a dot, matching the mark on the chart.
        SizedBox(
          width: 22.w,
          height: 10.h,
          child: Stack(alignment: Alignment.center, children: [
            Container(height: 2, color: color),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2)),
            ),
          ]),
        ),
        6.pw,
        // Text wears text colours, never the series colour.
        Text('$label ${value.round()}',
            style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _BpTable extends StatelessWidget {
  const _BpTable({required this.points});
  final List<BpDayPoint> points;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE d MMM');
    TextStyle head() => TextStyle(
        color: AppColors.hintGrey, fontSize: 11.sp, fontWeight: FontWeight.w600);
    TextStyle cell() => TextStyle(color: AppColors.textGrey, fontSize: 12.sp);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text('View as table',
            style: TextStyle(
                color: AppColors.primaryColorPurple,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600)),
        children: [
          Table(
            columnWidths: const {0: FlexColumnWidth(2.2)},
            children: [
              TableRow(children: [
                Text('Day', style: head()),
                Text('Sys', style: head()),
                Text('Dia', style: head()),
                Text('Pulse', style: head()),
              ]),
              for (final p in points.reversed)
                TableRow(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Text(
                        '${fmt.format(DateTime.parse(p.date))}'
                        '${p.readings > 1 ? ' (avg of ${p.readings})' : ''}',
                        style: cell()),
                  ),
                  Text('${p.systolic.round()}', style: cell()),
                  Text('${p.diastolic.round()}', style: cell()),
                  Text('${p.pulse.round()}', style: cell()),
                ]),
            ],
          ),
        ],
      ),
    );
  }
}
