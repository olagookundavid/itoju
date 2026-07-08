import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/metrics/notifiers/medication_notifier.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/date_pick_widget.dart';
import 'package:itoju_mobile/features/widgets/dates.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class MedicationList extends ConsumerStatefulWidget {
  const MedicationList({
    super.key,
    required this.date,
    required this.medicationModel,
  });
  final String date;

  final MedicationModel medicationModel;
  @override
  ConsumerState<MedicationList> createState() => _MedicationListState();
}

class _MedicationListState extends ConsumerState<MedicationList> {
  int dosage = 0;
  int quantity = 0;
  DateTime? time;
  String timeValue = '';
  String metric = '';

  final List quantityNum = [1, 2, 3, 4, 5];

  final Set dayTags = {timeOfDay()};
  Set tester = {};
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      dosage = widget.medicationModel.dosage;
      quantity = widget.medicationModel.quantity;
      timeValue = widget.medicationModel.time;
      time = convertTimeStringToDateTime(timeValue);
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
                  'asset/svg/drug.svg',
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
                    widget.medicationModel.name,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  CustomText(
                    widget.medicationModel.time,
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
                      if (tester.contains(widget.medicationModel.id)) {
                        tester.clear();
                        return;
                      }
                      tester.clear();
                      tester.add(widget.medicationModel.id);
                    });
                  },
                  child: Icon(
                    !tester.contains(widget.medicationModel.id)
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
          visible: tester.contains(widget.medicationModel.id),
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
                  'Single Dosage',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColorPurple,
                ),
                10.ph,
                CustomText(
                  '${(quantity * dosage).toString()}${widget.medicationModel.metric}',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xffFF9F00),
                ),
                15.ph,
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    'Number of single dosage',
                    color: AppColors.primaryColorPurple,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                10.ph,
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceAround,
                    children: List.generate(quantityNum.length, (index) {
                      final int quantityType = quantityNum[index];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            isSaveVisible = true;
                            quantity = quantityType;
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 40.h,
                              width: 40.w,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.primaryColorPurple,
                                    width: quantity == quantityType ? 2 : 0),
                                borderRadius: BorderRadius.circular(7.r),
                              ),
                              child: Center(
                                child: CustomText(
                                  'x${index + 1}',
                                  // +(quantity > 4 ? '+' : ''),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: quantity == quantityType
                                      ? AppColors.primaryColorPurple
                                      : const Color(0xffA7ABBE),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                10.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        CustomText(
                          'Time',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColorPurple,
                        ),
                        10.ph,
                        InkWell(
                          onTap: () async {
                            isSaveVisible = true;
                            time = await showOnlyTimePicker(context: context);
                            timeValue =
                                DateFormatter.formatTime(time.toString());
                            setState(() {});
                          },
                          child: WhiteContainer(text: timeValue),
                        )
                      ],
                    ),
                  ],
                ),
                20.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    Visibility(
                      visible: isSaveVisible,
                      child: CurvedButton(
                        text: 'Save',
                        loading: ref.watch(medicationProvider).updateStatus ==
                            Loader.loading,
                        onPressed: () async {
                          final response = await ref
                              .read(medicationProvider.notifier)
                              .updateMedicationMetric(MedicationModel(
                                id: widget.medicationModel.id!,
                                dosage: dosage,
                                name: widget.medicationModel.name,
                                quantity: quantity,
                                metric: metric,
                                time: timeValue,
                              ));

                          if (response.successMessage.isNotEmpty) {
                            getAlert(response.successMessage, isWarning: false);
                            isSaveVisible = false;
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              ref
                                  .read(medicationProvider.notifier)
                                  .getMedicationList(widget.date);
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
                              .read(medicationProvider.notifier)
                              .deleteSymsMetric(widget.medicationModel.id!);

                          if (response.successMessage.isNotEmpty) {
                            getAlert(response.successMessage, isWarning: false);
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              ref
                                  .read(medicationProvider.notifier)
                                  .getMedicationList(widget.date);
                            });
                          } else if (response.responseMessage!.isNotEmpty) {
                            getAlert(response.responseMessage!);
                          } else {
                            getAlert(response.errorMessage);
                          }
                        },
                        iconSize: 25.r,
                        color: Colors.red.shade500,
                        icon: ref.watch(medicationProvider).delStatus ==
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
