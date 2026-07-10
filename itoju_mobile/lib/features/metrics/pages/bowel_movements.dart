import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/dashboard/widgets/add_button.dart';
import 'package:itoju_mobile/features/metrics/notifiers/bowel_notifier.dart';
import 'package:itoju_mobile/features/metrics/widgets/bowel_list.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/top_note.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

final addBowelProvider = StateProvider<bool>((ref) {
  return false;
});

class BowelMovement extends ConsumerStatefulWidget {
  const BowelMovement(this.intialDate, {super.key});
  final DateTime intialDate;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BowelMovementState();
}

class _BowelMovementState extends ConsumerState<BowelMovement> {
  @override
  void initState() {
    selectedDate = widget.intialDate;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref
          .read(bowelProvider.notifier)
          .getBowelList(DateFormat('yyyy-MM-dd').format(selectedDate!));
      ref.read(addBowelProvider.notifier).state = false;
    });
    super.initState();
  }

  DateTime? selectedDate;
  bool isExtraNight = false;
  @override
  Widget build(BuildContext context) {
    final isExtraVisible = ref.watch(addBowelProvider);
    final state = ref.watch(bowelProvider);
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
                        TopNote(
                            text: 'Have you had any bowel movements today?'),
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
                                ref.read(bowelProvider.notifier).getBowelList(
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
                              ref.read(bowelProvider.notifier).getBowelList(
                                  DateFormat('yyyy-MM-dd')
                                      .format(selectedDate!));
                              ref.read(addBowelProvider.notifier).state = false;
                            });
                          },
                        )
                      : Column(
                          children: [
                            state.bowelModels!.isEmpty
                                ? Visibility(
                                    visible: !isExtraVisible,
                                    child: Column(
                                      children: [
                                        25.ph,
                                        Image.asset('asset/png/no_bowel.png'),
                                        10.ph
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: state.bowelModels!.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final bowelMetric = ref
                                          .watch(bowelProvider)
                                          .bowelModels![index];

                                      return BowelList(
                                          isNew: false,
                                          bowelModel: bowelMetric,
                                          date: DateFormat('yyyy-MM-dd')
                                              .format(selectedDate!));
                                    },
                                  ),
                            Visibility(
                              visible: isExtraVisible,
                              child: BowelList(
                                  isNew: true,
                                  bowelModel: BowelModel(
                                    id: null,
                                    time: '',
                                    pain: 0,
                                    tags: [],
                                    type: 0,
                                  ),
                                  date: DateFormat('yyyy-MM-dd')
                                      .format(selectedDate!)),
                            ),
                            10.ph,
                            InkWell(
                                onTap: () async {
                                  ref.read(addBowelProvider.notifier).state =
                                      true;
                                  setState(() {});
                                },
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const AddButton(),
                                      7.pw,
                                      CustomText(
                                        'Add Bowel record',
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
