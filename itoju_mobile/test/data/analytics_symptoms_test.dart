import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/data/analytics/local_analytics_service.dart';
import 'package:itoju_mobile/data/db/app_database.dart';

void main() {
  late AppDatabase db;
  late LocalAnalyticsService analytics;
  final fmt = DateFormat('yyyy-MM-dd');

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    analytics = LocalAnalyticsService(db);
  });
  tearDown(() => db.close());

  // Postgres DOW bucket used by the analytics service (Sunday=0..Saturday=6).
  int dow(DateTime d) => d.weekday % 7;

  Future<void> insertSymptom(
    String id,
    int symptomId,
    DateTime date, {
    double morning = 0,
    double afternoon = 0,
    double night = 0,
  }) async {
    await db.into(db.symptomMetrics).insert(SymptomMetricsCompanion.insert(
          id: id,
          localUpdatedAt: DateTime.now(),
          symptomsId: symptomId,
          date: fmt.format(date),
          morningSeverity: Value(morning),
          afternoonSeverity: Value(afternoon),
          nightSeverity: Value(night),
          updatedAt: Value(DateTime.now()),
        ));
  }

  test('syms7Days shows every logged day, not just the rated one', () async {
    const symptomId = 42;
    final now = DateTime.now();
    // 4 consecutive days => 4 distinct weekday buckets, all inside the 7-day
    // window. Only "today" is rated; the other three are logged but unrated.
    final today = now;
    final d1 = now.subtract(const Duration(days: 1));
    final d2 = now.subtract(const Duration(days: 2));
    final d3 = now.subtract(const Duration(days: 3));

    await insertSymptom('s-today', symptomId, today, morning: 0.6);
    await insertSymptom('s-d1', symptomId, d1); // logged, unrated
    await insertSymptom('s-d2', symptomId, d2); // logged, unrated
    await insertSymptom('s-d3', symptomId, d3); // logged, unrated

    final result = await analytics.syms7Days(symptomId);

    // The old behaviour ((m+a+n)/3, no floor) gave the unrated days 0 and
    // deflated today to 0.2 — this is exactly the reported bug.
    // Every logged day must now be present...
    expect(result.containsKey('${dow(today)}'), isTrue);
    expect(result.containsKey('${dow(d1)}'), isTrue);
    expect(result.containsKey('${dow(d2)}'), isTrue);
    expect(result.containsKey('${dow(d3)}'), isTrue);

    // ...unrated days sit at the "logged" baseline...
    expect(result['${dow(d1)}'], LocalAnalyticsService.kLoggedBaseline);
    expect(result['${dow(d2)}'], LocalAnalyticsService.kLoggedBaseline);
    expect(result['${dow(d3)}'], LocalAnalyticsService.kLoggedBaseline);

    // ...and the rated day reflects its severity (mean of the rated period
    // only — not divided across all three), rising above the baseline.
    expect(result['${dow(today)}'], 0.6);
  });

  test('rating a single period is not deflated across all three', () async {
    const symptomId = 7;
    final now = DateTime.now();
    // Only the afternoon rated at 0.9; old code averaged 0.9/3 = 0.3.
    await insertSymptom('one-period', symptomId, now, afternoon: 0.9);

    final result = await analytics.syms7Days(symptomId);
    expect(result['${now.weekday % 7}'], 0.9);
  });

  test('a day with no symptom row produces no bucket', () async {
    final result = await analytics.syms7Days(999);
    expect(result, isEmpty);
  });
}
