import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';

import '../core/Storage/storage_class.dart';
import '../data/db/app_database.dart';
import '../data/providers.dart';
import '../data/repositories/tracking_activity.dart';
import '../data/streak_messages.dart';

final streakCelebratorProvider = Provider<StreakCelebrator>((ref) {
  final c = StreakCelebrator(
    db: ref.watch(appDatabaseProvider),
    show: showStreakToast,
    celebratedOn: () => HiveStorage.get(HiveKeys.streakCelebratedOn) as String?,
    markCelebrated: (day) => HiveStorage.put(HiveKeys.streakCelebratedOn, day),
    isForeground: () =>
        SchedulerBinding.instance.lifecycleState == AppLifecycleState.resumed,
  );
  ref.onDispose(c.dispose);
  return c;
});

/// The in-app toast (not a system notification): shown over whatever screen is
/// open.
void showStreakToast(String title, String body) {
  toastification.show(
    type: ToastificationType.success,
    style: ToastificationStyle.fillColored,
    autoCloseDuration: const Duration(seconds: 4),
    title: Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
    description: Text(body, style: TextStyle(fontSize: 14.sp)),
    icon: const Icon(Icons.local_fire_department_rounded),
    alignment: Alignment.topCenter,
    direction: TextDirection.ltr,
  );
}

/// Congratulates the person on their streak the first time they log something
/// on a day: "3-day streak, keep it going". At most once a day, only while the
/// app is open, and never at launch for something logged earlier.
class StreakCelebrator {
  StreakCelebrator({
    required this.db,
    required this.show,
    required this.celebratedOn,
    required this.markCelebrated,
    this.isForeground = _always,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final void Function(String title, String body) show;

  /// The last day (yyyy-MM-dd) a streak message was shown, and how to record one.
  final String? Function() celebratedOn;
  final void Function(String day) markCelebrated;
  final bool Function() isForeground;
  final DateTime Function() _now;

  static bool _always() => true;

  StreamSubscription<Object?>? _sub;
  Future<void> _queue = Future.value();
  String? _day; // the day _tracked refers to
  bool _tracked = false; // whether that day already had something logged
  bool _started = false;

  static String _iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Idempotent. Takes a baseline (so what was logged before launch isn't
  /// celebrated) and then watches every tracker.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    final today = _now();
    _day = _iso(today);
    _tracked = await TrackingActivity(db).trackedOn(today);
    _sub = db
        .tableUpdates(TableUpdateQuery.onAllTables([
          db.symptomMetrics,
          db.foodMetrics,
          db.sleepMetrics,
          db.medicationMetrics,
          db.exerciseMetrics,
          db.urineMetrics,
          db.bowelMetrics,
          db.bpMetrics,
          db.cycleDays,
          db.smileyEntries,
        ]))
        .listen((_) => check());
  }

  /// Looks at what is logged now. Serialised, so overlapping changes can't show
  /// two toasts. Call on resume: something logged while the app was in the
  /// background (e.g. "Mark as taken") is celebrated when they come back.
  Future<void> check() {
    _queue = _queue.then((_) => _check()).catchError((Object _) {});
    return _queue;
  }

  Future<void> _check() async {
    if (!_started || !isForeground()) return; // nobody would see it
    final today = _now();
    final day = _iso(today);
    if (day != _day) {
      // Midnight passed while the app stayed open: a fresh day, nothing logged.
      _day = day;
      _tracked = false;
    }
    final activity = TrackingActivity(db);
    final tracked = await activity.trackedOn(today);
    if (!tracked) {
      _tracked = false; // an entry was deleted
      return;
    }
    if (_tracked) return; // already knew about today's logging
    _tracked = true;
    if (celebratedOn() == day) return; // already congratulated today
    markCelebrated(day);
    final message = streakMessage(await activity.streak(today));
    if (message != null) show(message.title, message.body);
  }

  void dispose() => _sub?.cancel();
}
