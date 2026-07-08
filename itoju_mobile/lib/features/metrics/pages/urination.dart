import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/dashboard/widgets/add_button.dart';
import 'package:itoju_mobile/features/metrics/notifiers/urine_notifier.dart';
import 'package:itoju_mobile/features/metrics/widgets/urine_list.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/top_note.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

final addUrineProvider = StateProvider<bool>((ref) {
  return false;
});

class UrineMovement extends ConsumerStatefulWidget {
  const UrineMovement(this.intialDate, {super.key});
  final DateTime intialDate;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UrineMovementState();
}

class _UrineMovementState extends ConsumerState<UrineMovement> {
  @override
  void initState() {
    selectedDate = widget.intialDate;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref
          .read(urineProvider.notifier)
          .getUrineList(DateFormat('yyyy-MM-dd').format(selectedDate!));
      ref.read(addUrineProvider.notifier).state = false;
    });
    super.initState();
  }

  DateTime? selectedDate;
  bool isExtraNight = false;
  @override
  Widget build(BuildContext context) {
    final isExtraVisible = ref.watch(addUrineProvider);
    final state = ref.watch(urineProvider);
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
                        TopNote(text: 'How do you feel during urination?'),
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
                                ref.read(urineProvider.notifier).getUrineList(
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
                              ref.read(urineProvider.notifier).getUrineList(
                                  DateFormat('yyyy-MM-dd')
                                      .format(selectedDate!));
                              ref.read(addUrineProvider.notifier).state = false;
                            });
                          },
                        )
                      : Column(
                          children: [
                            state.urineModels!.isEmpty
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
                                    itemCount: state.urineModels!.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final urineMetric = ref
                                          .watch(urineProvider)
                                          .urineModels![index];

                                      return UrineList(
                                          isNew: false,
                                          urineModel: urineMetric,
                                          date: DateFormat('yyyy-MM-dd')
                                              .format(selectedDate!));
                                    },
                                  ),
                            Visibility(
                              visible: isExtraVisible,
                              replacement: InkWell(
                                  onTap: () async {
                                    ref.read(addUrineProvider.notifier).state =
                                        true;
                                    setState(() {});
                                  },
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const AddButton(),
                                        7.pw,
                                        CustomText(
                                          'Add Urine record',
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primaryColorPurple,
                                        )
                                      ])),
                              child: UrineList(
                                  isNew: true,
                                  urineModel: UrineModel(
                                      id: 0,
                                      time: '',
                                      pain: 0,
                                      tags: [],
                                      type: 0,
                                      quantity: 0),
                                  date: DateFormat('yyyy-MM-dd')
                                      .format(selectedDate!)),
                            ),
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
