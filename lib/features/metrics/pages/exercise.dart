import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/dashboard/widgets/add_button.dart';
import 'package:itoju_mobile/features/metrics/notifiers/exercise_notifier.dart';
import 'package:itoju_mobile/features/metrics/widgets/exxercise_list.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/custom_text_field.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/top_note.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class ExercisePage extends ConsumerStatefulWidget {
  const ExercisePage(this.intialDate, {super.key});
  final DateTime intialDate;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExercisePageState();
}

class _ExercisePageState extends ConsumerState<ExercisePage> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      selectedDate = widget.intialDate;
      ref
          .read(exerciseProvider.notifier)
          .getExercise(DateFormat('yyyy-MM-dd').format(selectedDate));
    });
    super.initState();
  }

  DateTime selectedDate = DateTime.now();
  bool isCreateVisible = true;
  final TextEditingController textCtrl = TextEditingController();
  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exerciseProvider);
    bool ifToday = (((selectedDate.day == DateTime.now().day) &&
        (selectedDate.month == DateTime.now().month)));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 120.h,
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          CustomBackButton(),
                          TopNote(text: 'What exercises did you do today?')
                        ],
                      ),
                      5.ph,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            '${ifToday ? 'Today' : ''} ${DateFormat('EEE').format(selectedDate)} ${(selectedDate).day} ${ifToday ? '' : DateFormat.MMM().format(selectedDate)}',
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
                                initialDate: selectedDate,
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
                                      .read(exerciseProvider.notifier)
                                      .getExercise(DateFormat('yyyy-MM-dd')
                                          .format(selectedDate));
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
                state.getStatus == Loader.loading
                    ? const AppLoader()
                    : state.getStatus == Loader.error
                        ? ErrorCon(
                            func: () {
                              SchedulerBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                selectedDate = widget.intialDate;
                                ref.read(exerciseProvider.notifier).getExercise(
                                    DateFormat('yyyy-MM-dd')
                                        .format(selectedDate));
                              });
                            },
                          )
                        : Column(
                            children: [
                              state.exerciseModel!.isEmpty
                                  ? Visibility(
                                      visible: isCreateVisible,
                                      child: Column(
                                        children: [
                                          25.ph,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                  'asset/png/no_exercise.png'),
                                            ],
                                          ),
                                          10.ph
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: ref
                                          .watch(exerciseProvider)
                                          .exerciseModel!
                                          .length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        final exerciseMetric = ref
                                            .watch(exerciseProvider)
                                            .exerciseModel![index];

                                        return ExerciseList(
                                            exerciseMetric: exerciseMetric,
                                            date: DateFormat('yyyy-MM-dd')
                                                .format(selectedDate));
                                      },
                                    ),
                              10.ph,
                              Visibility(
                                visible: isCreateVisible,
                                replacement: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 7.h, horizontal: 10.w),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: const Color(0xffEEEDF8),
                                      border:
                                          Border.all(color: const Color(0xffEEEDF8))),
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      7.ph,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomText(
                                            'Name of Exercise',
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryColorPurple,
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isCreateVisible =
                                                      !isCreateVisible;
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.cancel_outlined,
                                                color: AppColors
                                                    .primaryColorPurple,
                                              ))
                                        ],
                                      ),
                                      3.ph,
                                      CustomTextField(
                                          filled: true, controller: textCtrl),
                                      7.ph,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CurvedButton(
                                            text: 'Done',
                                            loading: ref
                                                    .watch(exerciseProvider)
                                                    .postStatus ==
                                                Loader.loading,
                                            onPressed: () async {
                                              if (textCtrl.text.isEmpty) return;
                                              final response = await ref
                                                  .read(
                                                      exerciseProvider.notifier)
                                                  .createExercise(
                                                      textCtrl.text,
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(
                                                              selectedDate));

                                              if (response
                                                  .successMessage.isNotEmpty) {
                                                getAlert(
                                                    response.successMessage,
                                                    isWarning: false);
                                                isCreateVisible = false;
                                                textCtrl.clear();
                                                SchedulerBinding.instance
                                                    .addPostFrameCallback(
                                                        (timeStamp) async {
                                                  ref
                                                      .read(exerciseProvider
                                                          .notifier)
                                                      .getExercise(DateFormat(
                                                              'yyyy-MM-dd')
                                                          .format(
                                                              selectedDate));
                                                });
                                              } else if (response
                                                  .responseMessage!
                                                  .isNotEmpty) {
                                                getAlert(
                                                    response.responseMessage!);
                                              } else {
                                                getAlert(response.errorMessage);
                                              }
                                            },
                                            width: 150.w,
                                            height: 40.h,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        isCreateVisible = !isCreateVisible;
                                      });
                                    },
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const AddButton(),
                                          7.pw,
                                          CustomText(
                                            'Add or Edit Exercise',
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.primaryColorPurple,
                                          )
                                        ])),
                              ),
                            ],
                          ),
                30.ph,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
