import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/dashboard/widgets/add_button.dart';
import 'package:itoju_mobile/features/metrics/notifiers/sleep_notifier.dart';
import 'package:itoju_mobile/features/metrics/widgets/sleep_list.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/top_note.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

final addSleepProvider = StateProvider<bool>((ref) {
  return false;
});

class SleepWidget extends ConsumerStatefulWidget {
  const SleepWidget(this.intialDate, {super.key});
  final DateTime intialDate;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SleepWidgetState();
}

class _SleepWidgetState extends ConsumerState<SleepWidget> {
  @override
  void initState() {
    selectedDate = widget.intialDate;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref
          .read(sleepProvider.notifier)
          .getSleepList(DateFormat('yyyy-MM-dd').format(selectedDate!));
    });
    super.initState();
  }

  DateTime? selectedDate;
  bool isExtraNight = false;
  @override
  Widget build(BuildContext context) {
    final isExtraVisible = ref.watch(addSleepProvider);
    final state = ref.watch(sleepProvider);
    bool ifToday = (selectedDate == null ||
        ((selectedDate?.day == DateTime.now().day) &&
            (selectedDate?.month == DateTime.now().month)));
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(10.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 120.h,
                child: Column(
                  children: [
                    const Row(
                      children: [
                        CustomBackButton(),
                        TopNote(text: 'How well did you sleep today?')
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
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 90)),
                              lastDate: DateTime.now(),
                            ).then((value) {
                              setState(() {});
                              if (value != null) {
                                selectedDate = value;
                              }
                              SchedulerBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                ref.read(sleepProvider.notifier).getSleepList(
                                    DateFormat('yyyy-MM-dd')
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
                              ref.read(sleepProvider.notifier).getSleepList(
                                  DateFormat('yyyy-MM-dd')
                                      .format(selectedDate!));
                            });
                          },
                        )
                      : Column(
                          children: [
                            state.sleepModels!.isEmpty
                                ? Column(
                                    children: [
                                      25.ph,
                                      Image.asset('asset/png/no_sleep.png'),
                                      10.ph
                                    ],
                                  )
                                : ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: ref
                                        .watch(sleepProvider)
                                        .sleepModels!
                                        .length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final sleepMetric = ref
                                          .watch(sleepProvider)
                                          .sleepModels![index];

                                      return SleepList(
                                          sleepMetric.isNight!
                                              ? 'Night'
                                              : 'Daytime',
                                          sleepMetric.isNight!,
                                          false,
                                          sleepModel: sleepMetric,
                                          date: DateFormat('yyyy-MM-dd')
                                              .format(selectedDate!));
                                    },
                                  ),
                            Visibility(
                              visible: isExtraVisible,
                              child: SleepList(
                                  isExtraNight ? 'Night' : 'Daytime',
                                  isExtraNight,
                                  true,
                                  sleepModel: SleepModel(
                                      id: 0,
                                      timeSlept: '',
                                      timeWokeUp: '',
                                      tags: [],
                                      severity: 0,
                                      isNight: isExtraNight),
                                  date: DateFormat('yyyy-MM-dd')
                                      .format(selectedDate!)),
                            ),
                            10.ph,
                            InkWell(
                                onTap: () async {
                                  isExtraNight = await showModalBottomSheet(
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                    ),
                                    context: context,
                                    builder: (context) =>
                                        const SleepTimeDeciderSheet(),
                                  );
                                  ref.read(addSleepProvider.notifier).state =
                                      true;
                                  setState(() {});
                                },
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const AddButton(),
                                      7.pw,
                                      CustomText(
                                        'Add Sleep record',
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primaryColorPurple,
                                      )
                                    ])),
                          ],
                        ),
              50.ph
            ],
          ),
        ),
      )),
    );
  }
}

class SleepTimeDeciderSheet extends StatelessWidget {
  const SleepTimeDeciderSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          children: [
            10.ph,
            SelectTimeWidget(
              time: true,
              ontap: () {
                Navigator.pop(context, false);
              },
            ),
            10.ph,
            SelectTimeWidget(
              time: false,
              ontap: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SelectTimeWidget extends StatelessWidget {
  const SelectTimeWidget({
    super.key,
    required this.time,
    required this.ontap,
  });
  final bool time;
  final Function() ontap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
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
                'asset/svg/${time == true ? 'day' : 'night'}_time.svg',
                width: 20.w,
                height: 20.h,
              ),
            ),
            18.pw,
            CustomText(
              time == true ? 'DayTime' : 'Night',
              fontSize: 16.sp,
              color: Colors.white,
            ),
            const Spacer(),
            Container(
              height: 30.h,
              width: 30.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.r),
                  border: Border.all(color: Colors.white, width: 2.w)),
              child: const Center(
                  child: Icon(
                Icons.add,
                color: Colors.white,
              )),
            )
          ],
        ),
      ),
    );
  }
}
