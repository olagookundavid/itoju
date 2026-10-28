import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/colors/colors.dart';
import 'package:itoju_mobile/data/reminder_schedule.dart';
import 'package:itoju_mobile/data/repositories/reminder_repository.dart';
import 'package:itoju_mobile/features/metrics/notifiers/reminders_provider.dart';
import 'package:itoju_mobile/features/metrics/pages/reminder_editor.dart';
import 'package:itoju_mobile/features/widgets/back_button.dart';
import 'package:itoju_mobile/features/widgets/custom_button.dart';
import 'package:itoju_mobile/features/widgets/custom_text.dart';
import 'package:itoju_mobile/features/widgets/utills.dart';
import 'package:itoju_mobile/services/flush_bar_service.dart';
import 'package:itoju_mobile/services/reminder_coordinator.dart';
import 'package:permission_handler/permission_handler.dart';

class MedicationRemindersPage extends ConsumerStatefulWidget {
  const MedicationRemindersPage({super.key});

  @override
  ConsumerState<MedicationRemindersPage> createState() =>
      _MedicationRemindersPageState();
}

class _MedicationRemindersPageState extends ConsumerState<MedicationRemindersPage>
    with WidgetsBindingObserver {
  bool? _allowed; // null until checked
  bool _hideNames = HiveStorage.get(HiveKeys.reminderHideNames) == true;

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

  Future<void> _setHideNames(bool v) async {
    setState(() => _hideNames = v);
    await HiveStorage.put(HiveKeys.reminderHideNames, v);
    await ref.read(reminderCoordinatorProvider).refresh();
  }

  Future<void> _toggle(MedReminderModel r, bool on) async {
    try {
      await ref.read(reminderRepositoryProvider).setEnabled(r.id!, on);
      if (on) await ref.read(reminderCoordinatorProvider).enableNotifications();
    } on ArgumentError catch (e) {
      getAlert(e.message.toString());
    }
  }

  void _open([MedReminderModel? r]) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => ReminderEditorPage(existing: r)));

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
            child: Text('Notifications are off, so reminders will not appear.',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey)),
          ),
          TextButton(onPressed: _turnOn, child: const Text('Turn on')),
        ]),
      );

  Widget _tile(MedReminderModel r) {
    final dose = [
      if (r.dosage > 0) '${r.dosage} ${r.unit}',
      if (r.quantity > 1) 'take ${r.quantity}',
    ].join(' · ');
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.alt_border_grey),
      ),
      child: ListTile(
        onTap: () => _open(r),
        contentPadding: EdgeInsets.fromLTRB(14.w, 4.h, 8.w, 4.h),
        title: Text(r.name,
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: r.enabled ? AppColors.primaryColorPurple : AppColors.hintGrey)),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            [
              if (dose.isNotEmpty) dose,
              ReminderDays.summary(r.days),
              r.times.map(prettyTime).join(', '),
            ].join('\n'),
            style: TextStyle(fontSize: 12.sp, color: AppColors.textGrey, height: 1.4),
          ),
        ),
        trailing: Switch(
          value: r.enabled,
          activeThumbColor: AppColors.primaryColorPurple,
          onChanged: (v) => _toggle(r, v),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(remindersProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const CustomBackButton(),
                8.pw,
                CustomText('Medication reminders',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColorPurple),
              ]),
              12.ph,
              if (_allowed == false) _permissionBanner(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primaryColorPurple,
                title: Text('Hide medication names',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                subtitle: Text(
                    'Notifications say "Medication reminder" so nothing about your '
                    'health shows on a locked screen.',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.hintGrey)),
                value: _hideNames,
                onChanged: _setHideNames,
              ),
              const Divider(),
              Expanded(
                child: reminders.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const Center(child: Text('Could not load reminders')),
                  data: (list) => list.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.alarm_add_outlined,
                                  size: 48.r, color: AppColors.hintGrey),
                              10.ph,
                              Text('No reminders yet',
                                  style: TextStyle(
                                      fontSize: 15.sp, fontWeight: FontWeight.w700)),
                              4.ph,
                              Text(
                                  'Pick the days and the times, and Itoju will remind you.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12.sp, color: AppColors.hintGrey)),
                            ],
                          ),
                        )
                      : ListView(children: list.map(_tile).toList()),
                ),
              ),
              Center(
                child: CurvedButton(
                  text: 'Add a reminder',
                  onPressed: _open,
                  width: 220.w,
                  height: 48.h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
