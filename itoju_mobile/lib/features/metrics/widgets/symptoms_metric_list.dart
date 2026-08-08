import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/dashboard/widgets/slider_and_value.dart';
import 'package:itoju_mobile/features/metrics/notifiers/symptoms_notifier.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class SymptomsList extends ConsumerStatefulWidget {
  const SymptomsList({
    super.key,
    required this.symsMetric,
    required this.date,
  });
  final SymptomsMetricModel symsMetric;
  final String date;
  @override
  ConsumerState<SymptomsList> createState() => _SymptomsListState();
}

class _SymptomsListState extends ConsumerState<SymptomsList> {
  // One overall severity (0..1). We keep the model's three period columns for
  // the backend sync contract but drive them all from this single value, so a
  // day is never left partially-rated (which the analytics used to deflate).
  double severity = 0;
  Set tester = {};
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // Seed from the strongest recorded period so re-opening a rated symptom
      // shows its level (new writes are uniform, so all three are equal).
      severity = [
        widget.symsMetric.morningSeverity ?? 0,
        widget.symsMetric.afternoonSeverity ?? 0,
        widget.symsMetric.nightSeverity ?? 0,
      ].reduce((a, b) => a > b ? a : b);
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
                  'asset/svg/cough.svg',
                  width: 20.w,
                  height: 20.h,
                ),
              ),
              18.pw,
              CustomText(
                widget.symsMetric.name,
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
                child: Center(
                    child: InkWell(
                  onTap: () {
                    setState(() {
                      if (tester.contains(widget.symsMetric.id)) {
                        tester.clear();
                        return;
                      }
                      tester.clear();
                      tester.add(widget.symsMetric.id);
                    });
                  },
                  child: Icon(
                    !tester.contains(widget.symsMetric.id)
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
          visible: tester.contains(widget.symsMetric.id),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: const Color(0xffEEEDF8),
                border: Border.all(color: const Color(0xffEEEDF8))),
            width: double.infinity,
            child: Column(
              children: [
                10.ph,
                CustomText(
                  'How bad is it?',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColorPurple,
                ),
                10.ph,
                SliderAndValue(
                    onchanged: (value) {
                      isSaveVisible = true;
                      severity = value;
                      setState(() {});
                    },
                    sev: severity),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomText(
                      'Mild',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: severity < .33 ? Colors.green : Colors.grey,
                    ),
                    CustomText(
                      'Moderate',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: severity > .33 && severity < .67
                          ? Colors.amber
                          : Colors.grey,
                    ),
                    CustomText(
                      'Severe',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: severity > .67 ? Colors.red : Colors.grey,
                    ),
                  ],
                ),
                15.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Spacer(flex: 3),
                    Visibility(
                      visible: isSaveVisible,
                      child: CurvedButton(
                        text: 'Save',
                        loading: ref.watch(symsProvider).postSymsStatus ==
                            Loader.loading,
                        onPressed: () async {
                          // One overall severity → all three period columns, so
                          // the day is fully rated (analytics averages the
                          // non-zero periods, giving exactly this value).
                          final v = double.parse(severity.toStringAsFixed(1));
                          final response = await ref
                              .read(symsProvider.notifier)
                              .updateSymsMetric(
                                  widget.symsMetric.id!, v, v, v, widget.date);

                          if (response.successMessage.isNotEmpty) {
                            getAlert(response.successMessage, isWarning: false);
                            isSaveVisible = false;
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              ref
                                  .read(symsProvider.notifier)
                                  .getSymMetric(widget.date);
                            });
                          } else if (response.responseMessage?.isNotEmpty ==
                              true) {
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
                              .read(symsProvider.notifier)
                              .deleteSymsMetric(widget.symsMetric.id!);

                          if (response.successMessage.isNotEmpty) {
                            getAlert(response.successMessage, isWarning: false);
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              ref
                                  .read(symsProvider.notifier)
                                  .getSymMetric(widget.date);
                            });
                          } else if (response.responseMessage?.isNotEmpty ==
                              true) {
                            getAlert(response.responseMessage!);
                          } else {
                            getAlert(response.errorMessage);
                          }
                        },
                        iconSize: 25.r,
                        color: Colors.red.shade500,
                        icon:
                            ref.watch(symsProvider).delStatus == Loader.loading
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
