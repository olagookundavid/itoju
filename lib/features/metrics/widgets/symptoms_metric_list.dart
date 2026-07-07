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
import 'package:itoju_mobile/features/widgets/dates.dart';
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
  final List daysList = [
    'Morning',
    'Afternoon',
    'Evening',
  ];
  double morningSev = 0;
  double afternoonSev = 0;
  double eveningSev = 0;

  final Set dayTags = {timeOfDay()};
  double serverity = 0;
  Set tester = {};
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      morningSev = widget.symsMetric.morningSeverity!;
      afternoonSev = widget.symsMetric.afternoonSeverity!;
      eveningSev = widget.symsMetric.nightSeverity!;
    });
    super.initState();
  }

  bool isSaveVisible = false;
  @override
  Widget build(BuildContext context) {
    serverity = (dayTags.first == 'Morning'
        ? morningSev
        : dayTags.first == 'Afternoon'
            ? afternoonSev
            : eveningSev);
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
                7.ph,
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: List.generate(daysList.length, (index) {
                    final tag = daysList[index];
                    return ActionChip(
                      label: Text(tag),
                      labelStyle: TextStyle(
                          color: dayTags.contains(tag)
                              ? Colors.white
                              : Colors.black),
                      backgroundColor: dayTags.contains(tag)
                          ? AppColors.primaryColorPurple.withOpacity(.85)
                          : null,
                      onPressed: () {
                        setState(() {
                          if (dayTags.contains(tag)) {
                            return;
                          }
                          dayTags.clear();
                          dayTags.add(tag);
                        });
                      },
                    );
                  }),
                ),
                10.ph,
                SliderAndValue(
                    onchanged: (value) {
                      isSaveVisible = true;
                      switch (dayTags.first) {
                        case 'Morning':
                          morningSev = value;
                          break;
                        case 'Afternoon':
                          afternoonSev = value;
                          break;
                        case 'Evening':
                          eveningSev = value;
                          break;
                        default:
                      }
                      setState(() {});
                    },
                    sev: serverity),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomText(
                      'Mild',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: serverity < .33 ? Colors.green : Colors.grey,
                    ),
                    CustomText(
                      'Moderate',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: serverity > .33 && serverity < .67
                          ? Colors.amber
                          : Colors.grey,
                    ),
                    CustomText(
                      'Severe',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: serverity > .67 ? Colors.red : Colors.grey,
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
                          final response = await ref
                              .read(symsProvider.notifier)
                              .updateSymsMetric(
                                  widget.symsMetric.id!,
                                  double.parse(morningSev.toStringAsFixed(1)),
                                  double.parse(afternoonSev.toStringAsFixed(1)),
                                  double.parse(eveningSev.toStringAsFixed(1)),
                                  widget.date);

                          if (response.successMessage.isNotEmpty) {
                            getAlert(response.successMessage, isWarning: false);
                            isSaveVisible = false;
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              ref
                                  .read(symsProvider.notifier)
                                  .getSymMetric(widget.date);
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
                          } else if (response.responseMessage!.isNotEmpty) {
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
