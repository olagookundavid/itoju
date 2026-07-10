import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sync_controller.dart';

/// Background sync trigger: kicks a sync whenever connectivity is (re)gained.
/// Launch and app-foreground triggers live in main.dart; together they cover the
/// common cases without a heavyweight background worker. Every trigger runs only
/// when the configured cadence is due, and is a no-op unless the user is
/// authenticated and holds the sync entitlement.
class SyncScheduler {
  SyncScheduler(this._ref);
  final Ref _ref;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  void start() {
    _sub ??= Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) {
        _ref.read(syncControllerProvider).maybePeriodicSync();
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
