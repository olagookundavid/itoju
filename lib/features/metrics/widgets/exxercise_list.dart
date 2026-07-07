import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/metrics/notifiers/exercise_notifier.dart';
import 'package:itoju_mobile/features/metrics/widgets/sleep_list.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/custom_text_field.dart';
import 'package:itoju_mobile/features/widgets/date_pick_widget.dart';
import 'package:itoju_mobile/features/widgets/dates.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class ExerciseList extends ConsumerStatefulWidget {
  const ExerciseList({
    super.key,
    required this.exerciseMetric,
    required this.date,
  });
  final ExerciseModel exerciseMetric;
  final String date;
  @override
  ConsumerState<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends ConsumerState<ExerciseList> {
  final List tags = [
    'Satisfying',
    'Confident',
    'Energised',
    'Stressed',
    'Tired',
    'Weak',
  ];
  Set selectedTags = {};
  int noOfTimes = 0;
  Set tester = {};
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      textCtrl.text = widget.exerciseMetric.noOfTimes!.toString();
      timeStarted = widget.exerciseMetric.started!;
      started = convertTimeStringToDateTime(timeStarted);
      timeEnded = widget.exerciseMetric.ended!;
      ended = convertTimeStringToDateTime(timeEnded);
      duration = calculateTimeDifference(started, ended);
      final tags = (widget.exerciseMetric.tags) ?? [];
      for (String tag in tags) {
        selectedTags.add(tag);
      }
      setState(() {});
    });
    super.initState();
  }

  bool isSaveVisible = false;

  DateTime? started;
  DateTime? ended;
  String timeStarted = '';
  String timeEnded = '';

  String duration = "00h 00m";
  final TextEditingController textCtrl = TextEditingController();
  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }

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
                  'asset/svg/cough.svg',
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
                    widget.exerciseMetric.name,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  CustomText(
                    '${widget.exerciseMetric.started} - ${widget.exerciseMetric.ended} ',
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
                      if (tester.contains(widget.exerciseMetric.id)) {
                        tester.clear();
                        return;
                      }
                      tester.clear();
                      tester.add(widget.exerciseMetric.id);
                    });
                  },
                  child: Icon(
                    !tester.contains(widget.exerciseMetric.id)
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
          visible: tester.contains(widget.exerciseMetric.id),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 7.h),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: const Color(0xffEEEDF8),
                border: Border.all(color: const Color(0xffEEEDF8))),
            width: double.infinity,
            child: Column(
              children: [
                CustomText(
                  'Exercise duration',
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
                          'Start',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColorPurple,
                        ),
                        10.ph,
                        InkWell(
                          onTap: () async {
                            isSaveVisible = true;
                            started =
                                await showDateTimePicker(context: context);
                            timeStarted =
                                DateFormatter.formatTime(started.toString());
                            ended = null;
                            timeEnded = '';
                            duration = calculateTimeDifference(started, ended);
                            setState(() {});
                          },
                          child: WhiteContainer(text: timeStarted),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        CustomText(
                          'Ended',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColorPurple,
                        ),
                        10.ph,
                        InkWell(
                            onTap: () async {
                              isSaveVisible = true;
                              ended = await showDateTimePicker(
                                  context: context,
                                  initialDate: started,
                                  firstDate: started);
                              timeEnded =
                                  DateFormatter.formatTime(ended.toString());
                              duration =
                                  calculateTimeDifference(started, ended);
                              setState(() {});
                            },
                            child: WhiteContainer(text: timeEnded))
                      ],
                    )
                  ],
                ),
                25.ph,
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    'Number of times',
                    color: AppColors.primaryColorPurple,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                5.ph,
                CustomTextField(
                  controller: textCtrl,
                  filled: true,
                  inputType: TextInputType.number,
                  onChanged: (p0) {
                    isSaveVisible = true;
                    setState(() {});
                  },
                ),
                7.ph,
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    'Tags',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColorPurple,
                  ),
                ),
                5.ph,
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: List.generate(tags.length, (index) {
                    final tag = tags[index];
                    return ActionChip(
                      label: Text(tag),
                      labelStyle: TextStyle(
                          color: selectedTags.contains(tag)
                              ? Colors.white
                              : Colors.black),
                      backgroundColor: selectedTags.contains(tag)
                          ? AppColors.primaryColorPurple.withOpacity(.85)
                          : null,
                      onPressed: () {
                        setState(() {
                          isSaveVisible = true;
                          if (selectedTags.contains(tag)) {
                            selectedTags.remove(tag);
                            return;
                          }
                          selectedTags.add(tag);
                        });
                      },
                    );
                  }),
                ),
                10.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Spacer(flex: 3),
                    Visibility(
                      visible: isSaveVisible,
                      child: CurvedButton(
                        text: 'Save',
                        loading: ref.watch(exerciseProvider).postStatus ==
                            Loader.loading,
                        onPressed: () async {
                          final response = await ref
                              .read(exerciseProvider.notifier)
                              .updateExercise(
                                timeStarted,
                                timeEnded,
                                selectedTags.toList(),
                                int.tryParse(textCtrl.text) ?? 0,
                                widget.exerciseMetric.id!,
                              );

                          if (response.successMessage.isNotEmpty) {
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              getAlert(response.successMessage,
                                  isWarning: false);
                              isSaveVisible = false;
                              ref
                                  .read(exerciseProvider.notifier)
                                  .getExercise(widget.date);
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
                    const Spacer(flex: 2),
                    IconButton(
                        onPressed: () async {
                          final response = await ref
                              .read(exerciseProvider.notifier)
                              .deleteExercise(widget.exerciseMetric.id!);

                          if (response.successMessage.isNotEmpty) {
                            getAlert(response.successMessage, isWarning: false);
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              ref
                                  .read(exerciseProvider.notifier)
                                  .getExercise(widget.date);
                            });
                          } else if (response.responseMessage!.isNotEmpty) {
                            getAlert(response.responseMessage!);
                          } else {
                            getAlert(response.errorMessage);
                          }
                        },
                        iconSize: 25.r,
                        color: Colors.red.shade500,
                        icon: ref.watch(exerciseProvider).delStatus ==
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
