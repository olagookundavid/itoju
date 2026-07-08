import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/analytics/analytics.dart';
import 'package:itoju_mobile/features/dashboard/pages/dashboard.dart';
import 'package:itoju_mobile/features/home/pages/home.dart';
import 'package:itoju_mobile/features/menses/menses_page.dart';
import 'package:itoju_mobile/features/profile/pages/profile.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

final routeStateProvider = ChangeNotifierProvider.autoDispose((ref) {
  return PersistentTabController(initialIndex: 0);
});

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(routeStateProvider);

    List<Widget> screens() {
      return [
        const DashBoardScreen(),
        const AnalyticsPage(),
        const HomePage(),
        const MensesPage(),
        const ProfilePage(),
      ];
    }

    List<ItemConfig> navBarsItems() {
      const activeColor = AppColors.primaryColorPurple;
      const inActiveColor = Colors.grey;
      return [
        ItemConfig(
          inactiveIcon: SvgPicture.asset('asset/svg/home.svg'),
          icon: SvgPicture.asset('asset/svg/home_full.svg'),
          title: state.index == 0 ? ("Home") : null,
          iconSize: 30.r,
          activeForegroundColor: activeColor,
          inactiveForegroundColor: Colors.grey,
          textStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800),
        ),
        ItemConfig(
          inactiveIcon: SvgPicture.asset('asset/svg/analytics.svg'),
          icon: SvgPicture.asset('asset/svg/analytics_full.svg'),
          title: state.index == 1 ? ("Analytics") : null,
          iconSize: 30.r,
          activeForegroundColor: activeColor,
          inactiveForegroundColor: inActiveColor,
          textStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800),
        ),
        ItemConfig(
          icon: Icon(
            Icons.add,
            color: Colors.white,
            size: 30.r,
          ),
          activeForegroundColor: activeColor,
          inactiveForegroundColor: inActiveColor,
        ),
        ItemConfig(
          inactiveIcon: SvgPicture.asset('asset/svg/calendar.svg'),
          icon: SvgPicture.asset('asset/svg/calendar_full.svg'),
          title: state.index == 3 ? ("Calendar") : null,
          iconSize: 30.r,
          activeForegroundColor: activeColor,
          inactiveForegroundColor: inActiveColor,
          textStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800),
        ),
        ItemConfig(
          inactiveIcon: Icon(
            Icons.person_outline_rounded,
            size: 25.r,
            color: Colors.grey,
          ),
          icon: Icon(Icons.person,
              size: 25.r, color: AppColors.primaryColorPurple),
          title: state.index == 4 ? ("Profile") : null,
          textStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800),
          iconSize: 30.r,
          activeForegroundColor: activeColor,
          inactiveForegroundColor: inActiveColor,
        ),
      ];
    }

    tabs() {
      return List.generate(
        5,
        (index) => PersistentTabConfig(
          screen: screens()[index],
          item: navBarsItems()[index],
        ),
      );
    }

    final PersistentTabController? controller = ref.watch(routeStateProvider);
    return PopScope(
      canPop: false,
      child: PersistentTabView(
        controller: controller,
        navBarBuilder: (navBarConfig) =>
            Style16BottomNavBar(navBarConfig: navBarConfig),
        //
        tabs: tabs(),
        //
        avoidBottomPadding: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        // hideNavigationBarWhenKeyboardShows: true,
        hideNavigationBar: false,
        // decoration: NavBarDecoration(
        //   borderRadius: BorderRadius.circular(10.r),
        //   colorBehindNavBar: Colors.white,
        // ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        // itemAnimationProperties: const ItemAnimationProperties(
        //   duration: Duration(milliseconds: 1000),
        //   curve: Curves.ease,
        // ),
        screenTransitionAnimation: const ScreenTransitionAnimation(
          curve: Curves.decelerate,
          duration: Duration(milliseconds: 300),
        ),
      ),
    );
  }
}
