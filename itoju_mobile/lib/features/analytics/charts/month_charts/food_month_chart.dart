import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/analytics/charts/7days_chart/food_7_days_chart.dart';
import 'package:itoju_mobile/features/analytics/charts/week_charts/syms_week_chart.dart';
import 'package:itoju_mobile/features/analytics/notifiers/month_chart_notifier/food_diary_month_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/notifiers/week_charts_notifier/food_week_day_chart_notifier.dart';
import 'package:itoju_mobile/features/analytics/widgets/color_tile.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

final foodYearProvider = StateProvider<String>((ref) {
  return DateTime.now().year.toString();
});

class FoodMonthChart extends ConsumerStatefulWidget {
  const FoodMonthChart({
    super.key,
  });

  @override
  ConsumerState<FoodMonthChart> createState() => _FoodMonthChartState();
}

class _FoodMonthChartState extends ConsumerState<FoodMonthChart> {
  List<String> dropdownItems = [
    'General',
    'Gluten',
    'Dairy',
    'Sugar',
    'Red Meat',
    'Soy',
    'Caffeine'
  ];
  List<String> yearDropdownItems = [...getLastNYears(5)];
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodDiaryMonthChartProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                          .read(foodDiaryMonthChartProvider.notifier)
                          .getFoodDiaryMonthDaysChart(
                              ref.watch(foodNameProvider),
                              ref.watch(foodYearProvider));
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
                      if (ref.watch(foodYearProvider) == val) {
                        return;
                      }
                      ref.read(foodYearProvider.notifier).state = val!;
                      ref
                          .read(foodDiaryMonthChartProvider.notifier)
                          .getFoodDiaryMonthDaysChart(
                              ref.watch(foodNameProvider),
                              ref.watch(foodYearProvider));
                      setState(() {});
                    },
                    items: yearDropdownItems,
                    hint: const Text(''),
                    width: 70.w,
                    value: ref.watch(foodYearProvider),
                  ),
                ],
              ),
            ),
          ],
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
                            .read(foodDiaryMonthChartProvider.notifier)
                            .getFoodDiaryMonthDaysChart(
                                ref.watch(foodNameProvider),
                                ref.watch(foodYearProvider));
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
                                      state.foodDiary7ChartModel!.jan!)
                                ]),
                                BarChartGroupData(x: 1, barRods: [
                                  ...transformToBarChartRodData(
                                      state.foodDiary7ChartModel!.feb!)
                                ]),
                                BarChartGroupData(x: 2, barRods: [
                                  ...transformToBarChartRodData(
                                      state.foodDiary7ChartModel!.mar!)
                                ]),
                                BarChartGroupData(x: 3, barRods: [
                                  ...transformToBarChartRodData(
                                      state.foodDiary7ChartModel!.apr!)
                                ]),
                                BarChartGroupData(x: 4, barRods: [
                                  ...transformToBarChartRodData(
                                      state.foodDiary7ChartModel!.may!)
                                ]),
                                BarChartGroupData(x: 5, barRods: [
                                  ...transformToBarChartRodData(
                                      state.foodDiary7ChartModel!.jun!)
                                ]),
                                BarChartGroupData(x: 6, barRods: [
                                  ...transformToBarChartRodData(
                                      state.foodDiary7ChartModel!.jul!)
                                ]),
                                BarChartGroupData(x: 7, barRods: [
                                  ...transformToBarChartRodData(
                                      state.foodDiary7ChartModel!.aug!)
                                ]),
                                BarChartGroupData(x: 8, barRods: [
                                  ...transformToBarChartRodData(
                                      state.foodDiary7ChartModel!.sept!)
                                ]),
                                BarChartGroupData(x: 9, barRods: [
                                  ...transformToBarChartRodData(
                                      state.foodDiary7ChartModel!.oct!)
                                ]),
                                BarChartGroupData(x: 10, barRods: [
                                  ...transformToBarChartRodData(
                                      state.foodDiary7ChartModel!.nov!)
                                ]),
                                BarChartGroupData(x: 11, barRods: [
                                  ...transformToBarChartRodData(
                                      state.foodDiary7ChartModel!.dec!)
                                ]),
                              ],
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
