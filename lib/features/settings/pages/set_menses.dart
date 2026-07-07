import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/features/settings/notifier/menses_notifier.dart';
import 'package:itoju_mobile/features/settings/widgets/sign_value_widget.dart';
import 'package:itoju_mobile/features/settings/widgets/sign_widget.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class SetMenses extends ConsumerStatefulWidget {
  const SetMenses({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SetMensesState();
}

class _SetMensesState extends ConsumerState<SetMenses> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      await ref.read(mensesProvider.notifier).getMenses();
      periodCtrl.text =
          (ref.read(mensesProvider).mensesModel?.periodLen ?? 0).toString();
      cycleCtrl.text =
          (ref.read(mensesProvider).mensesModel?.cycleLen ?? 0).toString();
    });
    super.initState();
  }

  final periodCtrl = TextEditingController();
  final cycleCtrl = TextEditingController();
  @override
  void dispose() {
    periodCtrl.dispose();
    cycleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mensesProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: state.getStatus == Loader.loading
              ? const AppLoader()
              : state.getStatus == Loader.error
                  ? ErrorCon(
                      func: () {
                        SchedulerBinding.instance
                            .addPostFrameCallback((timeStamp) async {
                          await ref.read(mensesProvider.notifier).getMenses();
                          periodCtrl.text = (ref
                                      .read(mensesProvider)
                                      .mensesModel
                                      ?.periodLen ??
                                  0)
                              .toString();
                          cycleCtrl.text =
                              (ref.read(mensesProvider).mensesModel?.cycleLen ??
                                      0)
                                  .toString();
                        });
                      },
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        30.ph,
                        CustomText(
                          'Period Length (Days)',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xffEEAF4B),
                        ),
                        15.ph,
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 10.h),
                            width: 280.w,
                            height: 122.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: const Color(0xffF8F8FC),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SignWigdet(
                                  isAdd: false,
                                  onTap: () {
                                    setState(() {
                                      if ((int.tryParse(periodCtrl.text) ??
                                              0) ==
                                          0) {
                                        return;
                                      }
                                      periodCtrl.text =
                                          ((int.tryParse(periodCtrl.text) ??
                                                      0) -
                                                  1)
                                              .toString();
                                    });
                                  },
                                ),
                                SignValueWigdet(ctrl: periodCtrl),
                                SignWigdet(
                                  isAdd: true,
                                  onTap: () {
                                    setState(() {
                                      periodCtrl.text =
                                          ((int.tryParse(periodCtrl.text)!) + 1)
                                              .toString();
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        50.ph,
                        CustomText(
                          'Cycle Length (Days)',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xffEEAF4B),
                        ),
                        15.ph,
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 10.h),
                            width: 280.w,
                            height: 122.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: const Color(0xffF8F8FC),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SignWigdet(
                                  isAdd: false,
                                  onTap: () {
                                    setState(() {
                                      if ((int.tryParse(cycleCtrl.text) ?? 0) ==
                                          0) {
                                        return;
                                      }
                                      cycleCtrl.text =
                                          ((int.tryParse(cycleCtrl.text) ?? 0) -
                                                  1)
                                              .toString();
                                    });
                                  },
                                ),
                                SignValueWigdet(ctrl: cycleCtrl),
                                SignWigdet(
                                  isAdd: true,
                                  onTap: () {
                                    setState(() {
                                      cycleCtrl.text =
                                          ((int.tryParse(cycleCtrl.text) ?? 0) +
                                                  1)
                                              .toString();
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        30.ph,
                        CurvedButton(
                            text: 'Update',
                            loading: ref.watch(mensesProvider).postStatus ==
                                Loader.loading,
                            onPressed: () async {
                              if (int.tryParse(periodCtrl.text) == null ||
                                  int.tryParse(periodCtrl.text) == null) {
                                getAlert('Both field\'s must be integers');
                                return;
                              }
                              final response = await ref
                                  .read(mensesProvider.notifier)
                                  .updateMenses(int.parse(periodCtrl.text),
                                      int.parse(cycleCtrl.text));

                              if (response.successMessage.isNotEmpty) {
                                getAlert(response.successMessage,
                                    isWarning: false);
                              } else if (response.responseMessage!.isNotEmpty) {
                                getAlert(response.responseMessage!);
                              } else {
                                getAlert(response.errorMessage);
                              }
                            }),
                        // GridView.builder(
                        //   shrinkWrap: true,
                        //   physics: const NeverScrollableScrollPhysics(),
                        //   primary: false,
                        //   itemCount: 6,
                        //   gridDelegate:
                        //       SliverGridDelegateWithFixedCrossAxisCount(
                        //           crossAxisCount: 3,
                        //           crossAxisSpacing: 7.w,
                        //           mainAxisSpacing: 10.w,
                        //           childAspectRatio: 1.6),
                        //   itemBuilder: (BuildContext context, int index) {
                        //     return;
                        //   },
                        // ),
                        // Image.asset('asset/avatars/1.png')
                      ],
                    ),
        ),
      ),
    );
  }
}
