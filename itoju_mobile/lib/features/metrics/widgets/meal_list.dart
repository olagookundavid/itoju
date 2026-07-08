import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/metrics/notifiers/food_metric_notifier.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/custom_text_field.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class MealList extends ConsumerStatefulWidget {
  const MealList(
    this.name,
    this.img, {super.key, 
    required this.date,
    required this.foodModel,
  });
  final String date, name, img;
  final FoodMetricModel foodModel;
  @override
  ConsumerState<MealList> createState() => _MealListState();
}

class _MealListState extends ConsumerState<MealList> {
  final List tagsList = [
    'Gluten',
    'Dairy',
    'Sugar',
    'Red Meat',
    'Soy',
    'Caffeine'
  ];
  final Set userTags = {};
  Set tester = {};
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      mealCtrl.text = (widget.name.toLowerCase() == 'breakfast'
          ? widget.foodModel.breakfastMeal
          : widget.name.toLowerCase() == 'lunch'
              ? widget.foodModel.lunchMeal
              : widget.foodModel.dinnerMeal)!;
      extraCtrl.text = (widget.name.toLowerCase() == 'breakfast'
          ? widget.foodModel.breakfastExtra
          : widget.name.toLowerCase() == 'lunch'
              ? widget.foodModel.lunchExtra
              : widget.foodModel.dinnerExtra)!;
      fruitCtrl.text = (widget.name.toLowerCase() == 'breakfast'
          ? widget.foodModel.breakfastFruit
          : widget.name.toLowerCase() == 'lunch'
              ? widget.foodModel.lunchFruit
              : widget.foodModel.dinnerFruit)!;
      final tags = (widget.name.toLowerCase() == 'breakfast'
          ? widget.foodModel.breakfastTags
          : widget.name.toLowerCase() == 'lunch'
              ? widget.foodModel.lunchTags
              : widget.foodModel.dinnerTags);
      for (String tag in tags!) {
        userTags.add(tag);
      }
      setState(() {});
    });
    super.initState();
  }

  final mealCtrl = TextEditingController();
  final extraCtrl = TextEditingController();
  final fruitCtrl = TextEditingController();

  @override
  void dispose() {
    mealCtrl.dispose();
    extraCtrl.dispose();
    fruitCtrl.dispose();
    super.dispose();
  }

  bool isSaveVisible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        10.ph,
        Container(
          height: 60.h,
          width: double.infinity,
          padding: EdgeInsets.all(10.h),
          decoration: BoxDecoration(
              color: AppColors.primaryColorPurple,
              borderRadius: BorderRadius.circular(15.r)),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                    color: AppColors.splash_underlay,
                    borderRadius: BorderRadius.circular(5.r)),
                child: SvgPicture.asset(
                  'asset/svg/${widget.img}.svg',
                  width: 20.w,
                  height: 20.h,
                ),
              ),
              18.pw,
              CustomText(
                widget.name,
                fontSize: 14.sp,
                color: Colors.white,
              ),
              const Spacer(),
              Container(
                height: 30.h,
                width: 30.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(color: Colors.white, width: 2.w)),
                child: Center(
                    child: InkWell(
                  onTap: () {
                    setState(() {
                      if (tester.contains(widget.foodModel.id)) {
                        tester.clear();
                        return;
                      }
                      tester.clear();
                      tester.add(widget.foodModel.id);
                    });
                  },
                  child: Icon(
                    !tester.contains(widget.foodModel.id)
                        ? Icons.add
                        : Icons.close,
                    color: Colors.white,
                  ),
                )),
              )
            ],
          ),
        ),
        10.ph,
        Visibility(
          visible: tester.contains(widget.foodModel.id),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 10.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: const Color(0xffEEEDF8),
                border: Border.all(color: const Color(0xffEEEDF8))),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.ph,
                Text('Main Meal',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColorPurple)),
                3.ph,
                CustomTextField(
                  controller: mealCtrl,
                  onChanged: (p0) {
                    setState(() {
                      isSaveVisible = true;
                    });
                  },
                ),
                20.ph,
                Text('Fruits',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColorPurple)),
                3.ph,
                CustomTextField(
                  controller: fruitCtrl,
                  onChanged: (p0) {
                    setState(() {
                      isSaveVisible = true;
                    });
                  },
                ),
                20.ph,
                Text('Extra',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColorPurple)),
                3.ph,
                CustomTextField(
                  controller: extraCtrl,
                  onChanged: (p0) {
                    setState(() {
                      isSaveVisible = true;
                    });
                  },
                ),
                15.ph,
                CustomText('Tags',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColorPurple),
                7.ph,
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: List.generate(tagsList.length, (index) {
                    final tag = tagsList[index];
                    return ActionChip(
                      label: Text(tag),
                      labelStyle: TextStyle(
                          color: userTags.contains(tag)
                              ? Colors.white
                              : Colors.black),
                      backgroundColor: userTags.contains(tag)
                          ? AppColors.primaryColorPurple.withOpacity(.85)
                          : null,
                      onPressed: () {
                        setState(() {
                          isSaveVisible = true;
                          if (userTags.contains(tag)) {
                            userTags.remove(tag);
                            return;
                          }
                          userTags.add(tag);
                        });
                      },
                    );
                  }),
                ),
                20.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: isSaveVisible,
                      child: CurvedButton(
                        text: 'Save',
                        loading: (ref.watch(foodMetricProvider).postStatus ==
                            Loader.loading),
                        onPressed: () async {
                          final model =
                              (widget.name.toLowerCase() == 'breakfast'
                                  ? FoodMetricModel(
                                      id: 0,
                                      breakfastMeal: mealCtrl.text,
                                      breakfastExtra: extraCtrl.text,
                                      breakfastFruit: fruitCtrl.text,
                                      breakfastTags: userTags.toList())
                                  : widget.name.toLowerCase() == 'lunch'
                                      ? FoodMetricModel(
                                          id: 0,
                                          lunchMeal: mealCtrl.text,
                                          lunchExtra: extraCtrl.text,
                                          lunchFruit: fruitCtrl.text,
                                          lunchTags: userTags.toList())
                                      : FoodMetricModel(
                                          id: 0,
                                          dinnerMeal: mealCtrl.text,
                                          dinnerExtra: extraCtrl.text,
                                          dinnerFruit: fruitCtrl.text,
                                          dinnerTags: userTags.toList()));

                          final response = await ref
                              .read(foodMetricProvider.notifier)
                              .updateFoodMetricMetric(widget.date, model);

                          if (response.successMessage.isNotEmpty) {
                            getAlert(response.successMessage, isWarning: false);
                            isSaveVisible = false;
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              ref
                                  .read(foodMetricProvider.notifier)
                                  .getFoodMetric(widget.date);
                            });
                          } else if (response.responseMessage!.isNotEmpty) {
                            getAlert(response.responseMessage!);
                          } else {
                            getAlert(response.errorMessage);
                          }
                        },
                        width: 150.w,
                        height: 45.h,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class SnackList extends ConsumerStatefulWidget {
  const SnackList({super.key, 
    required this.date,
    required this.foodModel,
  });
  final String date;
  final FoodMetricModel foodModel;
  @override
  ConsumerState<SnackList> createState() => _SnackListState();
}

class _SnackListState extends ConsumerState<SnackList> {
  final List tagsList = [
    'Gluten',
    'Dairy',
    'Sugar',
    'Red Meat',
    'Soy',
    'Caffeine'
  ];
  final Set userTags = {};
  Set tester = {};
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      snackCtrl.text = widget.foodModel.snackName!;
      final tags = (widget.foodModel.snackTags);
      for (String tag in tags!) {
        userTags.add(tag);
      }
      setState(() {});
    });
    super.initState();
  }

  final snackCtrl = TextEditingController();
  @override
  void dispose() {
    snackCtrl.dispose();
    super.dispose();
  }

  bool isSaveVisible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        10.ph,
        Container(
          height: 60.h,
          width: double.infinity,
          padding: EdgeInsets.all(10.h),
          decoration: BoxDecoration(
              color: AppColors.primaryColorPurple,
              borderRadius: BorderRadius.circular(15.r)),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                    color: AppColors.splash_underlay,
                    borderRadius: BorderRadius.circular(5.r)),
                child: SvgPicture.asset(
                  'asset/svg/snack.svg',
                  width: 20.w,
                  height: 20.h,
                ),
              ),
              18.pw,
              CustomText(
                'Snack',
                fontSize: 14.sp,
                color: Colors.white,
              ),
              const Spacer(),
              Container(
                height: 30.h,
                width: 30.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(color: Colors.white, width: 2.w)),
                child: Center(
                    child: InkWell(
                  onTap: () {
                    setState(() {
                      if (tester.contains(widget.foodModel.id)) {
                        tester.clear();
                        return;
                      }
                      tester.clear();
                      tester.add(widget.foodModel.id);
                    });
                  },
                  child: Icon(
                    !tester.contains(widget.foodModel.id)
                        ? Icons.add
                        : Icons.close,
                    color: Colors.white,
                  ),
                )),
              )
            ],
          ),
        ),
        10.ph,
        Visibility(
          visible: tester.contains(widget.foodModel.id),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 10.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: const Color(0xffEEEDF8),
                border: Border.all(color: const Color(0xffEEEDF8))),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.ph,
                Text('Name of Snack',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColorPurple)),
                3.ph,
                CustomTextField(
                  controller: snackCtrl,
                  onChanged: (p0) {
                    setState(() {
                      isSaveVisible = true;
                    });
                  },
                ),
                15.ph,
                CustomText('Tags',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColorPurple),
                7.ph,
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: List.generate(tagsList.length, (index) {
                    final tag = tagsList[index];
                    return ActionChip(
                      label: Text(tag),
                      labelStyle: TextStyle(
                          color: userTags.contains(tag)
                              ? Colors.white
                              : Colors.black),
                      backgroundColor: userTags.contains(tag)
                          ? AppColors.primaryColorPurple.withOpacity(.85)
                          : null,
                      onPressed: () {
                        setState(() {
                          isSaveVisible = true;
                          if (userTags.contains(tag)) {
                            userTags.remove(tag);
                            return;
                          }
                          userTags.add(tag);
                        });
                      },
                    );
                  }),
                ),
                20.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: isSaveVisible,
                      child: CurvedButton(
                        text: 'Save',
                        loading: (ref.watch(foodMetricProvider).postStatus ==
                            Loader.loading),
                        onPressed: () async {
                          final response = await ref
                              .read(foodMetricProvider.notifier)
                              .updateFoodMetricMetric(
                                  widget.date,
                                  FoodMetricModel(
                                      id: 0,
                                      snackName: snackCtrl.text,
                                      snackTags: userTags.toList()));

                          if (response.successMessage.isNotEmpty) {
                            getAlert(response.successMessage, isWarning: false);
                            isSaveVisible = false;
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              ref
                                  .read(foodMetricProvider.notifier)
                                  .getFoodMetric(widget.date);
                            });
                          } else if (response.responseMessage!.isNotEmpty) {
                            getAlert(response.responseMessage!);
                          } else {
                            getAlert(response.errorMessage);
                          }
                        },
                        width: 150.w,
                        height: 45.h,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class WhiteContainer extends StatelessWidget {
  const WhiteContainer({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.h,
      width: 100.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
      child: Center(
          child: Text(
        text,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      )),
    );
  }
}

class WaterList extends ConsumerStatefulWidget {
  const WaterList({super.key, 
    required this.date,
    required this.foodModel,
  });
  final String date;
  final FoodMetricModel foodModel;
  @override
  ConsumerState<WaterList> createState() => _WaterListState();
}

class _WaterListState extends ConsumerState<WaterList> {
  Set tester = {};
  int waterNo = 0;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      waterNo = widget.foodModel.glassNo!;
      setState(() {});
    });
    super.initState();
  }

  bool isSaveVisible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        10.ph,
        Container(
          height: 60.h,
          width: double.infinity,
          padding: EdgeInsets.all(10.h),
          decoration: BoxDecoration(
              color: AppColors.primaryColorPurple,
              borderRadius: BorderRadius.circular(15.r)),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                    color: AppColors.splash_underlay,
                    borderRadius: BorderRadius.circular(5.r)),
                child: SvgPicture.asset(
                  'asset/svg/water.svg',
                  width: 20.w,
                  height: 20.h,
                ),
              ),
              18.pw,
              CustomText(
                'Water',
                fontSize: 14.sp,
                color: Colors.white,
              ),
              const Spacer(),
              Container(
                height: 30.h,
                width: 30.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(color: Colors.white, width: 2.w)),
                child: Center(
                    child: InkWell(
                  onTap: () {
                    setState(() {
                      if (tester.contains(widget.foodModel.id)) {
                        tester.clear();
                        return;
                      }
                      tester.clear();
                      tester.add(widget.foodModel.id);
                    });
                  },
                  child: Icon(
                    !tester.contains(widget.foodModel.id)
                        ? Icons.add
                        : Icons.close,
                    color: Colors.white,
                  ),
                )),
              )
            ],
          ),
        ),
        10.ph,
        Visibility(
          visible: tester.contains(widget.foodModel.id),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 10.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: const Color(0xffEEEDF8),
                border: Border.all(color: const Color(0xffEEEDF8))),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                15.ph,
                Text(
                  '${waterNo * 250}ml',
                  style: TextStyle(
                      color: const Color(0xffFF9F00),
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700),
                ),
                10.ph,
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  InkWell(
                    onTap: () {
                      if (waterNo == 0) {
                        return;
                      }
                      setState(() {
                        isSaveVisible = true;
                        waterNo--;
                      });
                    },
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColorPurple,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 30.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  30.pw,
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r),
                        color: Colors.white),
                    child: SvgPicture.asset(
                      'asset/svg/water.svg',
                      width: 60.w,
                      height: 60.h,
                    ),
                  ),
                  30.pw,
                  InkWell(
                    onTap: () {
                      setState(() {
                        isSaveVisible = true;
                        waterNo++;
                      });
                    },
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColorPurple,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 30.r,
                        color: Colors.white,
                      ),
                    ),
                  )
                ]),
                15.ph,
                Text(
                  '$waterNo Glass of Water',
                  style: TextStyle(
                      color: AppColors.primaryColorPurple,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700),
                ),
                15.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: isSaveVisible,
                      child: CurvedButton(
                        text: 'Save',
                        loading: (ref.watch(foodMetricProvider).postStatus ==
                            Loader.loading),
                        onPressed: () async {
                          final response = await ref
                              .read(foodMetricProvider.notifier)
                              .updateFoodMetricMetric(widget.date,
                                  FoodMetricModel(id: 0, glassNo: waterNo));

                          if (response.successMessage.isNotEmpty) {
                            getAlert(response.successMessage, isWarning: false);
                            isSaveVisible = false;
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              ref
                                  .read(foodMetricProvider.notifier)
                                  .getFoodMetric(widget.date);
                            });
                          } else if (response.responseMessage!.isNotEmpty) {
                            getAlert(response.responseMessage!);
                          } else {
                            getAlert(response.errorMessage);
                          }
                        },
                        width: 150.w,
                        height: 45.h,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
