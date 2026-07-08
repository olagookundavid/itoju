// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/auth/notifiers/add_metrics_notifier.dart';
import 'package:itoju_mobile/features/auth/notifiers/get_tracked_metric_notifier.dart';
import 'package:itoju_mobile/features/auth/notifiers/profile_notifier.dart';
import 'package:itoju_mobile/features/auth/pages/add_conditions.dart';
import 'package:itoju_mobile/features/home/notifer/getTrackedMetrics_notifier.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/margins.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class AddTrackedMetrics extends ConsumerStatefulWidget {
  const AddTrackedMetrics({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddTrackedMetricsState();
}

class _AddTrackedMetricsState extends ConsumerState<AddTrackedMetrics> {
  Set<int> metricsList = {};
  Set<int> deleteList = {};

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      await ref.watch(metricProvider.notifier).getMetric();
      await ref.watch(metricProvider.notifier).getUserMetric();
      final userMetrics = ref.read(metricProvider).userMetricLists;
      for (MetricModel metric in userMetrics!) {
        metricsList.add(metric.id!);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(metricProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                color: AppColors.splash_underlay,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        "Welcome ${ref.watch(profileProvider).userModel?.firstName}",
                        fontSize: 16.sp,
                        color: AppColors.primaryColorPurple,
                        fontWeight: FontWeight.w700,
                      ),
                      10.pw,
                      CustomText(
                        "👋",
                        fontSize: 25.sp,
                        fontWeight: FontWeight.w700,
                      )
                    ],
                  ),
                  verticalSpaceSmall,
                  CustomText(
                    "What would you love to track?",
                    fontSize: 12.sp,
                    color: AppColors.hintGrey,
                  ),
                ],
              ),
            ),
            20.ph,
            Expanded(
              child: Column(
                children: [
                  state.status == Loader.loading
                      ? const AppLoader()
                      : state.status == Loader.error
                          ? ErrorCon(
                              func: () {
                                SchedulerBinding.instance
                                    .addPostFrameCallback((timeStamp) async {
                                  await ref
                                      .watch(metricProvider.notifier)
                                      .getMetric();
                                  await ref
                                      .watch(metricProvider.notifier)
                                      .getUserMetric();
                                  final userMetrics =
                                      ref.read(metricProvider).userMetricLists;
                                  for (MetricModel metric in userMetrics!) {
                                    metricsList.add(metric.id!);
                                  }
                                });
                              },
                            )
                          : Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: List.generate(
                                  state.metricLists?.length ?? 0, (index) {
                                final metric = state.metricLists![index];
                                return ActionChip(
                                  label: Text(metric.name!),
                                  labelStyle: TextStyle(
                                      color: metricsList.contains(metric.id!)
                                          ? Colors.white
                                          : Colors.black),
                                  backgroundColor:
                                      metricsList.contains(metric.id!)
                                          ? AppColors.primaryColorPurple
                                              .withOpacity(.85)
                                          : null,
                                  onPressed: () {
                                    setState(() {
                                      if (metricsList.contains(metric.id!)) {
                                        metricsList.remove(metric.id!);
                                        deleteList.add(metric.id!);
                                        return;
                                      }
                                      metricsList.add(metric.id!);
                                      deleteList.remove(metric.id!);
                                    });
                                  },
                                );
                              }),
                            ),
                  const Spacer(),
                  CurvedButton(
                    text: "Save",
                    loading: ref.watch(addMetricsProvider).loadStatus ==
                        Loader.loading,
                    onPressed: () async {
                      if (metricsList.isEmpty) {
                        getAlert('You haven\'t chosen any selection!');
                        return;
                      }
                      final response = await ref
                          .read(addMetricsProvider.notifier)
                          .addMetrics(
                              metricsList.toList(), deleteList.toList());
                      if (response.successMessage.isNotEmpty) {
                        if (!mounted) return;
                        bool setMetrics =
                            HiveStorage.get(HiveKeys.setMetrics) ?? false;
                        if (!setMetrics) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const AddConditions();
                              },
                            ),
                          );
                        }
                        ref
                            .read(getUserMetricsProvider.notifier)
                            .getGetUserMetrics();
                        getAlert(response.successMessage, isWarning: false);
                      } else if (response.responseMessage!.isNotEmpty) {
                        getAlert(response.responseMessage!);
                      } else {
                        getAlert(response.errorMessage);
                      }
                    },
                  ),
                  80.ph,
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OptionsButton extends StatefulWidget {
  final String? option;
  final int? selectedIndex;
  final bool? userSelected;
  final VoidCallback? onTap;
  const OptionsButton({
    Key? key,
    this.option,
    this.selectedIndex,
    this.userSelected,
    this.onTap,
  }) : super(key: key);

  @override
  _OptionsButtonState createState() => _OptionsButtonState();
}

class _OptionsButtonState extends State<OptionsButton> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
        widget.onTap!();
      },
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryColorPurple
                  : AppColors.borderGrey,
            ),
            color:
                isSelected ? AppColors.primaryColorPurple : Colors.transparent,
          ),
          child: Center(
            child: CustomText(
              widget.option,
              fontSize: 12.sp,
              color: isSelected ? Colors.white : AppColors.primaryColorPurple,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
