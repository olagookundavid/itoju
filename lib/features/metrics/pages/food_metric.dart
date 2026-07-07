import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/metrics/notifiers/food_metric_notifier.dart';
import 'package:itoju_mobile/features/metrics/widgets/meal_list.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/top_note.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class FoodMetric extends ConsumerStatefulWidget {
  const FoodMetric(this.intialDate, {super.key});
  final DateTime intialDate;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FoodMetricState();
}

class _FoodMetricState extends ConsumerState<FoodMetric> {
  @override
  void initState() {
    selectedDate = widget.intialDate;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref
          .read(foodMetricProvider.notifier)
          .getFoodMetric(DateFormat('yyyy-MM-dd').format(selectedDate!));
    });
    super.initState();
  }

  DateTime? selectedDate;
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodMetricProvider);
    bool ifToday = (selectedDate == null ||
        ((selectedDate?.day == DateTime.now().day) &&
            (selectedDate?.month == DateTime.now().month)));
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          children: [
            SizedBox(
              height: 120.h,
              child: Column(
                children: [
                  const Row(
                    children: [
                      CustomBackButton(),
                      TopNote(text: 'Let’s record your today’s diet')
                    ],
                  ),
                  5.ph,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        '${ifToday ? 'Today' : ''} ${DateFormat('EEE').format(selectedDate!)} ${(selectedDate)!.day} ${ifToday ? '' : DateFormat.MMM().format(selectedDate!)}',
                        color: AppColors.primaryColorPurple,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      CurvedButton(
                        width: 120.w,
                        height: 35.h,
                        text: 'Change',
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate:
                                DateTime.now().subtract(const Duration(days: 90)),
                            lastDate: DateTime.now(),
                          ).then((value) {
                            setState(() {});
                            if (value != null) {
                              selectedDate = value;
                            }
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              ref
                                  .read(foodMetricProvider.notifier)
                                  .getFoodMetric(DateFormat('yyyy-MM-dd')
                                      .format(selectedDate!));
                            });
                          });
                        },
                      )
                    ],
                  ),
                  10.ph,
                ],
              ),
            ),
            state.status == Loader.loading
                ? const AppLoader()
                : state.status == Loader.error
                    ? ErrorCon(
                        func: () {
                          SchedulerBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            ref.read(foodMetricProvider.notifier).getFoodMetric(
                                DateFormat('yyyy-MM-dd').format(selectedDate!));
                          });
                        },
                      )
                    : Expanded(
                        child: ListView(
                        shrinkWrap: true,
                        children: [
                          MealList('BreakFast', 'breakfast',
                              foodModel: state.foodModel!,
                              date: DateFormat('yyyy-MM-dd')
                                  .format(selectedDate!)),
                          MealList('Lunch', 'lunch',
                              foodModel: state.foodModel!,
                              date: DateFormat('yyyy-MM-dd')
                                  .format(selectedDate!)),
                          MealList('Dinner', 'dinner',
                              foodModel: state.foodModel!,
                              date: DateFormat('yyyy-MM-dd')
                                  .format(selectedDate!)),
                          SnackList(
                              foodModel: state.foodModel!,
                              date: DateFormat('yyyy-MM-dd')
                                  .format(selectedDate!)),
                          WaterList(
                              foodModel: state.foodModel!,
                              date: DateFormat('yyyy-MM-dd')
                                  .format(selectedDate!))
                        ],
                      )),
            50.ph
          ],
        ),
      )),
    );
  }
}
