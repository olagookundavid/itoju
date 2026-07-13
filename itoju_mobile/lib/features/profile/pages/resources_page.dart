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
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/resource_tile.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';

class ResourcesPage extends ConsumerStatefulWidget {
  const ResourcesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends ConsumerState<ResourcesPage> {
  @override
  void initState() {
    super.initState();
    // Self-sufficient fetch: no longer depends on the dashboard having
    // already loaded resources.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resourcesProvider.notifier).getResources();
    });
  }

  Future<void> _fetch() =>
      ref.read(resourcesProvider.notifier).getResources();

  /// Manual sync: pull the freshest resources from the server. When offline the
  /// cached list stays on screen and we tell the user they're seeing saved data.
  Future<void> _sync() async {
    final refreshed = await ref.read(resourcesProvider.notifier).getResources();
    if (!mounted) return;
    if (refreshed) {
      getAlert('Resources updated', isWarning: false);
    } else {
      getAlert("You're offline — showing saved resources");
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resourcesProvider);
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        actions: [
          // Manual sync — refresh the resources from the server on demand.
          state.syncing
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Center(
                    child: SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryColorPurple,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  tooltip: 'Sync resources',
                  onPressed: _sync,
                  icon: const Icon(
                    Icons.sync,
                    color: AppColors.primaryColorPurple,
                  ),
                ),
          if (ref.watch(profileProvider).userModel?.isAdmin ?? false)
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
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ResourcesState state) {
    if (state.getStatus == Loader.loading) {
      return const AppLoader();
    }

    if (state.getStatus == Loader.error) {
      return _buildError();
    }

    final resources = state.resourcesModel ?? const <ResourcesModel>[];
    return RefreshIndicator(
      color: AppColors.primaryColorPurple,
      onRefresh: _fetch,
      child: resources.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 120.h),
                Center(
                  child: CustomText(
                    'No Resources Available Yet',
                    fontSize: 14.sp,
                    color: AppColors.hintGrey,
                  ),
                ),
              ],
            )
          : GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 1),
              itemCount: resources.length,
              itemBuilder: (context, index) {
                final resource = resources[index];
                return ResourcesTile(
                  resource: resource,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return ResourceWebView(url: resource.link!);
                      },
                    ));
                  },
                );
              },
            ),
    );
  }

  Widget _buildError() {
    return RefreshIndicator(
      color: AppColors.primaryColorPurple,
      onRefresh: _fetch,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 100.h),
          Icon(Icons.wifi_off_rounded,
              size: 48.sp, color: AppColors.hintGrey),
          16.ph,
          Center(
            child: CustomText(
              "Couldn't load resources",
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
              textAlign: TextAlign.center,
            ),
          ),
          8.ph,
          Center(
            child: CustomText(
              'Please check your connection and try again.',
              fontSize: 13.sp,
              color: AppColors.hintGrey,
              textAlign: TextAlign.center,
            ),
          ),
          20.ph,
          Center(
            child: SizedBox(
              width: 160.w,
              child: CurvedButton(
                text: 'Retry',
                height: 46.h,
                onPressed: _fetch,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
