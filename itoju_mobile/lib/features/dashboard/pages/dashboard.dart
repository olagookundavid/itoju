import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/auth/notifiers/profile_notifier.dart';
import 'package:itoju_mobile/features/dashboard/notifiers/getSmiley_notifier.dart';
import 'package:itoju_mobile/features/dashboard/notifiers/get_most_tracked_syms_notifier.dart';
import 'package:itoju_mobile/features/dashboard/widgets/achievement_widget.dart';
import 'package:itoju_mobile/features/dashboard/widgets/reoccuring_sysm.dart';
import 'package:itoju_mobile/features/dashboard/widgets/smiley_line.dart';
import 'package:itoju_mobile/features/landing/landing_page.dart';
import 'package:itoju_mobile/features/profile/notifiers/resources_notifiers.dart';
import 'package:itoju_mobile/features/profile/widgets/resources_webview.dart';
import 'package:itoju_mobile/features/settings/notifier/points_notifier.dart';
import 'package:itoju_mobile/features/settings/pages/settings.dart';
import 'package:itoju_mobile/features/widgets/app_loader.dart';
import 'package:itoju_mobile/features/widgets/cached_image.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/dates.dart';
import 'package:itoju_mobile/features/widgets/dotted_border.dart';
import 'package:itoju_mobile/features/widgets/error_con.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DashBoardScreen extends ConsumerStatefulWidget {
  const DashBoardScreen({super.key});

  @override
  ConsumerState<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends ConsumerState<DashBoardScreen> {
  Future<void> _handleRefresh() async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(profileProvider.notifier).getProfile();
      ref.read(getSmileyProvider.notifier).getGetSmiley();
      ref.read(getTrackedSymsProvider.notifier).getGetTrackedSyms();
      Timer(const Duration(seconds: 2), () {
        ref.read(resourcesProvider.notifier).getResources();
        ref.read(pointProvider.notifier).getPoint();
      });
    });
  }

  @override
  void initState() {
    _handleRefresh();
    super.initState();
  }

  double getCountForSmileyId(
      List<SmileyModel> smileyList, int id, int totalCount) {
    // No `orElse` used to throw a StateError (crashing the whole dashboard
    // build) whenever the smiley catalog was missing an id — e.g. right after
    // a data wipe, before the seed/first sync settles. Missing id -> 0 count.
    SmileyModel? firstSmiley;
    for (final element in smileyList) {
      if (element.id == id) {
        firstSmiley = element;
        break;
      }
    }
    if (firstSmiley == null) return 0;
    var count = (firstSmiley.count ?? 0) / totalCount;
    return count.isNaN ? 0 : count;
  }

  int activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final trackedSymsState = ref.watch(getTrackedSymsProvider);

    final resourceState = ref.watch(resourcesProvider);
    final smileyState = ref.watch(getSmileyProvider);
    final smileyList = smileyState.smileyModel ?? [];
    final totalCount = smileyState.totalCount ?? 0;

    final isSmileyLoaded = smileyState.status == Loader.loaded;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppColors.primaryColorPurple,
        onRefresh: _handleRefresh,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              500.pw,
              60.ph,
              SizedBox(
                height: 60.h,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          "Hi ${state.status == Loader.loaded && state.userModel?.firstName != null ? state.userModel!.firstName! : HiveStorage.get(HiveKeys.localName) ?? '....'} 🤗",
                          fontSize: 16.sp,
                          color: AppColors.primaryColorPurple,
                          fontWeight: FontWeight.w800,
                        ),
                        6.ph,
                        CustomText(
                          "Good ${timeOfDay()}",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.hintGrey,
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        pushScreen(
                          context,
                          screen: const SettingsPage(),
                          // withNavBar: true, //TODO
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      child: Container(
                        height: 30.h,
                        width: 30.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.borderGrey,
                          ),
                          color: Colors.transparent,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.settings_outlined,
                            size: 25.r,
                            color: AppColors.primaryColorPurple,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      20.ph,
                      DashedRect(
                        color: AppColors.primaryColorPurple,
                        gap: 6.0,
                        strokeWidth: 1,
                        child: Container(
                          margin: EdgeInsets.all(12.h),
                          height: 300.h,
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          decoration: BoxDecoration(
                              color: Colors.yellow.shade100,
                              borderRadius: BorderRadius.circular(10.r)),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColorPurple,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10.r),
                                        bottomRight: Radius.circular(10.r))),
                                child: const Text(
                                  '30 Days at a glance',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              30.ph,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SmileyLine(
                                      emotes: '😃',
                                      value: (isSmileyLoaded
                                          ? getCountForSmileyId(
                                              smileyList, 1, totalCount)
                                          : 0)),
                                  SmileyLine(
                                      emotes: '🙂',
                                      value: (isSmileyLoaded
                                          ? getCountForSmileyId(
                                              smileyList, 2, totalCount)
                                          : 0)),
                                  SmileyLine(
                                      emotes: '😑',
                                      value: (isSmileyLoaded
                                          ? getCountForSmileyId(
                                              smileyList, 3, totalCount)
                                          : 0)),
                                  SmileyLine(
                                      emotes: '🙁',
                                      value: (isSmileyLoaded
                                          ? getCountForSmileyId(
                                              smileyList, 4, totalCount)
                                          : 0)),
                                  SmileyLine(
                                      emotes: '😢',
                                      value: (isSmileyLoaded
                                          ? getCountForSmileyId(
                                              smileyList, 5, totalCount)
                                          : 0)),
                                ],
                              ),
                              20.ph,
                              InkWell(
                                onTap: () {
                                  ref.read(routeStateProvider).jumpToTab(1);
                                },
                                child: Text(
                                  'Check Analytics',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationColor:
                                          AppColors.primaryColorPurple,
                                      decorationThickness: 2,
                                      color: AppColors.primaryColorPurple,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      20.ph,
                      CustomText(
                        'Recurring Symptoms',
                        fontSize: 15.sp,
                        color: AppColors.primaryColorPurple,
                        fontWeight: FontWeight.w600,
                      ),
                      10.ph,
                      trackedSymsState.status == Loader.loading
                          ? const AppLoader()
                          : trackedSymsState.status == Loader.error
                              ? const Text('error')
                              : (trackedSymsState.symsModel ?? const []).isEmpty
                                  ? const Text("No Recently Tracked Symptoms")
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      primary: false,
                                      padding: const EdgeInsets.all(0),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 10.w,
                                              mainAxisSpacing: 20.h,
                                              childAspectRatio: (1 / .9)),
                                      itemCount: (trackedSymsState.symsModel ??
                                              const [])
                                          .length,
                                      itemBuilder: (context, index) {
                                        final syms =
                                            trackedSymsState.symsModel![index];
                                        return ReoccurringSyms(
                                            'cough',
                                            syms.name ?? '',
                                            (syms.count ?? 0).toString());
                                      },
                                    ),
                      20.ph,
                      CustomText(
                        'Achievements',
                        fontSize: 15.sp,
                        color: AppColors.primaryColorPurple,
                        fontWeight: FontWeight.w600,
                      ),
                      10.ph,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AchievementWidget(
                            text1: ref
                                    .watch(pointProvider)
                                    .pointModel
                                    ?.todayPts
                                    .toString() ??
                                '0',
                            text2: 'Today Points',
                          ),
                          AchievementWidget(
                            text1: ref
                                    .watch(pointProvider)
                                    .pointModel
                                    ?.weekPts
                                    .toString() ??
                                '0',
                            text2: 'Week Points',
                          ),
                          AchievementWidget(
                            text1: ref
                                    .watch(pointProvider)
                                    .pointModel
                                    ?.totalPts
                                    .toString() ??
                                '0',
                            text2: 'Total Points',
                          ),
                        ],
                      ),
                      20.ph,
                      CustomText(
                        'Resources',
                        fontSize: 15.sp,
                        color: AppColors.primaryColorPurple,
                        fontWeight: FontWeight.w600,
                      ),
                      10.ph,
                      resourceState.getStatus == Loader.loading
                          ? const AppLoader()
                          : resourceState.getStatus == Loader.error
                              ? MiniErrorCon(
                                  func: () {
                                    SchedulerBinding.instance
                                        .addPostFrameCallback(
                                            (timeStamp) async {
                                      ref
                                          .read(resourcesProvider.notifier)
                                          .getResources();
                                    });
                                  },
                                )
                              : (resourceState.resourcesModel ?? const [])
                                      .isEmpty
                                  ? const Text('No Resources Available Yet')
                                  : Column(
                                      children: [
                                        CarouselSlider.builder(
                                          itemCount:
                                              (resourceState.resourcesModel ??
                                                      const [])
                                                  .length,
                                          itemBuilder:
                                              (context, index, realIndex) {
                                            final resource = resourceState
                                                .resourcesModel![index];
                                            return InkWell(
                                              onTap: () {
                                                final link = resource.link;
                                                if (link == null) return;
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                  builder: (context) {
                                                    return ResourceWebView(
                                                        url: link);
                                                  },
                                                ));
                                              },
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    15.r))),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  15.r)),
                                                      child: CachedImageHelper(
                                                          url:
                                                              resource.imgUrl ??
                                                                  ''),
                                                    ),
                                                  ),
                                                  Positioned(
                                                      bottom: 10.h,
                                                      child: CustomText(
                                                        resource.name,
                                                      ))
                                                ],
                                              ),
                                            );
                                          },
                                          options: CarouselOptions(
                                              aspectRatio: 16 / 9,
                                              viewportFraction: 1,
                                              initialPage: 0,
                                              enableInfiniteScroll: false,
                                              autoPlay: false,
                                              // autoPlayInterval:
                                              //     const Duration(seconds: 15),
                                              // autoPlayAnimationDuration:
                                              //     const Duration(
                                              //         milliseconds: 500),
                                              autoPlayCurve:
                                                  Curves.fastOutSlowIn,
                                              enlargeCenterPage: true,
                                              scrollDirection: Axis.horizontal,
                                              onPageChanged: (index, reason) {
                                                setState(() {
                                                  activeIndex = index;
                                                });
                                              }),
                                        ),
                                        5.ph,
                                        AnimatedSmoothIndicator(
                                          activeIndex: activeIndex,
                                          count:
                                              (resourceState.resourcesModel ??
                                                      const [])
                                                  .length,
                                          effect: JumpingDotEffect(
                                            dotWidth: 7.w,
                                            dotHeight: 7.h,
                                          ),
                                        )
                                      ],
                                    ),
                      100.ph,
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
