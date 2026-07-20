import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/auth/session.dart';
import 'package:itoju_mobile/core/helpers/app_reset.dart';
import 'package:itoju_mobile/core/helpers/biometric_helper.dart';
import 'package:itoju_mobile/features/auth/pages/login.dart';
import 'package:itoju_mobile/services/dio_provider.dart';
import 'package:itoju_mobile/sync/sync_controller.dart';
import 'package:itoju_mobile/sync/sync_schedule.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/features/auth/pages/add_conditions.dart';
import 'package:itoju_mobile/features/auth/pages/add_tracked_metrics.dart';
import 'package:itoju_mobile/features/auth/pages/change_password.dart';
import 'package:itoju_mobile/features/landing/landing_page.dart';
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
  bool _loggedIn = false;
  bool _backingUp = false;

  @override
  void initState() {
    super.initState();
    Session.hasToken().then((v) {
      if (mounted) setState(() => _loggedIn = v);
    });
  }

  Future<void> _logout(BuildContext context) async {
    // Logging out only ends the cloud session — the local-first data stays.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Log out? Your data stays on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    // Revoke the token server-side first (best-effort), then tear down the
    // local session and provider sessions.
    try {
      await ref.read(dioProvider).post('logout');
    } catch (_) {
      // Offline or already-invalid token — local teardown below still applies.
    }
    await Session.clearLocal();
    await Session.signOutProviders();
    if (mounted) setState(() => _loggedIn = false);
    if (!context.mounted) return;
    // Back to the app root — the app stays fully usable anonymously.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LandingPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const CustomBackButton(), actions: [
        if (_loggedIn)
          InkWell(
            onTap: () => _logout(context),
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                border: Border.all(
                    width: .5.w, color: AppColors.primaryColorPurple),
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
              if (_loggedIn)
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
              SizedBox(height: 20.h),
              _cloudSyncSection(),
              SizedBox(height: 28.h),
              _dangerZoneSection(),
              // Trailing breathing room so the last tile's subtitle isn't
              // flush against the bottom of the scroll content.
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  // --- Cloud Sync ------------------------------------------------------------

  Widget _sectionLabel(String text) => Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColorPurple),
        ),
      );

  Widget _cloudSyncSection() {
    if (!_loggedIn) {
      // Local-first: sync is optional and only matters once there's an account.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Cloud Sync'),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignInPage()),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Sign in to back up & sync your data',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textGrey),
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.primaryColorPurple),
              ],
            ),
          ),
        ],
      );
    }

    final controller = ref.read(syncControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Cloud Sync'),
        Row(
          children: [
            Text(
              'Automatic sync',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColorPurple),
            ),
            const Spacer(),
            DropdownButton<String>(
              value: controller.cadence,
              underline: const SizedBox.shrink(),
              items: SyncSchedule.all
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(_cadenceLabel(c)),
                      ))
                  .toList(),
              onChanged: (value) async {
                if (value == null) return;
                await controller.setCadence(value);
                if (mounted) setState(() {});
              },
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Text(
                'Last backup: ${_lastSyncedLabel(controller.lastSyncAt)}',
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textGrey),
              ),
            ),
            _backingUp
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : TextButton(
                    onPressed: _backupNow,
                    child: Text(
                      'Back up now',
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColorPurple),
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  String _cadenceLabel(String c) {
    switch (c) {
      case SyncSchedule.off:
        return 'Off';
      case SyncSchedule.daily:
        return 'Daily';
      case SyncSchedule.weekly:
        return 'Weekly';
      case SyncSchedule.monthly:
        return 'Monthly';
      default:
        return c;
    }
  }

  String _lastSyncedLabel(DateTime? dt) {
    if (dt == null) return 'never';
    final local = dt.toLocal();
    final d = '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
    final t = '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
    return '$d $t';
  }

  Future<void> _backupNow() async {
    setState(() => _backingUp = true);
    bool did = false;
    try {
      did = await ref.read(syncControllerProvider).backupNow();
    } finally {
      if (mounted) setState(() => _backingUp = false);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(did
            ? 'Backed up'
            : "Couldn't back up — make sure you're signed in and online"),
      ),
    );
  }

  // --- Danger zone -----------------------------------------------------------

  Widget _dangerZoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text(
            'Danger zone',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red),
          ),
        ),
        _dangerTile(
          icon: Icons.delete_forever_outlined,
          title: 'Erase all data',
          subtitle:
              'Wipe everything on this device and reset the app. Cloud backups are kept.',
          onTap: _eraseData,
        ),
        if (_loggedIn) ...[
          SizedBox(height: 8.h),
          _dangerTile(
            icon: Icons.person_remove_outlined,
            title: 'Delete account',
            subtitle:
                'Permanently delete your account and all backed-up data everywhere.',
            onTap: _deleteAccount,
          ),
        ],
      ],
    );
  }

  Widget _dangerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, color: Colors.red, size: 22.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Erase all local data on this device and reset the app. Gated by the device
  /// unlock (biometric → passcode fallback), then a red confirmation.
  Future<void> _eraseData() async {
    final unlocked = await LocalAuthApi.unlockApp();
    if (!unlocked || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Erase all data?'),
        content: const Text(
          'Erases all health data, sign-ins and settings on this device and '
          'resets the app. Cloud backups are NOT deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Erase', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await resetToFactory(ref, context);
  }

  /// Permanently delete the server account (and all backed-up data) then reset
  /// the device. Gated by unlock and a type-to-confirm dialog. If the server
  /// call fails, NOTHING local is changed.
  Future<void> _deleteAccount() async {
    final unlocked = await LocalAuthApi.unlockApp();
    if (!unlocked || !mounted) return;
    final confirmed = await _showDeleteAccountDialog();
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(dioProvider).delete('users/me');
    } catch (_) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text("Couldn't delete account"),
          content: const Text(
            'We could not reach the server. Nothing was changed. Please check '
            'your connection and try again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    if (!mounted) return;
    await resetToFactory(ref, context);
  }

  /// Type-to-confirm dialog: the destructive button only enables once the user
  /// types exactly `DELETE`.
  Future<bool?> _showDeleteAccountDialog() {
    final controller = TextEditingController();
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final canDelete = controller.text.trim() == 'DELETE';
            return AlertDialog(
              title: const Text('Delete account?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Permanently deletes your account and ALL backed-up data '
                    'for every device. This cannot be undone.',
                  ),
                  SizedBox(height: 16.h),
                  const Text('Type DELETE to confirm.'),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'DELETE',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: canDelete
                      ? () => Navigator.pop(dialogContext, true)
                      : null,
                  child: Text(
                    'Delete',
                    style: TextStyle(
                        color: canDelete ? Colors.red : Colors.grey),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
