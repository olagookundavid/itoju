import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/profile/notifiers/resources_notifiers.dart';
import 'package:itoju_mobile/sync/sync_controller.dart';

/// A provider-read function — matches both `Ref.read` and `WidgetRef.read`,
/// so callers can pass either without the registry caring which one is
/// driving it (main.dart uses a `WidgetRef`, sync_scheduler.dart a `Ref`).
typedef Reader = T Function<T>(ProviderListenable<T> provider);

typedef OnlineTask = Future<void> Function(Reader read);

/// Independent tasks to run whenever the app is confirmed online — launch,
/// resume from background, and connectivity regained (see main.dart and
/// sync_scheduler.dart). Add a new online-only refresh/download here rather
/// than wiring a new trigger for it. Each task is isolated: one failing
/// (offline mid-run, server error) never blocks the others.
final List<OnlineTask> onlineTasks = [
  // Health-data sync — gated internally by auth + entitlement + cadence.
  (read) => read(syncControllerProvider).maybePeriodicSync(),
  // Resources — free public content, no gate; cache-first, so this is a
  // cheap, idempotent background refresh safe to run on every trigger.
  (read) => read(resourcesProvider.notifier).getResources(),
];

Future<void> runOnlineTasks(Reader read) async {
  for (final task in onlineTasks) {
    try {
      await task(read);
    } catch (_) {
      // Isolated per-task — see doc comment above.
    }
  }
}
