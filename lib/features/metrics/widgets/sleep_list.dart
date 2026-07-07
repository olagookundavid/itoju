import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/dashboard/widgets/slider_and_value.dart';
import 'package:itoju_mobile/features/metrics/notifiers/sleep_notifier.dart';
import 'package:itoju_mobile/features/metrics/pages/sleep.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/date_pick_widget.dart';
import 'package:itoju_mobile/features/widgets/dates.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class SleepList extends ConsumerStatefulWidget {
  const SleepList(
    this.name,
    this.isNight,
    this.isNew, {
    super.key,
    required this.date,
    required this.sleepModel,
  });
  final String date, name;

  final SleepModel sleepModel;
  final bool isNight, isNew;
  @override
  ConsumerState<SleepList> createState() => _SleepListState();
}

class _SleepListState extends ConsumerState<SleepList> {
  final List tagsList = [
    'Early bedtime',
    'Late bedtime',
    'No Dream',
    'Nightmare',
    'Overslept',
    'Pleasant Dream'
  ];
  final Set userTags = {};
  double sev = 0;
  DateTime? slept;
  DateTime? wokeUp;
  String timeSlept = '';
  String timeWokeUp = '';

  final Set dayTags = {timeOfDay()};
  Set tester = {};
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      sev = widget.sleepModel.severity;
      timeSlept = widget.sleepModel.timeSlept!;
      slept = convertTimeStringToDateTime(timeSlept);
      timeWokeUp = widget.sleepModel.timeWokeUp!;
      wokeUp = convertTimeStringToDateTime(timeWokeUp);
      duration = calculateTimeDifference(slept, wokeUp);
      final tags = (widget.sleepModel.tags);
      for (String tag in tags) {
        userTags.add(tag);
      }
      setState(() {});
    });
    super.initState();
  }

  bool isSaveVisible = false;
  String duration = "00h 00m";
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
                  'asset/svg/${widget.isNight != true ? 'day' : 'night'}_time.svg',
                  width: 20.w,
                  height: 20.h,
                ),
              ),
              18.pw,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    widget.name,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  CustomText(
                    '${widget.sleepModel.timeSlept} - ${widget.sleepModel.timeWokeUp} ',
                    fontSize: 10.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  )
                ],
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
                      if (tester.contains(widget.sleepModel.id)) {
                        tester.clear();
                        return;
                      }
                      tester.clear();
                      tester.add(widget.sleepModel.id);
                    });
                  },
                  child: Icon(
                    !tester.contains(widget.sleepModel.id)
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
          visible: tester.contains(widget.sleepModel.id),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 10.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: const Color(0xffEEEDF8),
                border: Border.all(color: const Color(0xffEEEDF8))),
            width: double.infinity,
            child: Column(
              children: [
                15.ph,
                CustomText(
                  'Sleep Duration',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColorPurple,
                ),
                10.ph,
                CustomText(
                  duration,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xffFF9F00),
                ),
                12.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        CustomText(
                          'Slept',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColorPurple,
                        ),
                        10.ph,
                        InkWell(
                          onTap: () async {
                            isSaveVisible = true;
                            slept = await showDateTimePicker(context: context);
                            timeSlept =
                                DateFormatter.formatTime(slept.toString());
                            wokeUp = null;
                            timeWokeUp = '';
                            duration = calculateTimeDifference(slept, wokeUp);
                            setState(() {});
                          },
                          child: WhiteContainer(text: timeSlept),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        CustomText(
                          'Woke Up',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColorPurple,
                        ),
                        10.ph,
                        InkWell(
                            onTap: () async {
                              isSaveVisible = true;
                              wokeUp = await showDateTimePicker(
                                  context: context,
                                  initialDate: slept,
                                  firstDate: slept);
                              timeWokeUp =
                                  DateFormatter.formatTime(wokeUp.toString());
                              duration = calculateTimeDifference(slept, wokeUp);
                              setState(() {});
                            },
                            child: WhiteContainer(text: timeWokeUp))
                      ],
                    )
                  ],
                ),
                15.ph,
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    'How rested do you feel?',
                    color: AppColors.primaryColorPurple,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                5.ph,
                SliderAndValue(
                    onchanged: (value) {
                      isSaveVisible = true;
                      sev = value;
                      setState(() {});
                    },
                    sev: sev),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomText(
                      'Barely',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: sev < .33
                          ? AppColors.primaryColorPurple
                          : Colors.grey,
                    ),
                    CustomText(
                      'Moderately',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: sev > .33 && sev < .67
                          ? AppColors.primaryColorPurple
                          : Colors.grey,
                    ),
                    CustomText(
                      'Fully',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: sev > .67
                          ? AppColors.primaryColorPurple
                          : Colors.grey,
                    ),
                  ],
                ),
                10.ph,
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText('Tags',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColorPurple),
                ),
                7.ph,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
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
                ),
                20.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    Visibility(
                      visible: isSaveVisible,
                      child: CurvedButton(
                        text: widget.isNew ? 'Create' : 'Save',
                        loading: (ref.watch(sleepProvider).postStatus ==
                                Loader.loading ||
                            ref.watch(sleepProvider).updateStatus ==
                                Loader.loading),
                        onPressed: () async {
                          final response = await (widget.isNew
                              ? ref
                                  .read(sleepProvider.notifier)
                                  .createSleepMetric(
                                      widget.date,
                                      SleepModel(
                                          id: 0,
                                          timeSlept: timeSlept,
                                          timeWokeUp: timeWokeUp,
                                          tags: userTags.toList(),
                                          severity: sev,
                                          isNight: widget.isNight))
                              : ref
                                  .read(sleepProvider.notifier)
                                  .updateSleepMetric(
                                      widget.sleepModel.id!,
                                      SleepModel(
                                          id: 0,
                                          timeSlept: timeSlept,
                                          timeWokeUp: timeWokeUp,
                                          tags: userTags.toList(),
                                          severity: sev,
                                          isNight: widget.isNight)));

                          if (response.successMessage.isNotEmpty) {
                            getAlert(response.successMessage, isWarning: false);
                            isSaveVisible = false;
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              ref
                                  .read(sleepProvider.notifier)
                                  .getSleepList(widget.date);
                              ref.read(addSleepProvider.notifier).state = false;
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
                    Spacer(flex: widget.isNew ? 3 : 2),
                    if (!widget.isNew)
                      IconButton(
                          onPressed: () async {
                            final response = await ref
                                .read(sleepProvider.notifier)
                                .deleteSleepMetric(widget.sleepModel.id!);

                            if (response.successMessage.isNotEmpty) {
                              getAlert(response.successMessage,
                                  isWarning: false);
                              SchedulerBinding.instance
                                  .addPostFrameCallback((timeStamp) async {
                                ref
                                    .read(sleepProvider.notifier)
                                    .getSleepList(widget.date);
                              });
                            } else if (response.responseMessage!.isNotEmpty) {
                              getAlert(response.responseMessage!);
                            } else {
                              getAlert(response.errorMessage);
                            }
                          },
                          iconSize: 25.r,
                          color: Colors.red.shade500,
                          icon: ref.watch(sleepProvider).delStatus ==
                                  Loader.loading
                              ? const CircularProgressIndicator.adaptive(
                                  backgroundColor: Colors.red)
                              : const Icon(Icons.delete_forever_rounded))
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
