import 'dart:ui' show DartPluginRegistrant, IsolateNameServer;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/db/app_database.dart';
import '../data/reminder_actions.dart';
import '../data/reminder_schedule.dart';

const String kReminderChannelId = 'med_reminders';
const String kReminderCategory = 'medReminder';
const String kActionTaken = 'taken';

/// Name the main isolate registers so a notification's background isolate can tell
/// it that "Mark as taken" wrote to the database.
const String kReminderPortName = 'itoju_reminder_events';

/// The part of local notifications the rest of the app depends on. The real
/// implementation wraps flutter_local_notifications; tests substitute a fake.
abstract class ReminderScheduler {
  /// Called with the reminder id when "Mark as taken" is pressed while the app's
  /// own isolate handles the response.
  Future<void> Function(String reminderId)? onTaken;

  Future<void> init();
  Future<bool> notificationsAllowed();

  /// Shows the system permission prompt (Android 13+, iOS). True if granted.
  Future<bool> requestPermission();

  /// Replaces every scheduled reminder notification with the ones for
  /// [reminders]. Idempotent: calling it again with the same data changes nothing.
  Future<void> reschedule(List<MedReminderModel> reminders, {required bool hideNames});
}

class LocalReminderScheduler implements ReminderScheduler {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  @override
  Future<void> Function(String reminderId)? onTaken;

  @override
  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _applyDeviceTimezone();
    await _plugin.initialize(
      InitializationSettings(
        android: const AndroidInitializationSettings('ic_stat_reminder'),
        iOS: DarwinInitializationSettings(
          // Permission is asked for explicitly, when the person sets up a reminder.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          notificationCategories: [
            DarwinNotificationCategory(
              kReminderCategory,
              actions: [DarwinNotificationAction.plain(kActionTaken, 'Mark as taken')],
            ),
          ],
        ),
      ),
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse: reminderBackgroundResponse,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          kReminderChannelId,
          'Medication reminders',
          description: 'Reminders to take your medication',
          importance: Importance.high,
        ));
    _ready = true;
  }

  /// Points tz.local at the device's zone. Re-run before each reschedule so a
  /// person who travels (or whose clock rules change) isn't left on the zone the
  /// app happened to start in.
  Future<void> _applyDeviceTimezone() async {
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      if (tz.local.name != name) tz.setLocalLocation(tz.getLocation(name));
    } catch (e) {
      // Without the device timezone, reminders would fire at the wrong hour.
      // Keep the last known zone and log; this is rare (unknown/legacy zone id).
      debugPrint('Reminders: could not read the device timezone ($e)');
    }
  }

  void _onResponse(NotificationResponse r) {
    // A plain tap just opens the app (through the normal app-lock flow): never
    // navigate from here, or a tap could bypass the lock screen.
    final id = reminderIdFromPayload(r.payload);
    if (r.actionId == kActionTaken && id != null) onTaken?.call(id);
  }

  @override
  Future<bool> notificationsAllowed() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.areNotificationsEnabled() ?? false;
    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) return (await ios.checkPermissions())?.isEnabled ?? false;
    return false;
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) return await android.requestNotificationsPermission() ?? false;
    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: false, sound: true) ?? false;
    }
    return false;
  }

  @override
  Future<void> reschedule(List<MedReminderModel> reminders, {required bool hideNames}) async {
    await _applyDeviceTimezone();
    final zone = tz.local.name;
    final byId = {
      for (final r in reminders)
        if (r.id != null) r.id!: r
    };
    final slots = buildSlots(reminders);
    final ids = notificationIds(slots);
    final desired = [
      for (final slot in slots)
        () {
          final text = reminderTexts(byId[slot.reminderId]!, hideNames: hideNames);
          return (
            slot: slot,
            note: ScheduledNote(ids[slot]!, text.title, text.body, slotPayload(slot, zone)),
          );
        }()
    ];
    final pending = (await _plugin.pendingNotificationRequests())
        .map((p) => ScheduledNote(p.id, p.title, p.body, p.payload))
        .toList();

    // Touch only what changed: cancelling an id also clears that notification
    // from the tray, so a blanket cancel on every launch would wipe reminders the
    // person hasn't acted on yet.
    final plan = planReschedule([for (final d in desired) d.note], pending);
    for (final id in plan.cancel) {
      await _plugin.cancel(id);
    }
    final now = tz.TZDateTime.now(tz.local);
    final changed = {for (final n in plan.schedule) n.id};
    for (final d in desired) {
      if (!changed.contains(d.note.id)) continue;
      await _plugin.zonedSchedule(
        d.note.id,
        d.note.title,
        d.note.body,
        nextWeekly(now, d.slot.weekday, d.slot.hour, d.slot.minute),
        _details,
        payload: d.note.payload,
        // Inexact: a reminder may arrive a few minutes late in Doze, but the app
        // then needs no exact-alarm permission (which Google Play restricts).
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      kReminderChannelId,
      'Medication reminders',
      channelDescription: 'Reminders to take your medication',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      // Hide the content when the phone is locked and the person has chosen
      // to keep sensitive notification content private.
      visibility: NotificationVisibility.private,
      actions: [
        AndroidNotificationAction(kActionTaken, 'Mark as taken',
            cancelNotification: true, showsUserInterface: false),
      ],
    ),
    iOS: DarwinNotificationDetails(categoryIdentifier: kReminderCategory),
  );
}

/// Runs in a separate background isolate (the app may not be running at all) when
/// "Mark as taken" is pressed on Android, so it can only use what an isolate with
/// no Riverpod container has: it opens the database itself, writes, and pings the
/// main isolate if there is one.
@pragma('vm:entry-point')
Future<void> reminderBackgroundResponse(NotificationResponse r) async {
  final id = reminderIdFromPayload(r.payload);
  if (r.actionId != kActionTaken || id == null) return;
  DartPluginRegistrant.ensureInitialized();
  final db = AppDatabase();
  try {
    await ReminderActions.markTaken(db, id);
  } finally {
    await db.close();
  }
  IsolateNameServer.lookupPortByName(kReminderPortName)?.send(id);
}
