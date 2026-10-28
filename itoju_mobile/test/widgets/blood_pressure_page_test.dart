import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/providers.dart';
import 'package:itoju_mobile/features/metrics/pages/blood_pressure.dart';
import 'package:itoju_mobile/features/metrics/widgets/bp_trend_chart.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

void main() {
  late AppDatabase db;
  final today = DateTime.now();
  final todayKey = DateFormat('yyyy-MM-dd').format(today);

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    // The test font (Ahem) draws every glyph a full em wide, about twice a real
    // font, which overflows any realistic layout. Scale text to roughly real width.
    tester.platformDispatcher.textScaleFactorTestValue = 0.55;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => ToastificationWrapper(
          child: MaterialApp(home: BloodPressurePage(today)),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Finder numberField(int i) => find.byType(TextField).at(i);

  Future<void> enter(
      WidgetTester tester, String sys, String dia, String pulse) async {
    await tester.enterText(numberField(0), sys);
    await tester.enterText(numberField(1), dia);
    await tester.enterText(numberField(2), pulse);
    await tester.pump();
  }

  Future<void> tapSave(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
    // getAlert raises a toast with a 4 s timer; let it expire.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the category live as numbers are typed', (tester) async {
    await pumpPage(tester);
    expect(find.text('High – Stage 1'), findsNothing);

    await enter(tester, '132', '84', '71');
    expect(find.text('High – Stage 1'), findsOneWidget);

    await enter(tester, '110', '70', '71');
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('High – Stage 1'), findsNothing);
  });

  testWidgets('saving adds the reading to the list and the trend',
      (tester) async {
    await pumpPage(tester);
    expect(find.text('No readings for this day yet'), findsOneWidget);

    await enter(tester, '122', '81', '68');
    await tapSave(tester, 'Save reading');

    final rows = await db.select(db.bpMetrics).get();
    expect(rows, hasLength(1));
    expect([rows[0].systolic, rows[0].diastolic, rows[0].pulse, rows[0].date],
        [122, 81, 68, todayKey]);

    expect(find.text('No readings for this day yet'), findsNothing);
    expect(find.text('122/81'), findsOneWidget);
    expect(find.byType(BpTrendChart), findsOneWidget);
    // Legend names each series and carries its latest value (not colour alone).
    expect(find.text('Systolic 122'), findsOneWidget);
    expect(find.text('Diastolic 81'), findsOneWidget);
    expect(find.text('Pulse 68'), findsOneWidget);
    // The form is cleared for the next reading.
    expect(tester.widget<TextField>(numberField(0)).controller!.text, isEmpty);
  });

  testWidgets('a swapped top/bottom pair is refused', (tester) async {
    await pumpPage(tester);
    await enter(tester, '80', '120', '70');
    await tapSave(tester, 'Save reading');

    expect(await db.select(db.bpMetrics).get(), isEmpty);
    expect(tester.widget<TextField>(numberField(0)).controller!.text, '80',
        reason: 'what was typed is kept so it can be corrected');
  });

  testWidgets('tapping a reading edits it; delete removes it', (tester) async {
    await pumpPage(tester);
    await enter(tester, '122', '81', '68');
    await tapSave(tester, 'Save reading');

    await tester.tap(find.text('122/81'));
    await tester.pumpAndSettle();
    expect(find.text('Edit reading'), findsOneWidget);
    expect(tester.widget<TextField>(numberField(0)).controller!.text, '122');

    await enter(tester, '138', '88', '74');
    await tapSave(tester, 'Update reading');
    var rows = await db.select(db.bpMetrics).get();
    expect(rows, hasLength(1), reason: 'edited in place, not duplicated');
    expect([rows[0].systolic, rows[0].diastolic, rows[0].pulse], [138, 88, 74]);
    expect(find.text('138/88'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete reading'));
    await tester.pumpAndSettle();
    rows = await db.select(db.bpMetrics).get();
    expect(rows.single.deletedAt, isNotNull);
    expect(find.text('138/88'), findsNothing);
  });

  testWidgets('the 30-day view and the table are reachable', (tester) async {
    await pumpPage(tester);
    await enter(tester, '122', '81', '68');
    await tapSave(tester, 'Save reading');

    await tester.ensureVisible(find.text('30 days'));
    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(find.byType(BpTrendChart), findsOneWidget);
    expect(tester.widget<BpTrendChart>(find.byType(BpTrendChart)).days, 30);

    await tester.ensureVisible(find.text('View as table'));
    await tester.tap(find.text('View as table'));
    await tester.pumpAndSettle();
    expect(find.text('Sys'), findsOneWidget);
    expect(find.text('122'), findsWidgets);
  });
}
