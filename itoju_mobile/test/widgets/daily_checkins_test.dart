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
import 'package:itoju_mobile/features/dashboard/widgets/today_section.dart';
import 'package:itoju_mobile/features/settings/pages/daily_checkins.dart';
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
    for (final k in [
      HiveKeys.nudgeMorningOn,
      HiveKeys.nudgeMorningMinutes,
      HiveKeys.nudgeEveningOn,
      HiveKeys.nudgeEveningMinutes,
      HiveKeys.checkinCardSeen,
    ]) {
      await HiveStorage.delete(k);
    }
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, Widget home) async {
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
        builder: (_, __) => ToastificationWrapper(
          child: MaterialApp(home: Scaffold(body: home)),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  /// Tears the tree down at the end and lets Drift's zero-length stream-cleanup
  /// timer fire, so no timer is left pending.
  void page(String name, Future<void> Function(WidgetTester tester) body) {
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });
  }

  group('Settings page', () {
    page('both check-ins are on by default, at 7:00 AM and 6:00 PM', (tester) async {
      await pump(tester, const DailyCheckinsPage());
      expect(find.text('Good morning note'), findsOneWidget);
      expect(find.text('Evening nudge'), findsOneWidget);
      expect(find.text('At 7:00 AM'), findsOneWidget);
      expect(find.text('At 6:00 PM'), findsOneWidget);
      expect(tester.widget<SwitchListTile>(find.byKey(const Key('morningSwitch'))).value, isTrue);
      expect(tester.widget<SwitchListTile>(find.byKey(const Key('eveningSwitch'))).value, isTrue);
    });

    page('the evening card says it only comes on days nothing is logged', (tester) async {
      await pump(tester, const DailyCheckinsPage());
      expect(find.textContaining('Only on days you have not logged anything'), findsOneWidget);
    });

    page('earlier choices are shown', (tester) async {
      await HiveStorage.put(HiveKeys.nudgeMorningOn, false);
      await HiveStorage.put(HiveKeys.nudgeEveningMinutes, 20 * 60 + 30);
      await pump(tester, const DailyCheckinsPage());
      expect(find.text('At 7:00 AM'), findsNothing, reason: 'the morning note is off');
      expect(find.text('At 8:30 PM'), findsOneWidget);
    });

    page('switching one off saves it, reschedules, and never asks for permission',
        (tester) async {
      scheduler.allowed = false; // a prompt here would be wrong
      await pump(tester, const DailyCheckinsPage());
      final before = scheduler.requests;

      await tester.tap(find.byKey(const Key('morningSwitch')));
      await tester.pumpAndSettle();

      expect(HiveStorage.get(HiveKeys.nudgeMorningOn), false);
      expect(find.text('At 7:00 AM'), findsNothing);
      expect(scheduler.requests, before);
    });

    page('switching one on asks for permission when needed, then schedules',
        (tester) async {
      await HiveStorage.put(HiveKeys.nudgeMorningOn, false);
      scheduler.allowed = false;
      await pump(tester, const DailyCheckinsPage());

      await tester.tap(find.byKey(const Key('morningSwitch')));
      await tester.pumpAndSettle();

      expect(scheduler.requests, 1);
      expect(HiveStorage.get(HiveKeys.nudgeMorningOn), true);
      expect(scheduler.nudgeCalls, isNotEmpty);
      expect(scheduler.nudgeCalls.last.prefs.morningOn, isTrue);
    });

    page('when notifications are off a banner offers to turn them on', (tester) async {
      scheduler.allowed = false;
      await pump(tester, const DailyCheckinsPage());
      expect(find.textContaining('Notifications are off'), findsOneWidget);

      await tester.tap(find.text('Turn on'));
      await tester.pumpAndSettle();

      expect(scheduler.requests, 1);
      expect(find.textContaining('Notifications are off'), findsNothing);
      expect(scheduler.nudgeCalls, isNotEmpty);
    });

    page('no banner and no prompt when notifications are already allowed',
        (tester) async {
      await pump(tester, const DailyCheckinsPage());
      expect(find.textContaining('Notifications are off'), findsNothing);
      expect(scheduler.requests, 0);
    });

    page('a new time is saved and applied', (tester) async {
      await pump(tester, const DailyCheckinsPage());
      // The time picker's typing mode needs real text sizes to lay out.
      tester.platformDispatcher.textScaleFactorTestValue = 1.0;
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('morningTime')));
      await tester.pumpAndSettle();
      // Type the time instead of dragging the dial.
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '9');
      await tester.enterText(fields.at(1), '30');
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(HiveStorage.get(HiveKeys.nudgeMorningMinutes), 9 * 60 + 30);
      expect(find.text('At 9:30 AM'), findsOneWidget);
      expect(scheduler.nudgeCalls.last.prefs.morningMinutes, 9 * 60 + 30);
    });
  });

  group('Home card', () {
    page('asks for permission where the phone needs it, then goes away', (tester) async {
      scheduler.allowed = false;
      await pump(tester, const CheckinCard());
      expect(find.text('Daily check-ins'), findsOneWidget);
      expect(find.textContaining('7:00 AM'), findsOneWidget);
      expect(find.textContaining('6:00 PM'), findsOneWidget);

      await tester.tap(find.text('Allow notifications'));
      await tester.pumpAndSettle();

      expect(scheduler.requests, 1);
      expect(find.text('Daily check-ins'), findsNothing);
      expect(HiveStorage.get(HiveKeys.checkinCardSeen), true);
    });

    page('stays put when the person refuses', (tester) async {
      scheduler.allowed = false;
      scheduler.grantOnRequest = false;
      await pump(tester, const CheckinCard());

      await tester.tap(find.text('Allow notifications'));
      await tester.pumpAndSettle();
      expect(find.text('Daily check-ins'), findsOneWidget);
      expect(HiveStorage.get(HiveKeys.checkinCardSeen), isNot(true));
      await tester.pump(const Duration(seconds: 5));
    });

    page('offers no prompt when notifications are already allowed', (tester) async {
      await pump(tester, const CheckinCard());
      expect(find.text('Allow notifications'), findsNothing);
      expect(find.text('Customise'), findsOneWidget);
      expect(scheduler.requests, 0);
    });

    page('dismissing hides it for good', (tester) async {
      await pump(tester, const CheckinCard());
      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.text('Daily check-ins'), findsNothing);
      expect(HiveStorage.get(HiveKeys.checkinCardSeen), true);
    });

    page('stays hidden once seen', (tester) async {
      await HiveStorage.put(HiveKeys.checkinCardSeen, true);
      await pump(tester, const CheckinCard());
      expect(find.text('Daily check-ins'), findsNothing);
    });

    page('Customise opens the settings page', (tester) async {
      await pump(tester, const CheckinCard());
      await tester.tap(find.text('Customise'));
      await tester.pumpAndSettle();
      expect(find.text('Good morning note'), findsOneWidget);
    });
  });
}
