import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/food_diary_7_day_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/widgets/color_tile.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

final foodNameProvider = StateProvider<String>((ref) {
  return "General";
});

class Food7DaysChart extends ConsumerStatefulWidget {
  const Food7DaysChart({
    super.key,
  });

  @override
  ConsumerState<Food7DaysChart> createState() => _Food7DaysChartState();
}

class _Food7DaysChartState extends ConsumerState<Food7DaysChart> {
  List<String> dropdownItems = [
    'General',
    'Gluten',
    'Dairy',
    'Sugar',
    'Red Meat',
    'Soy',
    'Caffeine'
  ];
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodDiary7ChartProvider);
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
                  if (ref.watch(foodNameProvider) == val) {
                    return;
                  }
                  ref.read(foodNameProvider.notifier).state = val!;
                  ref
                      .read(foodDiary7ChartProvider.notifier)
                      .getFoodDiary7DaysChart(ref.watch(foodNameProvider));
                  setState(() {});
                },
                items: dropdownItems,
                hint: const Text(''),
                width: 70.w,
                value: ref.watch(foodNameProvider),
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
                            .read(foodDiary7ChartProvider.notifier)
                            .getFoodDiary7DaysChart(
                                ref.watch(foodNameProvider));
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
                            barGroups: chartFoodData(state.foodDiary7ChartModel!),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                  axisNameWidget: CustomText(
                                    'Number of times eaten',
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
                color: getColorForFoodDiary('Gluten'),
                text: 'Gluten',
              ),
              ColorTile(
                color: getColorForFoodDiary('Sugar'),
                text: 'Sugar',
              ),
              ColorTile(
                color: getColorForFoodDiary('Red Meat'),
                text: 'Red Meat',
              ),
              ColorTile(
                color: getColorForFoodDiary('Dairy'),
                text: 'Diary',
              ),
              ColorTile(
                color: getColorForFoodDiary('Soy'),
                text: 'Soy',
              ),
              ColorTile(
                color: getColorForFoodDiary('Caffeine'),
                text: 'Caffeine',
              ),
            ],
          ),
        )
      ],
    );
  }

  List<BarChartRodData> transformToBarChartRodData(
      List<FoodAnalyticsKeyValue> analyticsData) {
    return analyticsData.map((data) {
      return BarChartRodData(
        toY: data.value.toDouble(),
        color: getColorForFoodDiary(data.key),
      );
    }).toList();
  }

  List<BarChartGroupData> chartFoodData(FoodDiary7ChartModel model) {
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
        _ => const <FoodAnalyticsKeyValue>[],
      };
      groups.add(BarChartGroupData(
        x: pos,
        barRods: [...transformToBarChartRodData(val)],
      ));
    }
    return groups;
  }
}

Color getColorForFoodDiary(String food) {
  return switch (food) {
    'Gluten' => const Color(0xffFBD490),
    'Dairy' => const Color(0xffFF6963),
    'Sugar' => const Color(0xff99E6FF),
    'Red Meat' => const Color(0xff6A6AFB),
    'Soy' => const Color(0xff02A437),
    'Caffeine' => const Color(0xff6B88C7),
    _ => Colors.white,
  };
}

class DropdownExample extends StatefulWidget {
  final List<String> items;
  final Widget hint;
  final double width;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final String? value;

  const DropdownExample(
      {super.key,
      required this.items,
      this.width = 170,
      required this.hint,
      this.onChanged,
      this.validator,
      required this.value});

  @override
  DropdownExampleState createState() => DropdownExampleState();
}

class DropdownExampleState extends State<DropdownExample> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        elevation: 2,
        value: widget.value,
        hint: widget.hint,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.white,
        ),
        style: TextStyle(
          color: AppColors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        onChanged: widget.onChanged,
        dropdownColor: AppColors.primaryColorPurple,
        items: widget.items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: SizedBox(
              child: Text(
                value,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}


/*
chartFoodData([
                              state.foodDiary7ChartModel!.mon!.toDouble(),
                              state.foodDiary7ChartModel!.tue!.toDouble(),
                              state.foodDiary7ChartModel!.wed!.toDouble(),
                              state.foodDiary7ChartModel!.thur!.toDouble(),
                              state.foodDiary7ChartModel!.fri!.toDouble(),
                              state.foodDiary7ChartModel!.sat!.toDouble(),
                              state.foodDiary7ChartModel!.sun!.toDouble()
                            ])
*/