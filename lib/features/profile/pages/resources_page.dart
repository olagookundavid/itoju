import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/auth/notifiers/profile_notifier.dart';
import 'package:itoju_mobile/features/profile/notifiers/resources_notifiers.dart';
import 'package:itoju_mobile/features/profile/pages/admin_resources.dart';
import 'package:itoju_mobile/features/profile/widgets/resources_webview.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/resource_tile.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class ResourcesPage extends ConsumerStatefulWidget {
  const ResourcesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends ConsumerState<ResourcesPage> {
  @override
  void initState() {
    super.initState();
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //   ref.read(resourcesProvider.notifier).getResources();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resourcesProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        actions: [
          if (ref.watch(profileProvider).userModel!.isAdmin ?? false)
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const AdminResources();
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
                width: 120.w,
                height: 60.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  color: AppColors.splash_underlay,
                ),
                child: Center(
                  child: CustomText(
                    'Resources',
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
                                  resource: resource,
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return ResourceWebView(
                                            url: resource.link!);
                                      },
                                    ));
                                  },
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
