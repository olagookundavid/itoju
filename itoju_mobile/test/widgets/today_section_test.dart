import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/data/account_service.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/models/bp_model.dart';
import 'package:itoju_mobile/data/providers.dart';
import 'package:itoju_mobile/data/repositories/bp_repository.dart';
import 'package:itoju_mobile/data/repositories/tracked_metrics_repository.dart';
import 'package:itoju_mobile/features/dashboard/widgets/today_section.dart';
import 'package:itoju_mobile/features/metrics/pages/blood_pressure.dart';
import 'package:toastification/toastification.dart';

class _FakeAccount extends AccountService {
  @override
  Future<String> deterministicNamespaceId() async => 'acct';
}

void main() {
  late AppDatabase db;
  late TrackedMetricsRepository tracked;
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var n = 0;
  String id() => 'row-${n++}';

  setUpAll(() async => Hive.openBox(HiveKeys.appBox, bytes: Uint8List(0)));
  tearDownAll(() => Hive.close());

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tracked = TrackedMetricsRepository(db, _FakeAccount());
    await HiveStorage.delete(HiveKeys.whatsNew12Seen);
  });
  tearDown(() => db.close());

  Future<void> selectByName(List<String> names) async {
    final catalog = await tracked.getCatalog();
    for (final name in names) {
      await tracked.add(catalog.firstWhere((m) => m.name == name).id!);
    }
  }

  /// Like testWidgets, but disposes the tree and lets Drift's stream-cleanup timer
  /// fire so none is left pending.
  void page(String name, Future<void> Function(WidgetTester t) body) {
    testWidgets(name, (tester) async {
      tester.view.physicalSize = const Size(1125, 3600);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 0.55;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          accountServiceProvider.overrideWithValue(_FakeAccount()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, __) => const ToastificationWrapper(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Column(children: [TodaySection(), WhatsNewCard()]),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await body(tester);
      await tester.pump(const Duration(seconds: 5)); // let any toast expire
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });
  }

  page('with nothing tracked, it offers to add a metric and asks for a mood',
      (t) async {
    expect(find.text('Add a metric'), findsOneWidget);
    expect(find.text('0 of 1 logged'), findsOneWidget);
    expect(find.text('How are you feeling?'), findsOneWidget);
    expect(find.textContaining('Choose what you would like to track'),
        findsOneWidget);
  });

  page('each tracked metric gets a box that invites a log', (t) async {
    await selectByName(['Food Diary', 'Blood Pressure', 'Medications']);
    await t.pumpAndSettle();

    expect(find.text('Food Diary'), findsOneWidget);
    expect(find.text('Blood Pressure'), findsOneWidget);
    expect(find.text('Medications'), findsOneWidget);
    expect(find.text('Tap to log'), findsNWidgets(3));
    expect(find.text('0 of 4 logged'), findsOneWidget,
        reason: 'three metrics + mood');
    expect(find.text('Symptoms'), findsNothing,
        reason: 'not tracked, so no box');
  });

  page('a box updates live when something is logged elsewhere', (t) async {
    await selectByName(['Blood Pressure']);
    await t.pumpAndSettle();
    expect(find.text('Tap to log'), findsOneWidget);

    await t.runAsync(() => BpRepository(db).create(
        today,
        BpModel(
            id: null,
            date: today,
            time: '08:00',
            systolic: 122,
            diastolic: 81,
            pulse: 68)));
    await t.pumpAndSettle();

    expect(find.text('122/81'), findsOneWidget);
    expect(find.textContaining('68 bpm'), findsOneWidget);
    expect(find.text('Tap to log'), findsNothing);
    expect(find.text('1 of 2 logged'), findsOneWidget);
  });

  page('menstruation is shown but does not count toward the daily progress',
      (t) async {
    await selectByName(['Menstruation and Ovulation', 'Food Diary']);
    await t.pumpAndSettle();
    expect(find.text('Menstruation and Ovulation'), findsOneWidget);
    expect(find.text('0 of 2 logged'), findsOneWidget,
        reason: 'mood + food only');
  });

  page('tapping a mood face saves it for today', (t) async {
    await t.tap(find.text('🙂'));
    await t.pumpAndSettle();

    final rows = await db.select(db.smileyEntries).get();
    expect(rows, hasLength(1));
    expect(rows.single.smileyId, 2);
    expect(find.text('Feeling good today'), findsOneWidget);
    expect(find.text('1 of 1 logged'), findsOneWidget);
  });

  page('changing the mood keeps tags already chosen for today', (t) async {
    await db.into(db.smileyEntries).insert(SmileyEntriesCompanion.insert(
        id: id(),
        localUpdatedAt: DateTime.now(),
        smileyId: 1,
        grantedAt: DateTime.now(),
        tags: const Value(['Calm', 'Happy'])));
    await t.pumpAndSettle();

    await t.tap(find.text('🙁'));
    await t.pumpAndSettle();

    final rows = await db.select(db.smileyEntries).get();
    expect(rows, hasLength(2));
    final latest = rows.firstWhere((r) => r.smileyId == 4);
    expect(latest.tags, ['Calm', 'Happy']);
  });

  page('tapping a box opens that metric\'s entry page', (t) async {
    await selectByName(['Blood Pressure']);
    await t.pumpAndSettle();

    await t.tap(find.text('Blood Pressure'));
    await t.pumpAndSettle();

    expect(find.byType(BloodPressurePage), findsOneWidget);
  });

  page('a logging streak shows once it reaches two days', (t) async {
    expect(find.textContaining('streak'), findsNothing);
    final yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));
    await t.runAsync(() async {
      for (final d in [today, yesterday]) {
        await db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
            id: id(), localUpdatedAt: DateTime.now(), date: d));
      }
    });
    await t.pumpAndSettle();
    expect(find.text('🔥 2-day streak'), findsOneWidget);
  });

  group('What\'s new card', () {
    page('is shown until dismissed, and stays dismissed', (t) async {
      expect(find.text('New in Itoju'), findsOneWidget);
      await t.tap(find.byTooltip('Dismiss'));
      await t.pumpAndSettle();
      expect(find.text('New in Itoju'), findsNothing);
      expect(HiveStorage.get(HiveKeys.whatsNew12Seen), isTrue);
    });

    page('"Track blood pressure" tracks it, opens the page and hides the card',
        (t) async {
      expect(find.text('Blood Pressure'), findsNothing);
      await t.tap(find.text('Track blood pressure'));
      await t.pumpAndSettle();

      final selected = await tracked.getSelected();
      expect(selected.map((m) => m.name), contains('Blood Pressure'));
      expect(find.byType(BloodPressurePage), findsOneWidget);
      expect(HiveStorage.get(HiveKeys.whatsNew12Seen), isTrue);
    });
  });
}
