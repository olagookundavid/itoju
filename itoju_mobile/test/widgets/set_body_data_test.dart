import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/data/account_service.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/providers.dart';
import 'package:itoju_mobile/data/repositories/settings_repository.dart';
import 'package:itoju_mobile/features/settings/pages/set_body_data.dart';
import 'package:toastification/toastification.dart';

class _FakeAccount extends AccountService {
  @override
  Future<String> deterministicNamespaceId() async => 'acct';
}

void main() {
  late AppDatabase db;

  // An in-memory box: the page only needs HiveStorage's get/put semantics, and
  // the file backend's real I/O cannot complete inside testWidgets' fake-async zone.
  setUpAll(() async {
    await Hive.openBox(HiveKeys.appBox, bytes: Uint8List(0));
  });
  tearDownAll(() => Hive.close());

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await HiveStorage.delete(HiveKeys.weightMetric);
    await HiveStorage.delete(HiveKeys.heightMetric);
  });
  tearDown(() => db.close());

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        accountServiceProvider.overrideWithValue(_FakeAccount()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => const ToastificationWrapper(
          child: MaterialApp(home: SetBodyData()),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  /// getAlert raises a toast with a 4 s auto-dismiss timer; let it expire so the
  /// test doesn't end with a pending timer.
  Future<void> drainToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  Finder field(String suffix) => find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.suffixText == suffix);

  String textOf(WidgetTester tester, Finder f) =>
      tester.widget<TextField>(f).controller!.text;

  testWidgets('shows stored cm / kg with their decimals', (tester) async {
    await SettingsRepository(db, _FakeAccount()).updateBodyData(172.5, 68.4);
    await pumpPage(tester);

    expect(textOf(tester, field('cm')), '172.5');
    expect(textOf(tester, field('kg')), '68.4');
  });

  testWidgets('feet + inches are separate, labelled boxes', (tester) async {
    await HiveStorage.put(
        HiveKeys.heightMetric, 'inch'); // as older builds wrote it
    await SettingsRepository(db, _FakeAccount()).updateBodyData(175.3, 70);
    await pumpPage(tester);

    expect(find.text('Feet'), findsOneWidget);
    expect(find.text('Inches'), findsOneWidget);
    expect(textOf(tester, field('ft')), '5');
    expect(textOf(tester, field('in')), '9');
    expect(field('cm'), findsNothing);
  });

  testWidgets('switching units converts the value instead of relabelling it',
      (tester) async {
    await SettingsRepository(db, _FakeAccount()).updateBodyData(177.8, 68);
    await pumpPage(tester);

    await tester.tap(find.text('ft + in'));
    await tester.pumpAndSettle();
    expect(textOf(tester, field('ft')), '5');
    expect(textOf(tester, field('in')), '10');
    expect(HiveStorage.get(HiveKeys.heightMetric), 'inch');

    await tester.tap(find.text('lb'));
    await tester.pumpAndSettle();
    expect(textOf(tester, field('lb')), '149.9'); // 68 kg
    expect(HiveStorage.get(HiveKeys.weightMetric), 'lb');
  });

  testWidgets('saving decimals in pounds stores kilograms', (tester) async {
    await HiveStorage.put(HiveKeys.weightMetric, 'ib'); // legacy spelling
    await pumpPage(tester);

    await tester.enterText(field('lb'), '150.5');
    await tester.enterText(field('cm'), '168.2');
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    await drainToast(tester);
    final saved = await SettingsRepository(db, _FakeAccount()).getBodyData();
    expect(saved.weightKg, 68.3); // 150.5 lb
    expect(saved.heightCm, 168.2);
  });

  testWidgets('inches of 12 or more are refused, nothing is saved',
      (tester) async {
    await HiveStorage.put(HiveKeys.heightMetric, 'inch');
    await pumpPage(tester);

    await tester.enterText(field('ft'), '5');
    await tester.enterText(field('in'), '13');
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    await drainToast(tester);
    expect(await db.select(db.userSettings).get(), isEmpty);
  });
}
