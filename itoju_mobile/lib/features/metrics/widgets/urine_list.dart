import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/dashboard/widgets/slider_and_value.dart';
import 'package:itoju_mobile/features/metrics/notifiers/urine_notifier.dart';
import 'package:itoju_mobile/features/metrics/pages/urination.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/custom_text_field.dart';
import 'package:itoju_mobile/features/widgets/date_pick_widget.dart';
import 'package:itoju_mobile/features/widgets/dates.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class UrineList extends ConsumerStatefulWidget {
  const UrineList({
    super.key,
    required this.isNew,
    required this.date,
    required this.urineModel,
  });
  final String date;

  final UrineModel urineModel;
  final bool isNew;
  @override
  ConsumerState<UrineList> createState() => _UrineListState();
}

class _UrineListState extends ConsumerState<UrineList> {
  final List tagsList = [
    'A lot',
    'Moderate',
    'Few drops',
  ];
  final List typeNum = [1, 2, 3, 4, 5];
  final List colorType = [
    const Color(0xffFFEAA6),
    const Color(0xffFFD959),
    const Color(0xffFBBB00),
    const Color(0xffF39707),
    const Color(0xffC77B05)
  ];
  final Set userTags = {};
  double pain = 0;
  int type = 0;
  DateTime? time;
  String timeValue = '';
  final quantityCtrl = TextEditingController();

  @override
  void dispose() {
    quantityCtrl.dispose();
    super.dispose();
  }

  final Set dayTags = {timeOfDay()};
  Set tester = {};
  double quantity = 0;
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      pain = widget.urineModel.pain;
      type = widget.urineModel.type;
      timeValue = widget.urineModel.time!;
      time = convertTimeStringToDateTime(timeValue);
      quantity = widget.urineModel.quantity;
      quantityCtrl.text = widget.urineModel.quantity.toString();
      final tags = (widget.urineModel.tags);
      for (String tag in tags) {
        userTags.add(tag);
      }
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
                  'asset/svg/bowel.svg',
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
                    'Urine Movement',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  if (!widget.isNew)
                    CustomText(
                      widget.urineModel.time,
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
                      if (tester.contains(widget.urineModel.id)) {
                        tester.clear();
                        return;
                      }
                      tester.clear();
                      tester.add(widget.urineModel.id);
                    });
                  },
                  child: Icon(
                    !tester.contains(widget.urineModel.id)
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
          visible: tester.contains(widget.urineModel.id),
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
                  'Urine Colour',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColorPurple,
                ),
                10.ph,
                12.ph,
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceAround,
                    children: List.generate(typeNum.length, (index) {
                      final int bowelType = typeNum[index];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            isSaveVisible = true;
                            type = bowelType;
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
                                      width: type == bowelType ? 2 : 0),
                                  borderRadius: BorderRadius.circular(7.r),
                                  color: colorType[index]),
                            ),
                            15.ph,
                            CustomText(
                              (index + 1).toString(),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: type == bowelType
                                  ? AppColors.primaryColorPurple
                                  : const Color(0xffA7ABBE),
                            )
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
                        ),
                        15.ph,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CustomText(
                            'Urine Quantity (optional)',
                            color: AppColors.primaryColorPurple,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        5.ph,
                      ],
                    ),
                  ],
                ),
                5.ph,
                CustomTextField(
                  controller: quantityCtrl,
                  inputType: TextInputType.number,
                  onChanged: (val) {
                    quantity = (int.tryParse(val) ?? 0).toDouble();
                    setState(() {
                      isSaveVisible = true;
                    });
                  },
                ),
                15.ph,
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    'Pain during urination',
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
                    sev: pain),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomText(
                      'Mild',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: pain < .33 ? Colors.green : Colors.grey,
                    ),
                    CustomText(
                      'Moderate',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color:
                          pain > .33 && pain < .67 ? Colors.amber : Colors.grey,
                    ),
                    CustomText(
                      'Severe',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: pain > .67 ? Colors.red : Colors.grey,
                    ),
                  ],
                ),
                20.ph,
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText('Tags',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColorPurple),
                ),
                7.ph,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
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
                            ? AppColors.primaryColorPurple.withOpacity(.85)
                            : null,
                        onPressed: () {
                          setState(() {
                            isSaveVisible = true;
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
                ),
                20.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    Visibility(
                      visible: isSaveVisible,
                      child: CurvedButton(
                        text: widget.isNew ? 'Create' : 'Save',
                        loading: (ref.watch(urineProvider).postStatus ==
                                Loader.loading ||
                            ref.watch(urineProvider).updateStatus ==
                                Loader.loading),
                        onPressed: () async {
                          final response = await (widget.isNew
                              ? ref
                                  .read(urineProvider.notifier)
                                  .createUrineMetric(
                                      widget.date,
                                      UrineModel(
                                          time: timeValue,
                                          tags: userTags.toList(),
                                          pain: pain,
                                          quantity: quantity,
                                          type: type))
                              : ref
                                  .read(urineProvider.notifier)
                                  .updateUrineMetric(UrineModel(
                                      id: widget.urineModel.id!,
                                      time: timeValue,
                                      tags: userTags.toList(),
                                      pain: pain,
                                      quantity: quantity,
                                      type: type)));

                          if (response.successMessage.isNotEmpty) {
                            isSaveVisible = false;
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              ref
                                  .read(urineProvider.notifier)
                                  .getUrineList(widget.date);
                              ref.read(addUrineProvider.notifier).state = false;
                            });

                            getAlert(response.successMessage, isWarning: false);
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
                    Spacer(flex: widget.isNew ? 3 : 2),
                    if (!widget.isNew)
                      IconButton(
                          onPressed: () async {
                            final response = await ref
                                .read(urineProvider.notifier)
                                .deleteSymsMetric(widget.urineModel.id!);

                            if (response.successMessage.isNotEmpty) {
                              getAlert(response.successMessage,
                                  isWarning: false);
                              SchedulerBinding.instance
                                  .addPostFrameCallback((timeStamp) async {
                                ref
                                    .read(urineProvider.notifier)
                                    .getUrineList(widget.date);
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
                          icon: ref.watch(urineProvider).delStatus ==
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
