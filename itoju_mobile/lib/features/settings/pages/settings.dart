import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/auth/session.dart';
import 'package:itoju_mobile/features/auth/notifiers/login_notifier.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';
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
import 'package:itoju_mobile/features/metrics/pages/medication_reminders.dart';
import 'package:itoju_mobile/features/settings/pages/set_body_data.dart';
import 'package:itoju_mobile/features/settings/pages/set_menses.dart';
import 'package:itoju_mobile/features/settings/widgets/settings_tile.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/core/auth/provider_reset.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool switchValueAuth = false;
  bool switchValueAppLock = Session.isAppLockEnabled();
  bool switchValueBiometrics = Session.isBiometricLoginEnabled();
  bool _loggedIn = false;
  bool _backingUp = false;

  @override
  void initState() {
    super.initState();
    Session.hasToken().then((v) {
      if (mounted) setState(() => _loggedIn = v);
    });
  }

  /// Turning biometric sign-in ON: needs a device biometric, the account's email,
  /// and the user's password — which is VERIFIED against the server before
  /// anything is kept. The password is stored (in the platform keystore) only
  /// from this point, and only while the toggle stays on.
  Future<void> _enableBiometrics() async {
    if (!await LocalAuthApi.hasBiometrics()) {
      getAlert('Set up a fingerprint or face on this device first');
      return;
    }
    final email = HiveStorage.get(HiveKeys.userName) as String?;
    if (email == null || email.isEmpty) {
      getAlert(
          'Biometric sign-in is for email accounts. Sign in with your email and password first.');
      return;
    }
    final check = await LocalAuthApi.authenticate();
    if (check != 'success') {
      getAlert(check);
      return;
    }
    if (!mounted) return;
    final password = await _askPassword(email);
    if (password == null || password.isEmpty) return;

    // Flag first, so the verifying login below saves the password.
    await Session.setBiometricLoginEnabled(true);
    final res =
        await ref.read(loginNotifier.notifier).login(email, password);
    if (res.successMessage.isNotEmpty) {
      if (mounted) setState(() => switchValueBiometrics = true);
      getAlert('Biometric sign-in is on', isWarning: false);
    } else {
      await Session.setBiometricLoginEnabled(false);
      getAlert(res.responseMessage?.isNotEmpty == true
          ? res.responseMessage!
          : res.errorMessage);
    }
  }

  Future<String?> _askPassword(String email) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm your password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 12),
            const Text(
              'It is kept in your device\'s secure storage, and only while '
              'this is switched on.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, ctrl.text),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return result;
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

    // Logged out: nothing from this account may linger in memory.
    resetUserScopedProviders(ref.invalidate);

    if (mounted) setState(() => _loggedIn = false);
    if (!context.mounted) return;

    // Back to the app root (the app stays fully usable anonymously). Root
    // navigator avoids a blank nested page; LandingPage — not AuthGate — so the
    // user isn't asked to unlock again right after logging out.
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
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
                  image: 'drug',
                  text: 'Medication Reminders',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const MedicationRemindersPage();
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
              if (_loggedIn || switchValueBiometrics)
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
                        value: switchValueBiometrics,
                        onChanged: (on) async {
                          if (on) {
                            await _enableBiometrics();
                          } else {
                            await Session.setBiometricLoginEnabled(false);
                            setState(() => switchValueBiometrics = false);
                          }
                        }),
                  ],
                ),
              if (_loggedIn || switchValueBiometrics)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Text(
                    'Sign in with your fingerprint or face. While this is on, '
                    'your password is kept in this device\'s secure storage.',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
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
              SizedBox(height: 60.h),
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
    SyncOutcome outcome;
    try {
      outcome = await ref.read(syncControllerProvider).backupNow();
    } finally {
      if (mounted) setState(() => _backingUp = false);
    }
    if (!mounted) return;
    final message = switch (outcome) {
      SyncOutcome.synced => 'Backed up',
      SyncOutcome.notSignedIn => 'Sign in to back up your data to the cloud',
      SyncOutcome.accountSwitchPending =>
        'A different account is signed in on this device. Resolve that before '
            'backing up.',
      SyncOutcome.offlineOrServerError =>
        "Couldn't reach the server — check your connection and try again",
      SyncOutcome.busy => 'A backup is already in progress',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                    style:
                        TextStyle(color: canDelete ? Colors.red : Colors.grey),
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
