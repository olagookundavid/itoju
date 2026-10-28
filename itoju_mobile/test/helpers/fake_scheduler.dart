import 'package:itoju_mobile/data/reminder_schedule.dart';
import 'package:itoju_mobile/services/reminder_scheduler.dart';

/// A stand-in for the notifications plugin: records what would have been
/// scheduled and lets a test decide whether permission is granted.
class FakeScheduler implements ReminderScheduler {
  bool allowed = true;
  bool grantOnRequest = true;
  int inits = 0, requests = 0, running = 0, maxRunning = 0;
  Duration work = Duration.zero;
  final List<({List<MedReminderModel> reminders, bool hideNames})> calls = [];

  @override
  Future<void> Function(String reminderId)? onTaken;

  @override
  Future<void> init() async {
    // Like the real scheduler, initialising twice is a no-op.
    if (inits == 0) inits++;
  }
  @override
  Future<bool> notificationsAllowed() async => allowed;
  @override
  Future<bool> requestPermission() async {
    requests++;
    if (grantOnRequest) allowed = true;
    return grantOnRequest;
  }

  @override
  Future<void> reschedule(List<MedReminderModel> reminders,
      {required bool hideNames}) async {
    running++;
    if (running > maxRunning) maxRunning = running;
    await Future<void>.delayed(work);
    calls.add((reminders: reminders, hideNames: hideNames));
    running--;
  }
}
