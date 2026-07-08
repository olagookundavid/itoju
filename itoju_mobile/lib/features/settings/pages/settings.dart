import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/auth/session.dart';
import 'package:itoju_mobile/features/auth/pages/login.dart';
import 'package:itoju_mobile/services/dio_provider.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/auth/pages/add_conditions.dart';
import 'package:itoju_mobile/features/auth/pages/add_tracked_metrics.dart';
import 'package:itoju_mobile/features/auth/pages/change_password.dart';
import 'package:itoju_mobile/features/settings/pages/set_body_data.dart';
import 'package:itoju_mobile/features/settings/pages/set_menses.dart';
import 'package:itoju_mobile/features/settings/widgets/settings_tile.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool switchValueAuth = false;
  bool switchValueFingerPrint =
      HiveStorage.get(HiveKeys.showBiometrics) ?? false;
  bool switchValueAppLock = Session.isAppLockEnabled();

  Future<void> _logout(BuildContext context) async {
    // Revoke the token server-side first (best-effort), then tear down the
    // local session and provider sessions.
    try {
      await ref.read(dioProvider).post('logout');
    } catch (_) {
      // Offline or already-invalid token — local teardown below still applies.
    }
    await Session.clearLocal();
    await Session.signOutProviders();
    if (!context.mounted) return;
    // Fresh route so the AuthGate/login state isn't a stale in-stack screen.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const CustomBackButton(), actions: [
        InkWell(
          onTap: () => _logout(context),
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              border:
                  Border.all(width: .5.w, color: AppColors.primaryColorPurple),
              borderRadius: BorderRadius.circular(5.r),
            ),
            margin: EdgeInsets.only(right: 10.w),
            child: Icon(
              Icons.logout_rounded,
              size: 20.r,
            ),
          ),
        )
      ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 120.w,
                  height: 60.h,
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.r),
                    color: AppColors.splash_underlay,
                  ),
                  child: Center(
                    child: CustomText(
                      'Settings',
                      color: AppColors.primaryColorPurple,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  )),
              5.ph,
              SettingsTile(
                  image: 'blood',
                  text: 'Menstruation',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const SetMenses();
                      },
                    ));
                  }),
              SettingsTile(
                  image: 'body',
                  text: 'Body Measurements',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const SetBodyData();
                      },
                    ));
                  }),
              SettingsTile(
                  image: 'medical',
                  text: 'Diagnosed Conditions',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const AddConditions();
                      },
                    ));
                  }),
              SettingsTile(
                  image: 'tracks',
                  text: 'Tracking',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const AddTrackedMetrics();
                      },
                    ));
                  }),
              // SettingsTile(
              //     image: 'medical',
              //     text: 'Diagnosed Conditions',
              //     onTap: () {
              //       Navigator.push(context, MaterialPageRoute(
              //         builder: (context) {
              //           return AddDiagnosis();
              //         },
              //       ));
              //     }),
              SettingsTile(
                  image: 'padlock',
                  text: 'Change Password',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const ChangePassword();
                      },
                    ));
                  }),
              Row(
                children: [
                  Text(
                    'Enable Biometrics',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColorPurple),
                  ),
                  const Spacer(),
                  Switch.adaptive(
                      inactiveTrackColor: Colors.grey.withOpacity(.5),
                      activeColor: AppColors.primaryColorPurple,
                      value: switchValueFingerPrint,
                      onChanged: (e) async {
                        switchValueFingerPrint = !switchValueFingerPrint;
                        await HiveStorage.put(
                            HiveKeys.showBiometrics, switchValueFingerPrint);
                        setState(() {});
                      }),
                ],
              ),
              Row(
                children: [
                  Text(
                    'App Lock',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColorPurple),
                  ),
                  const Spacer(),
                  Switch.adaptive(
                      inactiveTrackColor: Colors.grey.withOpacity(.5),
                      activeColor: AppColors.primaryColorPurple,
                      value: switchValueAppLock,
                      onChanged: (e) async {
                        switchValueAppLock = !switchValueAppLock;
                        await Session.setAppLockEnabled(switchValueAppLock);
                        setState(() {});
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
