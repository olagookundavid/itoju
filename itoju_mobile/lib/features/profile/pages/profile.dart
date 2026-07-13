// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/auth/notifiers/profile_notifier.dart';
import 'package:itoju_mobile/features/dashboard/widgets/achievement_widget.dart';
import 'package:itoju_mobile/features/profile/pages/resources_page.dart';
import 'package:itoju_mobile/features/profile/widgets/profile_tiles.dart';
import 'package:itoju_mobile/features/settings/notifier/points_notifier.dart';
import 'package:itoju_mobile/features/settings/pages/settings.dart';
import 'package:itoju_mobile/features/widgets/coming_soon.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      pic_no = ref.watch(profileProvider).userModel?.pic_no ?? 0;
      setState(() {});
    });
    super.initState();
  }

  int pic_no = 0;
  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(profileProvider).userModel;
    final displayName = userModel != null
        ? '${userModel.firstName ?? ''} ${userModel.lastName ?? ''}'.trim()
        : (HiveStorage.get(HiveKeys.localName) ?? 'Guest');
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                20.ph,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    500.pw,
                    InkWell(
                      onTap: () async {
                        pic_no = await showModalBottomSheet(
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(30.r),
                              ),
                            ),
                            context: context,
                            builder: (ccontext) => const ProfilePicSheet());
                        getAlert('Your profile avatar has been updated',
                            isWarning: false);
                      },
                      child: pic_no == 0
                          ? Container(
                              width: 120.w,
                              height: 120.h,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.r),
                                color: AppColors.primaryColorPurple,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 40.sp,
                                  ),
                                  CustomText(
                                    'Click To Add Profile Picture',
                                    maxline: 3,
                                    textAlign: TextAlign.center,
                                    fontSize: 11.sp,
                                  )
                                ],
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.r)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.r),
                                child: Image.asset(
                                  'asset/avatars/$pic_no.png',
                                  fit: BoxFit.fill,
                                ),
                              )),
                    ),
                    5.ph,
                    CustomText(displayName,
                        color: AppColors.primaryColorPurple,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500),
                    3.ph,
                    if (userModel?.email != null) ...[
                      CustomText(userModel!.email,
                          color: Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500),
                    ],
                    50.ph,
                  ],
                ),
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
                30.ph,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ProfileTiles(
                      image: 'settings_gear',
                      label: 'Settings',
                      onTap: () {
                        pushScreen(
                          context,
                          screen: const SettingsPage(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                    ProfileTiles(
                      image: 'export_report',
                      label: 'Export Report',
                      onTap: () {
                        showModalBottomSheet(
                          isDismissible: false,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(30.r),
                            ),
                          ),
                          context: context,
                          builder: (ccontext) => const ComingSoonBottomSheet(
                            icon: 'export_report',
                            title: 'Watch Out!',
                          ),
                        );
                        // pushScreen(
                        //   context,
                        //   screen: const ExportReport(),
                        //   withNavBar: false,
                        //   pageTransitionAnimation:
                        //       PageTransitionAnimation.cupertino,
                        // );
                      },
                    ),
                    ProfileTiles(
                      image: 'resource',
                      label: 'Resources',
                      onTap: () {
                        pushScreen(
                          context,
                          screen: const ResourcesPage(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                  ],
                ),
                10.ph,
                ProfileTiles(
                  image: 'discuss',
                  label: 'Discussions',
                  onTap: () {
                    showModalBottomSheet(
                      isDismissible: false,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30.r),
                        ),
                      ),
                      context: context,
                      builder: (ccontext) => const ComingSoonBottomSheet(
                        icon: 'discuss',
                        title: 'Watch Out!',
                      ),
                    );
                  },
                ),
                30.ph,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfilePicSheet extends ConsumerWidget {
  const ProfilePicSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 500.h,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.h),
        child: Column(
          children: [
            15.ph,
            const CustomText('Choose An Avatar!',
                color: AppColors.primaryColorPurple),
            10.ph,
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: 30,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 1),
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () async {
                      final response = await ref
                          .read(profileProvider.notifier)
                          .updateProfilePic(index + 1);
                      if (response.successMessage.isNotEmpty) {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context, index + 1);
                      } else if (response.responseMessage!.isNotEmpty) {
                        getAlert(response.responseMessage!);
                      } else {
                        getAlert(response.errorMessage);
                      }
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.asset(
                            'asset/avatars/${index + 1}.png',
                            fit: BoxFit.fill,
                          ),
                        )),
                  );
                },
              ),
            ),
            30.ph
          ],
        ),
      ),
    );
  }
}
