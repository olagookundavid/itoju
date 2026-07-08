import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/profile/notifiers/resources_notifiers.dart';
import 'package:itoju_mobile/features/profile/pages/resource_detail.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/resource_tile.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class AdminResources extends ConsumerStatefulWidget {
  const AdminResources({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AdminResourcesState();
}

class _AdminResourcesState extends ConsumerState<AdminResources> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resourcesProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const ResourcesDetail();
                },
              ));
            },
            child: const Icon(
              Icons.add,
            ),
          ),
          10.pw
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 250.w,
                height: 60.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  color: AppColors.splash_underlay,
                ),
                child: Center(
                  child: CustomText(
                    'Admin Resources Access',
                    color: AppColors.primaryColorPurple,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                )),
            20.ph,
            state.getStatus == Loader.loading
                ? const AppLoader()
                : state.getStatus == Loader.error
                    ? const Text('Error')
                    : state.resourcesModel!.isEmpty
                        ? const Text('No Resources Available Yet')
                        : Expanded(
                            child: GridView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 5.w,
                                      mainAxisSpacing: 10.h,
                                      childAspectRatio: 1),
                              itemCount: state.resourcesModel!.length,
                              itemBuilder: (context, index) {
                                final resource = state.resourcesModel![index];
                                return ResourcesTile(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return ResourcesDetail(
                                            resource: resource);
                                      },
                                    ));
                                  },
                                  resource: resource,
                                );
                              },
                            ),
                          ),
          ],
        ),
      ),
    );
  }
}
