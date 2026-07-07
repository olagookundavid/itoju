import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/dashboard/widgets/slider_and_value.dart';
import 'package:itoju_mobile/features/metrics/notifiers/bowel_notifier.dart';
import 'package:itoju_mobile/features/metrics/pages/bowel_movements.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/date_pick_widget.dart';
import 'package:itoju_mobile/features/widgets/dates.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class BowelList extends ConsumerStatefulWidget {
  const BowelList({super.key, 
    required this.isNew,
    required this.date,
    required this.bowelModel,
  });
  final String date;

  final BowelModel bowelModel;
  final bool isNew;
  @override
  ConsumerState<BowelList> createState() => _BowelListState();
}

class _BowelListState extends ConsumerState<BowelList> {
  final List tagsList = [
    'Bloody Stool',
    'Mucous in stool',
    'A lot',
    'Little',
    'Greenish',
    'Yellowish',
    'Blackish'
  ];
  final List typeNum = [1, 2, 3, 4, 5, 6, 7];
  final Set userTags = {};
  double pain = 0;
  int type = 0;
  DateTime? time;
  String timeValue = '';

  final Set dayTags = {timeOfDay()};
  Set tester = {};
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      pain = widget.bowelModel.pain;
      type = widget.bowelModel.type;
      timeValue = widget.bowelModel.time!;
      time = convertTimeStringToDateTime(timeValue);
      final tags = (widget.bowelModel.tags);
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
                    'Bowel Movement',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  if (!widget.isNew)
                    CustomText(
                      widget.bowelModel.time,
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
                      if (tester.contains(widget.bowelModel.id)) {
                        tester.clear();
                        return;
                      }
                      tester.clear();
                      tester.add(widget.bowelModel.id);
                    });
                  },
                  child: Icon(
                    !tester.contains(widget.bowelModel.id)
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
          visible: tester.contains(widget.bowelModel.id),
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
                  'Bristol Stool type',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColorPurple,
                ),
                10.ph,
                Container(
                  height: 70.h,
                  width: 70.w,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: AppColors.primaryColorPurple, width: 1.8),
                      borderRadius: BorderRadius.circular(7.r)),
                  child:
                      type == 0 ? null : Image.asset('asset/png/type$type.png'),
                ),
                12.ph,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(typeNum.length, (index) {
                      final int bowelType = typeNum[index];
                      return ActionChip(
                        label: Text('type $bowelType'),
                        labelStyle: TextStyle(
                            color: type == bowelType
                                ? Colors.white
                                : Colors.black),
                        backgroundColor: type == bowelType
                            ? AppColors.primaryColorPurple.withOpacity(.85)
                            : null,
                        onPressed: () {
                          setState(() {
                            isSaveVisible = true;
                            type = bowelType;
                          });
                        },
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
                15.ph,
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    'Pain during movement',
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
                        loading: (ref.watch(bowelProvider).postStatus ==
                                Loader.loading ||
                            ref.watch(bowelProvider).updateStatus ==
                                Loader.loading),
                        onPressed: () async {
                          final response = await (widget.isNew
                              ? ref
                                  .read(bowelProvider.notifier)
                                  .createBowelMetric(
                                      widget.date,
                                      BowelModel(
                                          time: timeValue,
                                          tags: userTags.toList(),
                                          pain: pain,
                                          type: type))
                              : ref
                                  .read(bowelProvider.notifier)
                                  .updateBowelMetric(BowelModel(
                                      id: widget.bowelModel.id!,
                                      time: timeValue,
                                      tags: userTags.toList(),
                                      pain: pain,
                                      type: type)));

                          if (response.successMessage.isNotEmpty) {
                            getAlert(response.successMessage, isWarning: false);
                            isSaveVisible = false;
                            SchedulerBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              ref
                                  .read(bowelProvider.notifier)
                                  .getBowelList(widget.date);
                              ref.read(addBowelProvider.notifier).state = false;
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
                    Spacer(flex: widget.isNew ? 3 : 2),
                    if (!widget.isNew)
                      IconButton(
                          onPressed: () async {
                            final response = await ref
                                .read(bowelProvider.notifier)
                                .deleteSymsMetric(widget.bowelModel.id!);

                            if (response.successMessage.isNotEmpty) {
                              getAlert(response.successMessage,
                                  isWarning: false);
                              SchedulerBinding.instance
                                  .addPostFrameCallback((timeStamp) async {
                                ref
                                    .read(bowelProvider.notifier)
                                    .getBowelList(widget.date);
                              });
                            } else if (response.responseMessage!.isNotEmpty) {
                              getAlert(response.responseMessage!);
                            } else {
                              getAlert(response.errorMessage);
                            }
                          },
                          iconSize: 25.r,
                          color: Colors.red.shade500,
                          icon: ref.watch(bowelProvider).delStatus ==
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
