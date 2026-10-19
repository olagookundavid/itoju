import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/ids.dart';
import 'package:itoju_mobile/data/repositories/points_repository.dart';

void main() {
  late AppDatabase db;
  late PointsRepository repository;
  final fmt = DateFormat('yyyy-MM-dd');

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = PointsRepository(db);
  });

  tearDown(() => db.close());

  group('PointsRepository & Points System', () {
    test('ensureBackfill awards registration points (10 pts) and backfills metrics', () async {
      final now = DateTime.now();
      final todayStr = fmt.format(now);

      // Insert a symptom metric row without a point record
      await db.into(db.symptomMetrics).insert(SymptomMetricsCompanion.insert(
        id: 'sym_test_1',
        localUpdatedAt: now,
        symptomsId: 1,
        date: todayStr,
      ));

      // Initially 0 points
      var points = await repository.getPoints();
      expect(points.totalPts, 0);

      // Run backfill
      await repository.ensureBackfill();

      // Should have 10 (Register) + 10 (Symptoms) = 20 total points
      points = await repository.getPoints();
      expect(points.totalPts, 20);
      expect(points.todayPts, 20);
      expect(points.weekPts, 20);
    });


    test('two entries on the same day do not break the backfill', () async {
      // Each logged entry awards its own point record, so a day with two bowel
      // movements has two 'Bowel' rows. The backfill used to throw
      // "Too many elements" on exactly this.
      final today = fmt.format(DateTime.now());
      for (final id in ['b1', 'b2']) {
        await db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
              id: id,
              localUpdatedAt: DateTime.now(),
              date: today,
            ));
        await db.into(db.pointRecords).insert(PointRecordsCompanion.insert(
              id: IdMinter.v7(),
              localUpdatedAt: DateTime.now(),
              point: 2,
              scope: 'Bowel',
              date: today,
            ));
      }
      await repository.ensureBackfill(); // must not throw
      final bowelRows = await (db.select(db.pointRecords)
            ..where((t) => t.scope.equals('Bowel')))
          .get();
      expect(bowelRows.length, 2, reason: 'existing awards left untouched');
    });

    test('concurrent backfills award registration points exactly once', () async {
      // The notifier constructor and the dashboard/profile both trigger a
      // backfill at startup; they used to interleave and double-insert.
      await Future.wait([
        repository.ensureBackfill(),
        repository.ensureBackfill(),
        repository.ensureBackfill(),
      ]);
      final reg = await (db.select(db.pointRecords)
            ..where((t) => t.scope.equals('Register')))
          .get();
      expect(reg.length, 1);
      expect((await repository.getPoints()).totalPts, 10);
    });

    test('backfill is idempotent', () async {
      final today = fmt.format(DateTime.now());
      await db.into(db.foodMetrics).insert(FoodMetricsCompanion.insert(
          id: 'f1', localUpdatedAt: DateTime.now(), date: today));
      await repository.ensureBackfill();
      final first = (await repository.getPoints()).totalPts;
      await repository.ensureBackfill();
      await repository.ensureBackfill();
      expect((await repository.getPoints()).totalPts, first);
      expect(first, 12); // 10 Register + 2 Food
    });

    test('backfill covers sleep, urine and medication like every other metric',
        () async {
      final today = fmt.format(DateTime.now());
      final now = DateTime.now();
      await db.into(db.sleepMetrics).insert(SleepMetricsCompanion.insert(
          id: 's1', localUpdatedAt: now, date: today, isNight: true));
      await db.into(db.urineMetrics).insert(UrineMetricsCompanion.insert(
          id: 'u1', localUpdatedAt: now, date: today));
      await db.into(db.medicationMetrics).insert(
          MedicationMetricsCompanion.insert(
              id: 'm1', localUpdatedAt: now, date: today));
      await repository.ensureBackfill();
      // 10 Register + 2 each for Sleep, Urine, Medication
      expect((await repository.getPoints()).totalPts, 16);
    });

    test('soft-deleted metrics are not backfilled', () async {
      final today = fmt.format(DateTime.now());
      await db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
            id: 'gone',
            localUpdatedAt: DateTime.now(),
            date: today,
            deletedAt: Value(DateTime.now()),
          ));
      await repository.ensureBackfill();
      expect((await repository.getPoints()).totalPts, 10); // Register only
    });

    test('watchPoints emits real-time updates when pointRecords change', () async {
      final now = DateTime.now();
      final todayStr = fmt.format(now);

      final stream = repository.watchPoints();

      final initial = await stream.first;
      expect(initial.totalPts, 0);

      final nextEmission = stream.first;

      // Trigger insertion
      await db.into(db.pointRecords).insert(PointRecordsCompanion.insert(
        id: IdMinter.v7(),
        localUpdatedAt: now,
        point: 5,
        scope: 'Test',
        date: todayStr,
      ));

      final updated = await nextEmission;
      expect(updated.totalPts, 5);
      expect(updated.todayPts, 5);
    });
  });
}
