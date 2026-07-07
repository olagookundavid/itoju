import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/auth/pages/add_tracked_metrics.dart';
import 'package:itoju_mobile/features/dashboard/notifiers/getSmiley_notifier.dart';
import 'package:itoju_mobile/features/home/notifer/add_smiley_notifier.dart';
import 'package:itoju_mobile/features/home/notifer/getTrackedMetrics_notifier.dart';
import 'package:itoju_mobile/features/home/notifer/get_latest_smiley_notifier.dart';
import 'package:itoju_mobile/features/home/notifer/metrics_status_notifier.dart';
import 'package:itoju_mobile/features/home/widgets/smiley_box.dart';
import 'package:itoju_mobile/features/home/widgets/syms_box.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/top_note.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final List tagsList = [
    'Happy',
    'Calm',
    'Relaxed',
    'Excited',
    'Energetic',
    'Joyful',
    'Sad',
    'Angry',
    'Stressed',
    'Nervous',
  ];
  final Set userTags = {};
  int emote = 0;
  bool isFirstBuild = true;
  late List<DateTime> weekDateRange;
  DateTime? selectedDate;
  DateTime today = DateTime.now();
  Future<void> getUserLatestSmiley(DateTime date) async {
    await ref.read(latestSmileyProvider.notifier).getLatestSmiley(date);
    emote = ref.read(latestSmileyProvider).latestSmiley?.id ?? 0;
    final tags = (ref.read(latestSmileyProvider).latestSmiley?.tags) ?? [];
    for (String tag in tags) {
      userTags.add(tag);
    }
    isFirstBuild = true;
    setState(() {});
  }

  Future<void> _handleRefresh() async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(getUserMetricsProvider.notifier).getGetUserMetrics();
      ref
          .read(metricsStatusProvider.notifier)
          .getMetricsStatus(DateFormat('yyyy-MM-dd').format(DateTime.now()));
      await getUserLatestSmiley(DateTime.now());
    });
  }

  @override
  void initState() {
    _handleRefresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(getUserMetricsProvider);
    bool ifToday = (selectedDate == null ||
        ((selectedDate?.day == today.day) &&
            (selectedDate?.month == today.month)));
    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primaryColorPurple,
        onRefresh: _handleRefresh,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TopNote(text: 'How do you feel today?'),
                10.ph,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Container(
                        //   height: 70.h,
                        //   child: ListView.separated(
                        //     padding: EdgeInsets.only(top: 6.h),
                        //     scrollDirection: Axis.horizontal,
                        //     itemBuilder: (context, index) {
                        //       // final dateState = ref.watch(homeDateProvider);
                        //       DateTime dateTime =
                        //           ref.watch(homeDateProvider).weekDateRange![index];
                        //       return DateTimeline(
                        //         dateTime: dateTime,
                        //         isSelected: dateTime ==
                        //             ref.watch(homeDateProvider).selectedDate,
                        //         onDateSelected: () {
                        //           ref
                        //               .read(homeDateProvider.notifier)
                        //               .captureSelctedDate(dateTime);
                        //         },
                        //       );
                        //     },
                        //     separatorBuilder: (context, index) {
                        //       return 10.pw;
                        //     },
                        //     itemCount:
                        //         ref.watch(homeDateProvider).weekDateRange!.length), )
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              '${ifToday ? 'Today' : ''} ${DateFormat('EEE').format(selectedDate ?? today)} ${(selectedDate ?? today).day} ${ifToday ? '' : DateFormat.MMM().format(selectedDate!)}',
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
                                  if (value != null) {
                                    selectedDate = value;
                                    emote = 0;
                                    userTags.clear();
                                    isFirstBuild == true;
                                    SchedulerBinding.instance
                                        .addPostFrameCallback(
                                            (timeStamp) async {
                                      ref
                                          .read(metricsStatusProvider.notifier)
                                          .getMetricsStatus(
                                              DateFormat('yyyy-MM-dd')
                                                  .format(selectedDate!));
                                      await getUserLatestSmiley(selectedDate!);
                                    });
                                  }

                                  setState(() {});
                                });
                              },
                            )
                          ],
                        ),
                        50.pw,
                        10.ph,
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SmileyBox(
                                emotes: '😃',
                                onTap: () {
                                  isFirstBuild = false;
                                  emote = 1;
                                  setState(() {});
                                },
                                isTapped: emote == 1),
                            SmileyBox(
                                emotes: '🙂',
                                onTap: () {
                                  isFirstBuild = false;
                                  emote = 2;
                                  setState(() {});
                                },
                                isTapped: emote == 2),
                            SmileyBox(
                                emotes: '😑',
                                onTap: () {
                                  isFirstBuild = false;
                                  emote = 3;
                                  setState(() {});
                                },
                                isTapped: emote == 3),
                            SmileyBox(
                                emotes: '🙁',
                                onTap: () {
                                  isFirstBuild = false;
                                  emote = 4;
                                  setState(() {});
                                },
                                isTapped: emote == 4),
                            SmileyBox(
                                emotes: '😢',
                                onTap: () {
                                  isFirstBuild = false;
                                  emote = 5;
                                  setState(() {});
                                },
                                isTapped: emote == 5),
                          ],
                        ),
                        20.ph,
                        Text(
                          'Tags',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColorPurple),
                        ),
                        20.ph,
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
                                  ? AppColors.primaryColorPurple
                                      .withOpacity(.85)
                                  : null,
                              onPressed: () {
                                setState(() {
                                  isFirstBuild = false;
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
                        10.ph,
                        if (emote != 0 && isFirstBuild == false)
                          Center(
                              child: CurvedButton(
                                  height: 35.h,
                                  text: 'Save',
                                  loading:
                                      ref.watch(addSmileyProvider).loadStatus ==
                                          Loader.loading,
                                  onPressed: () async {
                                    final response = await ref
                                        .read(addSmileyProvider.notifier)
                                        .addSmiley(emote, userTags.toList(),
                                            selectedDate ?? DateTime.now());
                                    if (response.successMessage.isNotEmpty) {
                                      if (!mounted) return;
                                      getAlert(response.successMessage,
                                          isWarning: false);
                                      isFirstBuild = true;
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((timeStamp) {
                                        ref
                                            .read(getSmileyProvider.notifier)
                                            .getGetSmiley();
                                      });
                                    } else if (response
                                        .responseMessage!.isNotEmpty) {
                                      getAlert(response.responseMessage!);
                                    } else {
                                      getAlert(response.errorMessage);
                                    }
                                  },
                                  width: 150.w)),
                        20.ph,
                        Text(
                          'Give more details',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColorPurple),
                        ),
                        20.ph,
                        state.status == Loader.loading
                            ? const AppLoader()
                            : state.status == Loader.error
                                ? ErrorCon(
                                    func: () {
                                      _handleRefresh();
                                    },
                                  )
                                : (state.status == Loader.loaded &&
                                        state.metricsModel!.isEmpty)
                                    ? GestureDetector(
                                        onTap: () {
                                          pushScreen(
                                            context,
                                            screen: const AddTrackedMetrics(),
                                            withNavBar: false,
                                            pageTransitionAnimation:
                                                PageTransitionAnimation
                                                    .cupertino,
                                          );
                                        },
                                        child: CustomText(
                                          'No tracked metrics yet, click to add',
                                          color: AppColors.primaryColorPurple,
                                          maxline: 3,
                                          fontSize: 23.sp,
                                          textAlign: TextAlign.center,
                                        ))
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        primary: false,
                                        padding: const EdgeInsets.all(0),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 20.w,
                                                mainAxisSpacing: 20.h,
                                                childAspectRatio: 1),
                                        itemCount: state.metricsModel!.length,
                                        itemBuilder: (context, index) {
                                          final metric =
                                              state.metricsModel![index];
                                          return SyptomsBox(
                                              intialDate: selectedDate ?? today,
                                              metric: metric.name ?? '',
                                              onTap: () {});
                                        },
                                      ),
                        50.ph
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
