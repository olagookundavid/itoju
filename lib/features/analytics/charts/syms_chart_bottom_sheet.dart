import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/metrics/notifiers/symptoms_notifier.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/custom_text_field.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

class SymsChartBottomSheet extends ConsumerStatefulWidget {
  const SymsChartBottomSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<SymsChartBottomSheet> createState() =>
      _SymsChartBottomSheetState();
}

class _SymsChartBottomSheetState extends ConsumerState<SymsChartBottomSheet> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(symsProvider.notifier).getSymptoms();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(symsProvider);
    return Stack(
      children: [
        SingleChildScrollView(
          child: Center(
            child: SizedBox(
              child: StickyHeader(
                header: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      10.ph,
                      const Icon(Icons.keyboard_arrow_up_outlined),
                      // 15.ph,
                      CustomTextField(
                        width: 360.w,
                        hintText: 'Search Symptoms',
                        onChanged: (e) {
                          ref
                              .read(symsProvider.notifier)
                              .getFilteredSymptoms(searchTerm: e);
                        },
                      ),
                      20.ph
                    ],
                  ),
                ),
                content: state.getStatus == Loader.loading
                    ? Center(
                        child: SizedBox(
                            height: 200.h, child: const Center(child: AppLoader())),
                      )
                    : state.getStatus == Loader.error
                        ? SizedBox(
                            height: 200.h, child: const Center(child: Text('Error')))
                        : state.filteredSymsModel!.isEmpty
                            ? SizedBox(
                                height: 200.h,
                                child: Center(
                                    child: CustomText(
                                  'No symptoms available, contact admin',
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColorPurple,
                                )))
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .4,
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        physics: const ClampingScrollPhysics(),
                                        itemBuilder: (context, item) {
                                          final sym =
                                              state.filteredSymsModel![item];

                                          return InkWell(
                                            onTap: () async {
                                              Navigator.pop(context, sym);
                                            },
                                            child: ListTile(
                                              title: Text(
                                                sym.name!,
                                                style: TextStyle(
                                                  fontSize: 17.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors
                                                      .primaryColorPurple,
                                                ),
                                              ),
                                              leading: Container(
                                                width: 40.w,
                                                height: 35.h,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.r),
                                                  color:
                                                      AppColors.splash_underlay,
                                                ),
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    'asset/svg/cough.svg',
                                                    width: 20.w,
                                                    height: 20.w,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, item) =>
                                            const Divider(
                                          thickness: .5,
                                          color: AppColors.primaryColorPurple,
                                        ),
                                        itemCount:
                                            state.filteredSymsModel!.length,
                                      ),
                                    ),
                                  ),
                                  40.ph,
                                ],
                              ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: ref.watch(symsProvider).postStatus == Loader.loading,
          child: SizedBox(
            height: 450.h,
            child: const AppLoader(),
          ),
        )
      ],
    );
  }
}
