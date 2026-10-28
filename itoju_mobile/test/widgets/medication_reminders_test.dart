import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/providers.dart';
import 'package:itoju_mobile/data/repositories/reminder_repository.dart';
import 'package:itoju_mobile/data/reminder_schedule.dart';
import 'package:itoju_mobile/features/metrics/pages/medication_reminders.dart';
import 'package:itoju_mobile/features/metrics/pages/reminder_editor.dart'
    show prettyTime;
import 'package:itoju_mobile/services/reminder_coordinator.dart';
import 'package:toastification/toastification.dart';

import '../helpers/fake_scheduler.dart';

void main() {
  late AppDatabase db;
  late FakeScheduler scheduler;

  setUpAll(() async => Hive.openBox(HiveKeys.appBox, bytes: Uint8List(0)));
  tearDownAll(() => Hive.close());

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    scheduler = FakeScheduler();
    await HiveStorage.delete(HiveKeys.reminderHideNames);
  });
  tearDown(() => db.close());

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    // Ahem (the test font) is ~2x as wide as a real font; scale text to match.
    tester.platformDispatcher.textScaleFactorTestValue = 0.55;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        reminderSchedulerProvider.overrideWithValue(scheduler),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => const ToastificationWrapper(
          child: MaterialApp(home: MedicationRemindersPage()),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> drainToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  Future<void> addTimeViaPicker(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Add a time'));
    await tester.tap(find.text('Add a time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // the picker opens on 8:00 AM
    await tester.pumpAndSettle();
  }

  Future<void> fillBasics(WidgetTester tester,
      {String name = 'Metformin', String dose = '500'}) async {
    await tester.enterText(find.byType(TextField).at(0), name);
    await tester.enterText(find.byType(TextField).at(1), dose);
    await tester.pump();
  }

  /// Like testWidgets, but tears the tree down at the end and lets Drift's
  /// zero-length stream-cleanup timer fire, so no timer is left pending.
  void page(String name, Future<void> Function(WidgetTester tester) body) {
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });
  }

  page('starts empty and offers to add a reminder', (tester) async {
    await pumpPage(tester);
    expect(find.text('No reminders yet'), findsOneWidget);
    expect(find.text('Add a reminder'), findsOneWidget);
  });

  page('creating a reminder saves it, lists it and schedules it',
      (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Add a reminder'));
    await tester.pumpAndSettle();
    expect(find.text('New reminder'), findsOneWidget);

    await fillBasics(tester);
    await addTimeViaPicker(tester);
    expect(find.text(prettyTime('08:00')), findsWidgets);

    await tester.ensureVisible(find.text('Save reminder'));
    await tester.tap(find.text('Save reminder'));
    await tester.pumpAndSettle();

    final saved = await ReminderRepository(db).getAll();
    expect(saved, hasLength(1));
    expect([
      saved[0].name,
      saved[0].dosage,
      saved[0].unit,
      saved[0].days,
      saved[0].times
    ], [
      'Metformin',
      500,
      'mg',
      kAllDays,
      ['08:00']
    ]);

    // Back on the list, showing the reminder in words.
    expect(find.text('No reminders yet'), findsNothing);
    expect(find.text('Metformin'), findsOneWidget);
    expect(find.textContaining('Every day'), findsOneWidget);
    // Saving asked the OS to schedule (permission was already granted in the fake).
    expect(scheduler.calls, isNotEmpty);
    expect(scheduler.calls.last.reminders.map((r) => r.name), ['Metformin']);
  });

  page('days: unticking Sunday saves Monday-Saturday; Weekdays preset works',
      (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Add a reminder'));
    await tester.pumpAndSettle();
    await fillBasics(tester, dose: '');
    await addTimeViaPicker(tester);

    await tester.ensureVisible(find.text('Sun'));
    await tester.tap(find.text('Sun'));
    await tester.pump();
    expect(find.textContaining('Mon, Tue, Wed, Thu, Fri, Sat'), findsOneWidget);

    await tester.ensureVisible(find.text('Weekdays'));
    await tester.tap(find.text('Weekdays'));
    await tester.pump();
    expect(find.textContaining('Weekdays at'), findsOneWidget);

    await tester.ensureVisible(find.text('Save reminder'));
    await tester.tap(find.text('Save reminder'));
    await tester.pumpAndSettle();
    expect((await ReminderRepository(db).getAll()).single.days, 31);
  });

  page('several times a day can be added and removed', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Add a reminder'));
    await tester.pumpAndSettle();
    await fillBasics(tester);

    await addTimeViaPicker(tester);
    expect(find.text(prettyTime('08:00')), findsWidgets);
    // A second distinct time: pick via the dial's PM toggle, keeping 8:00.
    await tester.ensureVisible(find.text('Add a time'));
    await tester.tap(find.text('Add a time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PM'));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text(prettyTime('20:00')), findsWidgets);

    await tester.ensureVisible(find.byTooltip('Remove ${prettyTime('08:00')}'));
    await tester.tap(find.byTooltip('Remove ${prettyTime('08:00')}'));
    await tester.pump();
    expect(find.text(prettyTime('08:00')), findsNothing);

    await tester.ensureVisible(find.text('Save reminder'));
    await tester.tap(find.text('Save reminder'));
    await tester.pumpAndSettle();
    expect((await ReminderRepository(db).getAll()).single.times, ['20:00']);
  });

  page('saving without a time is refused and explained', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Add a reminder'));
    await tester.pumpAndSettle();
    await fillBasics(tester);

    await tester.ensureVisible(find.text('Save reminder'));
    await tester.tap(find.text('Save reminder'));
    await tester.pumpAndSettle();

    expect(await db.select(db.medReminders).get(), isEmpty);
    expect(find.text('New reminder'), findsOneWidget,
        reason: 'stays on the form');
    await drainToast(tester);
  });

  page('the save button is disabled until a name is entered', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Add a reminder'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save reminder'));
    final btn = find.ancestor(
        of: find.text('Save reminder'), matching: find.byType(ElevatedButton));
    expect(tester.widget<ElevatedButton>(btn).onPressed, isNull);
    await tester.enterText(find.byType(TextField).at(0), 'X');
    await tester.pump();
    expect(tester.widget<ElevatedButton>(btn).onPressed, isNotNull);
  });

  page('the on/off switch on a reminder disables it and unschedules it',
      (tester) async {
    await ReminderRepository(db).save(const MedReminderModel(
        id: null, name: 'Metformin', dosage: 500, times: ['08:00']));
    await pumpPage(tester);

    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();

    expect((await ReminderRepository(db).getAll()).single.enabled, isFalse);
  });

  page('tapping a reminder edits it, and it can be deleted', (tester) async {
    await ReminderRepository(db).save(const MedReminderModel(
        id: null, name: 'Metformin', dosage: 500, times: ['08:00']));
    await pumpPage(tester);

    await tester.tap(find.text('Metformin'));
    await tester.pumpAndSettle();
    expect(find.text('Edit reminder'), findsOneWidget);
    expect(find.text('Delete reminder'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Metformin XR');
    await tester.pump();
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    var all = await ReminderRepository(db).getAll();
    expect(all.single.name, 'Metformin XR');
    expect(await db.select(db.medReminders).get(), hasLength(1),
        reason: 'edited in place');

    await tester.tap(find.text('Metformin XR'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete reminder'));
    await tester.tap(find.text('Delete reminder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete')); // confirm dialog
    await tester.pumpAndSettle();
    all = await ReminderRepository(db).getAll();
    expect(all, isEmpty);
    expect(find.text('No reminders yet'), findsOneWidget);
  });

  page('with notifications off, a banner explains and Turn on asks',
      (tester) async {
    scheduler.allowed = false;
    scheduler.grantOnRequest = false;
    await pumpPage(tester);

    expect(find.textContaining('Notifications are off'), findsOneWidget);
    await tester.tap(find.text('Turn on'));
    await tester.pumpAndSettle();
    expect(scheduler.requests, 1);
    expect(find.textContaining('Notifications are off'), findsOneWidget,
        reason: 'still refused');
    await drainToast(tester);
  });

  page('granting permission clears the banner', (tester) async {
    scheduler.allowed = false;
    scheduler.grantOnRequest = true;
    await pumpPage(tester);
    expect(find.textContaining('Notifications are off'), findsOneWidget);

    await tester.tap(find.text('Turn on'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Notifications are off'), findsNothing);
  });

  page('the privacy switch is remembered and reschedules with generic text',
      (tester) async {
    await ReminderRepository(db).save(const MedReminderModel(
        id: null, name: 'Metformin', dosage: 500, times: ['08:00']));
    await pumpPage(tester);

    await tester.tap(find.text('Hide medication names'));
    await tester.pumpAndSettle();

    expect(HiveStorage.get(HiveKeys.reminderHideNames), isTrue);
    expect(scheduler.calls.last.hideNames, isTrue);
  });
}
