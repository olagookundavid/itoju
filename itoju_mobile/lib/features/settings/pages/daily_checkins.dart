import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/data/daily_nudges.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';
import 'package:itoju_mobile/services/reminder_coordinator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Settings for the daily check-ins: a good-morning note, and an evening nudge
/// that only comes on days nothing has been logged.
class DailyCheckinsPage extends ConsumerStatefulWidget {
  const DailyCheckinsPage({super.key});

  @override
  ConsumerState<DailyCheckinsPage> createState() => _DailyCheckinsPageState();
}

class _DailyCheckinsPageState extends ConsumerState<DailyCheckinsPage>
    with WidgetsBindingObserver {
  late NudgePrefs _prefs = nudgePrefsFromStorage();
  bool? _allowed; // null until checked

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Coming back from the phone's settings: re-check, and schedule if now allowed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission().then((_) => ref.read(reminderCoordinatorProvider).refresh());
    }
  }

  Future<void> _checkPermission() async {
    final ok = await ref.read(reminderCoordinatorProvider).notificationsAllowed;
    if (mounted) setState(() => _allowed = ok);
  }

  Future<void> _turnOn() async {
    final ok = await ref.read(reminderCoordinatorProvider).enableNotifications();
    if (!mounted) return;
    setState(() => _allowed = ok);
    if (!ok) {
      // The system only asks once; after a refusal the person has to use Settings.
      getAlert('Notifications are blocked. Opening your phone settings so you can allow them.');
      try {
        await openAppSettings();
      } catch (_) {
        // No settings screen to open (unsupported platform): the message above stands.
      }
    }
  }

  /// Saves the choice, then rebuilds the schedule so it applies straight away.
  Future<void> _save(NudgePrefs next) async {
    final turnedOn = (next.morningOn && !_prefs.morningOn) ||
        (next.eveningOn && !_prefs.eveningOn);
    setState(() => _prefs = next);
    await HiveStorage.put(HiveKeys.nudgeMorningOn, next.morningOn);
    await HiveStorage.put(HiveKeys.nudgeMorningMinutes, next.morningMinutes);
    await HiveStorage.put(HiveKeys.nudgeEveningOn, next.eveningOn);
    await HiveStorage.put(HiveKeys.nudgeEveningMinutes, next.eveningMinutes);
    final coordinator = ref.read(reminderCoordinatorProvider);
    // Switching a check-in on is the moment to ask for permission if needed;
    // switching one off, or changing a time, never pops a prompt.
    if (turnedOn) {
      await coordinator.enableNotifications();
      await _checkPermission();
    } else {
      await coordinator.refresh();
    }
  }

  Future<void> _pickTime(int current, void Function(int minutes) apply) async {
    final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60));
    if (picked != null) apply(picked.hour * 60 + picked.minute);
  }

  Widget _permissionBanner() => Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xffFFF1F0),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(children: [
          const Icon(Icons.notifications_off_outlined, color: Color(0xffD72727)),
          10.pw,
          Expanded(
            child: Text('Notifications are off, so check-ins will not appear.',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey)),
          ),
          TextButton(onPressed: _turnOn, child: const Text('Turn on')),
        ]),
      );

  Widget _card({
    required String title,
    required String subtitle,
    required bool on,
    required ValueChanged<bool> onToggle,
    required int minutes,
    required ValueChanged<int> onTime,
    required Key timeKey,
    required Key switchKey,
  }) =>
      Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.alt_border_grey),
        ),
        child: Column(children: [
          SwitchListTile(
            key: switchKey,
            contentPadding: EdgeInsets.fromLTRB(14.w, 4.h, 8.w, 0),
            activeThumbColor: AppColors.primaryColorPurple,
            title: Text(title,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: on ? AppColors.primaryColorPurple : AppColors.hintGrey)),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(subtitle,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey, height: 1.4)),
            ),
            value: on,
            onChanged: onToggle,
          ),
          if (on)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 8.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: timeKey,
                  onPressed: () => _pickTime(minutes, onTime),
                  icon: const Icon(Icons.schedule, size: 18),
                  label: Text('At ${nudgeTimeLabel(minutes)}'),
                ),
              ),
            ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const CustomBackButton(),
                  8.pw,
                  CustomText('Daily check-ins',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColorPurple),
                ]),
                12.ph,
                if (_allowed == false) _permissionBanner(),
                _card(
                  title: 'Good morning note',
                  subtitle: 'A friendly hello to start your day, with a reminder to track.',
                  on: _prefs.morningOn,
                  onToggle: (v) => _save(_prefs.copyWith(morningOn: v)),
                  minutes: _prefs.morningMinutes,
                  onTime: (m) => _save(_prefs.copyWith(morningMinutes: m)),
                  timeKey: const Key('morningTime'),
                  switchKey: const Key('morningSwitch'),
                ),
                _card(
                  title: 'Evening nudge',
                  subtitle: 'Only on days you have not logged anything. Log something '
                      'and tonight\'s nudge is cancelled.',
                  on: _prefs.eveningOn,
                  onToggle: (v) => _save(_prefs.copyWith(eveningOn: v)),
                  minutes: _prefs.eveningMinutes,
                  onTime: (m) => _save(_prefs.copyWith(eveningMinutes: m)),
                  timeKey: const Key('eveningTime'),
                  switchKey: const Key('eveningSwitch'),
                ),
                Text(
                    'These notes never mention your health details, so they are safe '
                    'on a locked screen. Medication reminders are separate.',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.hintGrey, height: 1.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
