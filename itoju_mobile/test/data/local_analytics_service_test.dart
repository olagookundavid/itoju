import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/data/analytics/local_analytics_service.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/ids.dart';

void main() {
  late AppDatabase db;
  late LocalAnalyticsService service;
  final fmt = DateFormat('yyyy-MM-dd');

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = LocalAnalyticsService(db);
  });

  tearDown(() => db.close());

  group('LocalAnalyticsService 7-day trailing window', () {
    test('includes today and 6 days prior (7 days total), excludes 7 days prior', () async {
      final now = DateTime.now();
      final todayStr = fmt.format(now);
      final sixDaysAgoStr = fmt.format(now.subtract(const Duration(days: 6)));
      final sevenDaysAgoStr = fmt.format(now.subtract(const Duration(days: 7)));

      // Insert bowel movements on today, 6 days ago, and 7 days ago
      await db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
        id: IdMinter.v7(),
        localUpdatedAt: now,
        date: todayStr,
        type: const Value(1),
      ));
      await db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
        id: IdMinter.v7(),
        localUpdatedAt: now,
        date: sixDaysAgoStr,
        type: const Value(2),
      ));
      await db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
        id: IdMinter.v7(),
        localUpdatedAt: now,
        date: sevenDaysAgoStr,
        type: const Value(3),
      ));

      final res = await service.bowel7Days();

      // Count total non-empty entries across buckets
      int totalEntries = 0;
      res.forEach((bucket, list) {
        totalEntries += list.length;
      });

      // Should include today and 6 days ago (2 entries total), but exclude 7 days ago
      expect(totalEntries, 2);
    });
  });

  group('LocalAnalyticsService week-of-month bucketing', () {
    test('correctly buckets January 2027 across year boundary without dropping data', () async {
      final now = DateTime.now();

      // Jan 1, 2027 (Friday) -> Week 1
      await db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
        id: IdMinter.v7(),
        localUpdatedAt: now,
        date: '2027-01-01',
        type: const Value(1),
      ));

      // Jan 4, 2027 (Monday) -> Week 2
      await db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
        id: IdMinter.v7(),
        localUpdatedAt: now,
        date: '2027-01-04',
        type: const Value(2),
      ));

      // Jan 15, 2027 (Friday) -> Week 3
      await db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
        id: IdMinter.v7(),
        localUpdatedAt: now,
        date: '2027-01-15',
        type: const Value(3),
      ));

      // Jan 31, 2027 (Sunday) -> Week 5
      await db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
        id: IdMinter.v7(),
        localUpdatedAt: now,
        date: '2027-01-31',
        type: const Value(4),
      ));

      final res = await service.bowelWeek(1, 2027);

      expect(res['1']!.length, 1);
      expect(res['1']!.first['key'], 1);

      expect(res['2']!.length, 1);
      expect(res['2']!.first['key'], 2);

      expect(res['3']!.length, 1);
      expect(res['3']!.first['key'], 3);

      expect(res['5']!.length, 1);
      expect(res['5']!.first['key'], 4);
    });

    test('clamps 6th calendar week of longer months into week 5', () async {
      final now = DateTime.now();

      // Aug 31, 2026 (Monday) is in calendar week 6 of August 2026 (Aug 1 is Saturday -> Week 1)
      await db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
        id: IdMinter.v7(),
        localUpdatedAt: now,
        date: '2026-08-31',
        type: const Value(5),
      ));

      final res = await service.bowelWeek(8, 2026);

      // Should be clamped into week 5
      expect(res['5']!.length, 1);
      expect(res['5']!.first['key'], 5);
    });
  });
}
