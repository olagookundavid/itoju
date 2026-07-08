import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/auth/notifiers/profile_notifier.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/margins.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class AddDiagnosis extends ConsumerStatefulWidget {
  const AddDiagnosis({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddDiagnosisState();
}

class _AddDiagnosisState extends ConsumerState<AddDiagnosis> {
  Set<int> conditionsList = {};

  @override
  void initState() {
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //   ref.watch(getConditionsProvider.notifier).getConditions();
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final state = ref.watch(getConditionsProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: SingleChildScrollView(
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
                          "Welcome ${ref.watch(profileProvider).userModel!.firstName}",
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
                      "Have you been diagnosed with any condition?",
                      fontSize: 12.sp,
                      color: AppColors.hintGrey,
                    ),
                  ],
                ),
              ),
              20.ph,
              // state.status == Loader.loading
              //     ?
              const AppLoader(),
              // : state.status == Loader.error
              // ? Text('Error')
              // : Wrap(
              //     spacing: 8.0,
              //     runSpacing: 8.0,
              //     children: List.generate(state.conditionsLists!.length,
              //         (index) {
              //       final condition = state.conditionsLists![index];
              //       return ActionChip(
              //  labelStyle: TextStyle(
              //                       color: conditionsList.contains(condition.id!)
              //                           ? Colors.white
              //                           : Colors.black),
              //         label: Text(condition.name!),
              //         backgroundColor:
              //             conditionsList.contains(condition.id!)
              //                 ? AppColors.primaryColorPurple
              //                     .withOpacity(.85)
              //                 : null,
              //         onPressed: () {
              //           setState(() {
              //             if (conditionsList.contains(condition.id!)) {
              //               conditionsList.remove(condition.id!);
              //               return;
              //             }
              //             conditionsList.add(condition.id!);
              //           });
              //         },
              //       );
              //     }),
              //   ),
              60.ph,
              CurvedButton(
                text: "Save",
                // loading: ref.watch(addConditionsProvider).loadStatus ==
                //     Loader.loading,
                onPressed: () async {
                  //   if (conditionsList.isEmpty) {
                  //     getAlert( 'You haven\'t chosen any selection!');
                  //     return;
                  //   }
                  //   final response = await ref
                  //       .read(addConditionsProvider.notifier)
                  //       .addConditions(conditionsList.toList());
                  //   if (response.successMessage.isNotEmpty) {
                  //     if (!mounted) return;
                  //     await HiveStorage.put(HiveKeys.setMetrics, true);
                  //     Navigator.pushAndRemoveUntil(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) {
                  //           return LandingPage();
                  //         },
                  //       ),
                  //       (route) => false,
                  //     );
                  //     getAlert( response.successMessage,
                  //         isWarning: false);
                  //   } else if (response.responseMessage!.isNotEmpty) {
                  //     getAlert( response.responseMessage!);
                  //   } else {
                  //     getAlert( response.errorMessage);
                  //   }
                },
              ),
              80.ph
            ],
          ),
        ),
      ),
    );
  }
}
