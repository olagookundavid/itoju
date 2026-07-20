import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'online_tasks.dart';

/// Background online-tasks trigger: runs the [onlineTasks] registry (health
/// sync, resources refresh, …) whenever connectivity is (re)gained. Launch
/// and app-foreground triggers live in main.dart; together they cover the
/// common cases without a heavyweight background worker. Each task in the
/// registry applies its own gating (e.g. health sync only runs when the
/// configured cadence is due and the user is authenticated/entitled).
class SyncScheduler {
  SyncScheduler(this._ref);
  final Ref _ref;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  void start() {
    _sub ??= Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) {
        runOnlineTasks(_ref.read);
      }
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }
}

final syncSchedulerProvider = Provider<SyncScheduler>((ref) {
  final scheduler = SyncScheduler(ref);
  ref.onDispose(scheduler.stop);
  return scheduler;
});
