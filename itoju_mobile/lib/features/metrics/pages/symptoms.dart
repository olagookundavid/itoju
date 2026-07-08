import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/dashboard/widgets/add_button.dart';
import 'package:itoju_mobile/features/metrics/notifiers/symptoms_notifier.dart';
import 'package:itoju_mobile/features/metrics/widgets/symptoms_bottom_sheet.dart';
import 'package:itoju_mobile/features/metrics/widgets/symptoms_metric_list.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/top_note.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class SymptomsPage extends ConsumerStatefulWidget {
  const SymptomsPage(this.intialDate, {super.key});
  final DateTime intialDate;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends ConsumerState<SymptomsPage> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      selectedDate = widget.intialDate;
      ref
          .read(symsProvider.notifier)
          .getSymMetric(DateFormat('yyyy-MM-dd').format(selectedDate));
    });
    super.initState();
  }

  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(symsProvider);
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
                          TopNote(text: 'What are your symptoms today?')
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
                                  ref.read(symsProvider.notifier).getSymMetric(
                                      DateFormat('yyyy-MM-dd')
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
                state.getSymsStatus == Loader.loading
                    ? const AppLoader()
                    : state.getSymsStatus == Loader.error
                        ? ErrorCon(
                            func: () {
                              SchedulerBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                ref.read(symsProvider.notifier).getSymMetric(
                                    DateFormat('yyyy-MM-dd')
                                        .format(selectedDate));
                              });
                            },
                          )
                        : Column(
                            children: [
                              (state.getSymsStatus == Loader.loaded &&
                                      state.symsMetricModels!.isEmpty)
                                  ? Column(
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
                                    )
                                  : ListView.builder(
                                      itemCount: ref
                                          .watch(symsProvider)
                                          .symsMetricModels!
                                          .length,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final symsMetric = ref
                                            .watch(symsProvider)
                                            .symsMetricModels![index];

                                        return SymptomsList(
                                            symsMetric: symsMetric,
                                            date: DateFormat('yyyy-MM-dd')
                                                .format(selectedDate));
                                      },
                                    ),
                              10.ph,
                              InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(8),
                                        ),
                                      ),
                                      context: context,
                                      builder: (context) =>
                                          SymptomsBottomSheet(selectedDate),
                                    );
                                  },
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const AddButton(),
                                        7.pw,
                                        CustomText(
                                          'Add/Edit symptoms',
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primaryColorPurple,
                                        )
                                      ])),
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
