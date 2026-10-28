import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/reminder_schedule.dart';
import 'package:itoju_mobile/data/repositories/reminder_repository.dart';
import 'package:itoju_mobile/services/reminder_coordinator.dart';

import '../helpers/fake_scheduler.dart';

MedReminderModel draft(String name,
        {List<String> times = const ['08:00'], bool enabled = true}) =>
    MedReminderModel(
        id: null, name: name, dosage: 500, times: times, enabled: enabled);

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 80));

void main() {
  late AppDatabase db;
  late ReminderRepository repo;
  late FakeScheduler scheduler;
  late ReminderCoordinator coordinator;
  var hideNames = false;
  var dataChanged = 0;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ReminderRepository(db);
    scheduler = FakeScheduler();
    hideNames = false;
    dataChanged = 0;
    coordinator = ReminderCoordinator(
      scheduler: scheduler,
      repository: repo,
      db: db,
      hideNames: () => hideNames,
      onDataChanged: () => dataChanged++,
      debounce: const Duration(milliseconds: 10),
      listenForBackgroundEvents: false,
    );
  });
  tearDown(() async {
    coordinator.dispose();
    await db.close();
  });

  test(
      'start initialises the scheduler once and schedules what is already saved',
      () async {
    await repo.save(draft('Metformin'));
    await coordinator.start();
    await coordinator.start(); // idempotent
    await settle();

    expect(scheduler.inits, 1);
    expect(scheduler.calls, isNotEmpty);
    expect(scheduler.calls.last.reminders.map((r) => r.name), ['Metformin']);
  });

  test('adding, editing and switching off a reminder each reschedule',
      () async {
    await coordinator.start();
    await settle();
    final before = scheduler.calls.length;

    final id = await repo.save(draft('Metformin'));
    await settle();
    expect(scheduler.calls.length, greaterThan(before));
    expect(scheduler.calls.last.reminders.map((r) => r.name), ['Metformin']);

    await repo
        .save((await repo.getById(id))!.copyWith(times: ['07:00', '19:00']));
    await settle();
    expect(scheduler.calls.last.reminders.single.times, ['07:00', '19:00']);

    await repo.setEnabled(id, false);
    await settle();
    // The scheduler is handed the reminder as disabled; it builds no slots for it.
    expect(buildSlots(scheduler.calls.last.reminders), isEmpty);

    await repo.delete(id);
    await settle();
    expect(scheduler.calls.last.reminders, isEmpty);
  });

  test('nothing is scheduled while notifications are not allowed', () async {
    scheduler.allowed = false;
    await repo.save(draft('Metformin'));
    await coordinator.start();
    await settle();

    expect(scheduler.calls, isEmpty);
    expect(scheduler.requests, 0,
        reason: 'starting up never pops a permission prompt');
  });

  test('enableNotifications asks for permission, then schedules', () async {
    scheduler.allowed = false;
    await repo.save(draft('Metformin'));
    await coordinator.start();
    await settle();

    expect(await coordinator.enableNotifications(), isTrue);
    expect(scheduler.requests, 1);
    expect(scheduler.calls.last.reminders.map((r) => r.name), ['Metformin']);
  });

  test('a refused permission schedules nothing and reports it', () async {
    scheduler.allowed = false;
    scheduler.grantOnRequest = false;
    await repo.save(draft('Metformin'));
    await coordinator.start();

    expect(await coordinator.enableNotifications(), isFalse);
    await settle();
    expect(scheduler.calls, isEmpty);
  });

  test('already-granted permission is not asked for again', () async {
    await coordinator.start();
    expect(await coordinator.enableNotifications(), isTrue);
    expect(scheduler.requests, 0);
  });

  test('the privacy setting is passed through at schedule time', () async {
    await repo.save(draft('Metformin'));
    await coordinator.start();
    await settle();
    expect(scheduler.calls.last.hideNames, isFalse);

    hideNames = true;
    await coordinator.refresh();
    expect(scheduler.calls.last.hideNames, isTrue);
  });

  test('overlapping refreshes never run at the same time', () async {
    scheduler.work = const Duration(milliseconds: 30);
    await repo.save(draft('Metformin'));
    await coordinator.start();
    await Future.wait(
        [coordinator.refresh(), coordinator.refresh(), coordinator.refresh()]);
    expect(scheduler.maxRunning, 1);
  });

  test('a failing scheduler does not break later refreshes', () async {
    await coordinator.start();
    await settle();
    scheduler.allowed = true;
    final failing = _ThrowOnce(scheduler);
    final c2 = ReminderCoordinator(
      scheduler: failing,
      repository: repo,
      db: db,
      hideNames: () => false,
      onDataChanged: () {},
      debounce: const Duration(milliseconds: 10),
      listenForBackgroundEvents: false,
    );
    addTearDown(c2.dispose);
    await c2.start();
    await settle();
    await c2.refresh();
    expect(failing.attempts, greaterThanOrEqualTo(2));
    expect(failing.succeeded, greaterThanOrEqualTo(1));
  });

  group('Mark as taken', () {
    test('logs the medication and tells the app to refresh', () async {
      final id = await repo.save(draft('Metformin'));
      await coordinator.start();

      await scheduler.onTaken!(id);

      final logged = await db.select(db.medicationMetrics).get();
      expect(logged.map((m) => m.name), ['Metformin']);
      expect(dataChanged, 1);
    });

    test('a reminder deleted since is ignored', () async {
      final id = await repo.save(draft('Metformin'));
      await repo.delete(id);
      await coordinator.start();

      await scheduler.onTaken!(id);

      expect(await db.select(db.medicationMetrics).get(), isEmpty);
      expect(dataChanged, 0);
    });
  });
}

class _ThrowOnce extends FakeScheduler {
  _ThrowOnce(FakeScheduler base) {
    allowed = base.allowed;
  }
  int attempts = 0, succeeded = 0;

  @override
  Future<void> reschedule(List<MedReminderModel> reminders,
      {required bool hideNames}) async {
    attempts++;
    if (attempts == 1) throw StateError('plugin hiccup');
    succeeded++;
  }
}
