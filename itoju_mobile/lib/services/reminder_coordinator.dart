import 'dart:async';
import 'dart:isolate';
import 'dart:ui' show IsolateNameServer;

import 'package:drift/drift.dart' show TableUpdate;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/Storage/storage_class.dart';
import '../data/db/app_database.dart';
import '../data/reminder_actions.dart';
import '../data/repositories/reminder_repository.dart';
import '../data/providers.dart';
import '../features/home/notifer/metrics_status_notifier.dart';
import '../features/settings/notifier/points_notifier.dart';
import 'reminder_scheduler.dart';

final reminderSchedulerProvider =
    Provider<ReminderScheduler>((ref) => LocalReminderScheduler());

final reminderCoordinatorProvider = Provider<ReminderCoordinator>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final c = ReminderCoordinator(
    scheduler: ref.watch(reminderSchedulerProvider),
    repository: ref.watch(reminderRepositoryProvider),
    db: db,
    hideNames: () => HiveStorage.get(HiveKeys.reminderHideNames) == true,
    onDataChanged: () {
      // Something wrote medication rows / points outside the UI (a notification
      // action): tell live queries and refresh what is derived from them.
      db.notifyUpdates({
        TableUpdate.onTable(db.medicationMetrics),
        TableUpdate.onTable(db.pointRecords),
      });
      ref.invalidate(metricsStatusProvider);
      ref.invalidate(pointProvider);
    },
  );
  ref.onDispose(c.dispose);
  return c;
});

/// Keeps the phone's scheduled notifications equal to the reminders in the
/// database, however those rows changed (edited here, restored by a sync, …),
/// and handles "Mark as taken".
class ReminderCoordinator {
  ReminderCoordinator({
    required this.scheduler,
    required this.repository,
    required this.db,
    required this.hideNames,
    required this.onDataChanged,
    this.debounce = const Duration(milliseconds: 400),
    this.listenForBackgroundEvents = true,
  });

  final ReminderScheduler scheduler;
  final ReminderRepository repository;
  final AppDatabase db;
  final bool Function() hideNames;
  final void Function() onDataChanged;
  final Duration debounce;
  final bool listenForBackgroundEvents;

  StreamSubscription<Object?>? _sub;
  ReceivePort? _port;
  Timer? _timer;
  Future<void> _queue = Future.value();
  bool _started = false;

  /// Idempotent. Safe to call on every launch.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    await scheduler.init();
    scheduler.onTaken = _handleTaken;
    if (listenForBackgroundEvents) {
      IsolateNameServer.removePortNameMapping(kReminderPortName);
      _port = ReceivePort()..listen((_) => onDataChanged());
      IsolateNameServer.registerPortWithName(_port!.sendPort, kReminderPortName);
    }
    // Emits once immediately (the initial schedule) and again on every change.
    _sub = repository.watchAll().listen((_) => _scheduleSoon());
  }

  void _scheduleSoon() {
    _timer?.cancel();
    _timer = Timer(debounce, refresh);
  }

  /// Rebuilds the scheduled notifications now. Serialised so two overlapping
  /// calls can't interleave their cancel/schedule steps.
  Future<void> refresh() {
    _queue = _queue.then((_) => _doRefresh()).catchError((Object _) {});
    return _queue;
  }

  Future<void> _doRefresh() async {
    await scheduler.init(); // idempotent; refresh() may run before start() finishes
    final reminders = await repository.getAll();
    // Scheduling without permission queues notifications the OS then discards;
    // wait until it is granted (enableNotifications / the next refresh).
    if (!await scheduler.notificationsAllowed()) return;
    await scheduler.reschedule(reminders, hideNames: hideNames());
  }

  /// Asks for notification permission if needed, then schedules. True if allowed.
  Future<bool> enableNotifications() async {
    await scheduler.init();
    var ok = await scheduler.notificationsAllowed();
    if (!ok) ok = await scheduler.requestPermission();
    if (ok) await refresh();
    return ok;
  }

  Future<bool> get notificationsAllowed async {
    await scheduler.init();
    return scheduler.notificationsAllowed();
  }

  Future<void> _handleTaken(String reminderId) async {
    if (await ReminderActions.markTaken(db, reminderId)) onDataChanged();
  }

  void dispose() {
    _timer?.cancel();
    _sub?.cancel();
    if (_port != null) {
      IsolateNameServer.removePortNameMapping(kReminderPortName);
      _port!.close();
    }
  }
}
