import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/dashboard/widgets/slider_and_value.dart';
import 'package:itoju_mobile/features/menses/del_menses_popup.dart';
import 'package:itoju_mobile/features/menses/notifiers/menses_notifier.dart';
import 'package:itoju_mobile/features/settings/notifier/menses_notifier.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/custom_text_field.dart';
import 'package:itoju_mobile/features/widgets/dialog.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';
import 'package:table_calendar/table_calendar.dart';

class MensesPage extends ConsumerStatefulWidget {
  const MensesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MensesPageState();
}

class _MensesPageState extends ConsumerState<MensesPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Map<DateTime, List<Color>> eventColors = {};

  // Map<DateTime, List<Color>> parseCycleDays(List<CycleDay> cycleDays) {
  //   Map<DateTime, List<Color>> eventColors = {};

  //   for (var day in cycleDays) {
  //     if (day.isPeriod) {
  //       eventColors[day.date] = [Colors.red];
  //     } else if (day.isOvulation) {
  //       eventColors[day.date] = [Colors.purple];
  //     }
  //   }

  //   return eventColors;
  // }

  bool isNew = false;
  bool isSelected = false;
  bool isFree = false;
  bool isSaveVisible = false;
  num pain = 0;
  num flow = 0;
  Set<dynamic> userTags = {};
  String cmq = "";

  PeriodModel? periodModel = PeriodModel(
      id: '',
      cycleId: '',
      date: '',
      isPeriod: false,
      isOvulation: true,
      flow: 0,
      pain: 0,
      tags: [],
      cmq: '');

  final TextEditingController periodCtrl = TextEditingController();
  final TextEditingController cycleCtrl = TextEditingController();
  final List tagsList = [
    'Breast Sensitivity',
    'Acne',
    'Weight gain',
    'Chills',
    'Bloating',
    'Cravings'
  ];
  final List cmqList = ['Egg White', 'Watery', 'Dry', 'Sticky', 'Creamy'];
  final List symptomsList = [
    'Addominal Cramps',
    'Appetite Changes',
    'Bladder incontinence',
    'Breast pain',
    'Acne',
    'Bloating'
  ];

  Future<void> _handleRefresh() async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(periodProvider.notifier).getPeriodList();
    });
  }

  @override
  void initState() {
    _handleRefresh();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      await ref.read(mensesProvider.notifier).getMenses();
      periodCtrl.text =
          (ref.read(mensesProvider).mensesModel?.periodLen ?? 25).toString();
      cycleCtrl.text =
          (ref.read(mensesProvider).mensesModel?.cycleLen ?? 5).toString();
      if (periodCtrl.text == '0') periodCtrl.text = '25';
      if (cycleCtrl.text == '0') cycleCtrl.text = '5';
    });
    super.initState();
  }

  @override
  void dispose() {
    periodCtrl.dispose();
    cycleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(periodProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.r),
                          color: AppColors.splash_underlay,
                        ),
                        child: Text(
                          'Menstruation & Ovulation',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColorPurple),
                        )),
                    const Spacer(),
                    Column(
                      children: [
                        8.ph,
                        InkWell(
                            onTap: () {
                              _handleRefresh();
                            },
                            child: const Icon(
                              Icons.replay,
                              color: AppColors.primaryColorPurple,
                            )),
                      ],
                    )
                  ],
                ),
                state.status == Loader.loading
                    ? Column(
                        children: [
                          250.ph,
                          const AppLoader(),
                        ],
                      )
                    : state.status == Loader.error
                        ? ErrorCon(
                            func: () {
                              _handleRefresh();
                            },
                          )
                        : Column(
                            children: [
                              TableCalendar<PeriodModel>(
                                firstDay: DateTime.utc(2010, 10, 16),
                                lastDay: DateTime.utc(2030, 3, 14),
                                focusedDay: _focusedDay,
                                daysOfWeekStyle: const DaysOfWeekStyle(
                                    weekdayStyle:
                                        TextStyle(color: Colors.black),
                                    weekendStyle: TextStyle(
                                        color: AppColors.primaryColorPurple)),
                                calendarStyle: CalendarStyle(
                                    selectedDecoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primaryColorPurple
                                            .withOpacity(.8)),
                                    todayDecoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primaryColorPurple
                                            .withOpacity(.5))),
                                headerStyle: const HeaderStyle(
                                    titleCentered: true,
                                    formatButtonVisible: false),
                                availableGestures: AvailableGestures.all,
                                eventLoader: (day) {
                                  return state.period?[DateFormat('yyyy-MM-dd')
                                          .format(DateTime.parse(
                                              day.toString()))] ??
                                      [];
                                },
                                calendarBuilders: CalendarBuilders(
                                  markerBuilder: (context, day, events) {
                                    if (events.isNotEmpty) {
                                      return Positioned(
                                        bottom: 10.h,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: events[0].isPeriod
                                                  ? Colors.red
                                                  : events[0].isOvulation
                                                      ? Colors.blue
                                                      : Colors.grey
                                                          .withOpacity(.7),
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(3.r),
                                                  bottomRight:
                                                      Radius.circular(3.r))),
                                          width: 30.w,
                                          height: 5.h,
                                        ),
                                      );
                                    }
                                    return null;
                                  },
                                ),
                                selectedDayPredicate: (day) {
                                  return isSameDay(_selectedDay, day);
                                },
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                  final day = DateFormat('yyyy-MM-dd').format(
                                      DateTime.parse(_selectedDay.toString()));
                                  // ignore: avoid_print
                                  if (state.period?[day] == null) {
                                    periodCtrl.text = (ref
                                                .read(mensesProvider)
                                                .mensesModel
                                                ?.periodLen ??
                                            0)
                                        .toString();
                                    cycleCtrl.text = (ref
                                                .read(mensesProvider)
                                                .mensesModel
                                                ?.cycleLen ??
                                            0)
                                        .toString();
                                    isSelected = false;
                                    isNew = true;
                                    isFree = false;
                                  } else {
                                    isNew = false;
                                    periodModel = state.period![day]!.first;
                                    if (!periodModel!.isOvulation &&
                                        !periodModel!.isPeriod) {
                                      isSelected = false;
                                      isFree = true;
                                      return;
                                    }
                                    isFree = false;
                                    isSelected = true;
                                    userTags.clear();
                                    final tags = (periodModel!.tags);
                                    for (String tag in tags) {
                                      userTags.add(tag);
                                    }
                                    cmq = periodModel!.cmq;
                                    pain = periodModel!.pain;
                                    flow = periodModel!.flow;
                                  }
                                },
                                onPageChanged: (focusedDay) {
                                  //TODO : load other calender details
                                },
                              ),
                              20.ph,
                              if (isFree)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 7.h, horizontal: 10.w),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: const Color(0xffEEEDF8),
                                      border: Border.all(
                                          color: const Color(0xffEEEDF8))),
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
                                            'No Activity Today!',
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryColorPurple,
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isFree = !isFree;
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
                                      CustomText(
                                        'If you had your period again today, you can add it!',
                                        maxline: 3,
                                        textAlign: TextAlign.center,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primaryColorPurple,
                                      ),
                                      15.ph,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CurvedButton(
                                            text: 'Add',
                                            loading: ref
                                                    .watch(periodProvider)
                                                    .updateStatus ==
                                                Loader.loading,
                                            onPressed: () async {
                                              final response = await ref
                                                  .read(periodProvider.notifier)
                                                  .updatePeriodMetric(
                                                      PeriodModel(
                                                          id: periodModel!.id,
                                                          cycleId: periodModel!
                                                              .cycleId,
                                                          date:
                                                              periodModel!.date,
                                                          isPeriod: true,
                                                          isOvulation:
                                                              periodModel!
                                                                  .isOvulation,
                                                          flow:
                                                              periodModel!.flow,
                                                          pain:
                                                              periodModel!.pain,
                                                          tags:
                                                              periodModel!.tags,
                                                          cmq: periodModel!
                                                              .cmq));

                                              if (response
                                                  .successMessage.isNotEmpty) {
                                                getAlert(
                                                    response.successMessage,
                                                    isWarning: false);
                                                isFree = false;
                                                SchedulerBinding.instance
                                                    .addPostFrameCallback(
                                                        (timeStamp) async {
                                                  ref
                                                      .read(periodProvider
                                                          .notifier)
                                                      .getPeriodList();
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
                              if (isNew)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 7.h, horizontal: 10.w),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: const Color(0xffEEEDF8),
                                      border: Border.all(
                                          color: const Color(0xffEEEDF8))),
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
                                            'Create new Period Cycle!',
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryColorPurple,
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isNew = !isNew;
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
                                      CustomText(
                                        'Cycle Length',
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryColorPurple,
                                      ),
                                      CustomTextField(
                                          filled: true, controller: cycleCtrl),
                                      7.ph,
                                      CustomText(
                                        'Period Length',
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryColorPurple,
                                      ),
                                      CustomTextField(
                                          filled: true, controller: periodCtrl),
                                      5.ph,
                                      CustomText(
                                        'Starts: ${DateFormat('yyyy-MM-dd').format(_selectedDay!)}',
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.redAccent,
                                      ),
                                      15.ph,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CurvedButton(
                                            text: 'Done',
                                            loading: ref
                                                    .watch(periodProvider)
                                                    .postStatus ==
                                                Loader.loading,
                                            onPressed: () async {
                                              if (periodCtrl.text.isEmpty ||
                                                  cycleCtrl.text.isEmpty) {
                                                return;
                                              }
                                              final response = await ref
                                                  .read(periodProvider.notifier)
                                                  .createPeriodMetric(
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(
                                                              _selectedDay!),
                                                      int.parse(cycleCtrl.text),
                                                      int.parse(
                                                          periodCtrl.text));

                                              if (response
                                                  .successMessage.isNotEmpty) {
                                                getAlert(
                                                    response.successMessage,
                                                    isWarning: false);
                                                isNew = false;
                                                periodCtrl.clear();
                                                cycleCtrl.clear();
                                                SchedulerBinding.instance
                                                    .addPostFrameCallback(
                                                        (timeStamp) async {
                                                  ref
                                                      .read(periodProvider
                                                          .notifier)
                                                      .getPeriodList();
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
                              if (isSelected)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 7.h, horizontal: 10.w),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: const Color(0xffEEEDF8),
                                      border: Border.all(
                                          color: const Color(0xffEEEDF8))),
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          const Spacer(flex: 3),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: AppColors
                                                    .primaryColorPurple,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.r)),
                                            height: 40.h,
                                            width: 85.w,
                                            child: Center(
                                              child: CustomText(
                                                periodModel!.isPeriod == true
                                                    ? 'Period'
                                                    : 'Ovulation',
                                                color: Colors.white,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const Spacer(flex: 1),
                                          IconButton(
                                              onPressed: () async {
                                                final del = await deleteMenses(
                                                    context, periodModel!);
                                                if (del) {
                                                  final response = await ref
                                                      .read(periodProvider
                                                          .notifier)
                                                      .deletePeriodMetric(
                                                          periodModel!.cycleId);
                                                  if (response.successMessage
                                                      .isNotEmpty) {
                                                    getAlert(
                                                        response.successMessage,
                                                        isWarning: false);
                                                    isSaveVisible = false;
                                                    isSelected = false;
                                                    isNew = true;
                                                    isFree = false;
                                                    // SchedulerBinding.instance
                                                    //     .addPostFrameCallback(
                                                    //         (timeStamp) async {
                                                    //   ref
                                                    //       .read(periodProvider
                                                    //           .notifier)
                                                    //       .getPeriodList();
                                                    // });
                                                  } else if (response
                                                      .responseMessage!
                                                      .isNotEmpty) {
                                                    getAlert(response
                                                        .responseMessage!);
                                                  } else {
                                                    getAlert(
                                                        response.errorMessage);
                                                  }
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.delete_forever,
                                                color: Colors.red,
                                              )),
                                          IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  isSelected = !isSelected;
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.cancel_outlined,
                                                color: AppColors
                                                    .primaryColorPurple,
                                              ))
                                        ],
                                      ),
                                      15.ph,
                                      if (periodModel!.isPeriod)
                                        Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: CustomText(
                                                'Menstrual Flow',
                                                color: AppColors
                                                    .primaryColorPurple,
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            5.ph,
                                            SliderAndValue(
                                                onchanged: (value) {
                                                  isSaveVisible = true;
                                                  flow = value;
                                                  setState(() {});
                                                },
                                                sev: flow.toDouble()),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                CustomText(
                                                  'Light',
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: flow < .33
                                                      ? Colors.green
                                                      : Colors.grey,
                                                ),
                                                CustomText(
                                                  'Moderate',
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      flow > .33 && flow < .67
                                                          ? Colors.amber
                                                          : Colors.grey,
                                                ),
                                                CustomText(
                                                  'Heavy',
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: flow > .67
                                                      ? Colors.red
                                                      : Colors.grey,
                                                ),
                                              ],
                                            ),
                                            20.ph,
                                          ],
                                        ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: CustomText(
                                          'Pain during ${periodModel!.isPeriod == true ? 'Menstruation' : 'Ovulation'}',
                                          color: AppColors.primaryColorPurple,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      5.ph,
                                      SliderAndValue(
                                          onchanged: (value) {
                                            isSaveVisible = true;
                                            pain = value;
                                            setState(() {});
                                          },
                                          sev: pain.toDouble()),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          CustomText(
                                            'Mild',
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700,
                                            color: pain < .33
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          CustomText(
                                            'Moderate',
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700,
                                            color: pain > .33 && pain < .67
                                                ? Colors.amber
                                                : Colors.grey,
                                          ),
                                          CustomText(
                                            'Severe',
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700,
                                            color: pain > .67
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                        ],
                                      ),
                                      20.ph,
                                      if (!periodModel!.isPeriod &&
                                          periodModel!.isOvulation)
                                        Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: CustomText(
                                                  'Cervical mucus quality',
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors
                                                      .primaryColorPurple),
                                            ),
                                            7.ph,
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Wrap(
                                                spacing: 8.0,
                                                runSpacing: 8.0,
                                                children: List.generate(
                                                    cmqList.length, (index) {
                                                  final tag = cmqList[index];
                                                  return ActionChip(
                                                    label: Text(tag),
                                                    labelStyle: TextStyle(
                                                        color: cmq == tag
                                                            ? Colors.white
                                                            : Colors.black),
                                                    backgroundColor: cmq == tag
                                                        ? AppColors
                                                            .primaryColorPurple
                                                            .withOpacity(.85)
                                                        : null,
                                                    onPressed: () {
                                                      setState(() {
                                                        isSaveVisible = true;
                                                        if (cmq == tag) {
                                                          cmq = '';
                                                          return;
                                                        }
                                                        cmq = tag;
                                                      });
                                                    },
                                                  );
                                                }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      20.ph,
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: CustomText(
                                            periodModel!.isPeriod == true
                                                ? 'Tags'
                                                : 'Symptoms',
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                AppColors.primaryColorPurple),
                                      ),
                                      7.ph,
                                      periodModel!.isPeriod
                                          ? Align(
                                              alignment: Alignment.centerLeft,
                                              child: Wrap(
                                                spacing: 8.0,
                                                runSpacing: 8.0,
                                                children: List.generate(
                                                    tagsList.length, (index) {
                                                  final tag = tagsList[index];
                                                  return ActionChip(
                                                    label: Text(tag),
                                                    labelStyle: TextStyle(
                                                        color: userTags
                                                                .contains(tag)
                                                            ? Colors.white
                                                            : Colors.black),
                                                    backgroundColor: userTags
                                                            .contains(tag)
                                                        ? AppColors
                                                            .primaryColorPurple
                                                            .withOpacity(.85)
                                                        : null,
                                                    onPressed: () {
                                                      setState(() {
                                                        isSaveVisible = true;
                                                        if (userTags
                                                            .contains(tag)) {
                                                          userTags.remove(tag);
                                                          return;
                                                        }
                                                        userTags.add(tag);
                                                      });
                                                    },
                                                  );
                                                }),
                                              ),
                                            )
                                          : Align(
                                              alignment: Alignment.centerLeft,
                                              child: Wrap(
                                                spacing: 8.0,
                                                runSpacing: 8.0,
                                                children: List.generate(
                                                    symptomsList.length,
                                                    (index) {
                                                  final tag =
                                                      symptomsList[index];
                                                  return ActionChip(
                                                    label: Text(tag),
                                                    labelStyle: TextStyle(
                                                        color: userTags
                                                                .contains(tag)
                                                            ? Colors.white
                                                            : Colors.black),
                                                    backgroundColor: userTags
                                                            .contains(tag)
                                                        ? AppColors
                                                            .primaryColorPurple
                                                            .withOpacity(.85)
                                                        : null,
                                                    onPressed: () {
                                                      setState(() {
                                                        isSaveVisible = true;
                                                        if (userTags
                                                            .contains(tag)) {
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Visibility(
                                            visible: isSaveVisible,
                                            child: CurvedButton(
                                              text: 'Done',
                                              loading: (ref
                                                          .watch(periodProvider)
                                                          .postStatus ==
                                                      Loader.loading ||
                                                  ref
                                                          .watch(periodProvider)
                                                          .updateStatus ==
                                                      Loader.loading),
                                              onPressed: () async {
                                                final response = await ref
                                                    .read(
                                                        periodProvider.notifier)
                                                    .updatePeriodMetric(
                                                        PeriodModel(
                                                            id: periodModel!.id,
                                                            cycleId:
                                                                periodModel!
                                                                    .cycleId,
                                                            date: periodModel!
                                                                .date,
                                                            isPeriod:
                                                                periodModel!
                                                                    .isPeriod,
                                                            isOvulation:
                                                                periodModel!
                                                                    .isOvulation,
                                                            flow: flow,
                                                            pain: pain,
                                                            tags: userTags
                                                                .toList(),
                                                            cmq: cmq));

                                                if (response.successMessage
                                                    .isNotEmpty) {
                                                  getAlert(
                                                      response.successMessage,
                                                      isWarning: false);
                                                  isSaveVisible = false;
                                                  SchedulerBinding.instance
                                                      .addPostFrameCallback(
                                                          (timeStamp) async {
                                                    ref
                                                        .read(periodProvider
                                                            .notifier)
                                                        .getPeriodList();
                                                  });
                                                } else if (response
                                                    .responseMessage!
                                                    .isNotEmpty) {
                                                  getAlert(response
                                                      .responseMessage!);
                                                } else {
                                                  getAlert(
                                                      response.errorMessage);
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
                              30.ph
                            ],
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

deleteMenses(BuildContext ctx, PeriodModel period) {
  return customDialog(
      ctx,
      DelMensesDialog(
        period: period,
      ),
      dialogHeight: 250,
      dialogWidth: 400);
}
