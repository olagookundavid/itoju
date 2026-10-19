import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/account_service.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/limits.dart';
import 'package:itoju_mobile/data/models/bowel_model.dart';
import 'package:itoju_mobile/data/models/exercise_model.dart';
import 'package:itoju_mobile/data/models/food_model.dart';
import 'package:itoju_mobile/data/models/medication_model.dart';
import 'package:itoju_mobile/data/models/urine_model.dart';
import 'package:itoju_mobile/data/repositories/bowel_repository.dart';
import 'package:itoju_mobile/data/repositories/exercise_repository.dart';
import 'package:itoju_mobile/data/repositories/food_repository.dart';
import 'package:itoju_mobile/data/repositories/medication_repository.dart';
import 'package:itoju_mobile/data/repositories/menses_repository.dart';
import 'package:itoju_mobile/data/repositories/settings_repository.dart';
import 'package:itoju_mobile/data/repositories/urine_repository.dart';

/// The server's columns are small (NUMERIC(5,2), SMALLINT, VARCHAR(255/20)).
/// One value past those limits makes Postgres reject the row, and before the
/// server learned to quarantine such rows it wedged that user's cloud backup
/// forever. These tests pin the client side: bad values never reach storage.
class _FixedAccount extends AccountService {
  @override
  Future<String> localAccountId() async => 'acct-test';
  @override
  Future<String> deterministicNamespaceId() async => 'acct-test';
}

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('helpers', () {
    test('clipText', () {
      expect(clipText('abc', 5), 'abc');
      expect(clipText('abcdef', 3), 'abc');
      expect(clipText(null, 3), '');
    });
    test('clampSmallInt', () {
      expect(clampSmallInt(-5), 0);
      expect(clampSmallInt(40000), 32767);
      expect(clampSmallInt(12), 12);
    });
    test('clampUnit keeps sliders inside the DB CHECK (0..1)', () {
      expect(clampUnit(-0.2), 0);
      expect(clampUnit(1.7), 1);
      expect(clampUnit(0.4), 0.4);
      expect(clampUnit(double.nan), 0);
    });
    test('clampQuantity fits NUMERIC(5,2)', () {
      expect(clampQuantity(99999), 999.99);
      expect(clampQuantity(-1), 0);
      expect(clampQuantity(12.5), 12.5);
    });
  });

  group('repositories refuse out-of-range values', () {
    test('urine quantity / pain / time', () async {
      await UrineRepository(db).create(
          '2026-05-01',
          UrineModel(
              time: 'x' * 50, tags: const [], type: 1, pain: 7, quantity: 99999));
      final r = await db.select(db.urineMetrics).getSingle();
      expect(r.quantity, 999.99);
      expect(r.pain, 1);
      expect(r.time.length, kMaxShortText);
    });

    test('medication dosage / quantity', () async {
      await MedicationRepository(db).create(
          '2026-05-01',
          MedicationModel(
              id: null,
              name: 'n', dosage: 99999, metric: 'mg', quantity: -3, time: '8'));
      final r = await db.select(db.medicationMetrics).getSingle();
      expect(r.dosage, 32767);
      expect(r.quantity, 0);
    });

    test('exercise count and times', () async {
      await ExerciseRepository(db).create(
          '2026-05-01',
          ExerciseModel(
              name: 'run',
              started: 's' * 40,
              ended: 'e' * 40,
              tags: const [],
              noOfTimes: 1000000));
      final r = await db.select(db.exerciseMetrics).getSingle();
      expect(r.noOfTimes, 32767);
      expect(r.started.length, kMaxShortText);
      expect(r.ended.length, kMaxShortText);
    });

    test('bowel pain', () async {
      await BowelRepository(db).create('2026-05-01',
          BowelModel(time: '08:00', tags: const [], type: 3, pain: 4.2));
      expect((await db.select(db.bowelMetrics).getSingle()).pain, 1);
    });

    test('food: long text clipped, water count bounded', () async {
      final repo = FoodRepository(db, _FixedAccount());
      await repo.upsert(
          '2026-05-01',
          FoodMetricModel(
              id: null,
              breakfastMeal: 'b' * 400,
              snackName: 's' * 400,
              glassNo: 99999));
      final r = await db.select(db.foodMetrics).getSingle();
      expect(r.breakfastMeal.length, kMaxText);
      expect(r.snackName.length, kMaxText);
      expect(r.glassNo, 32767);
    });
  });

  group('menstrual settings and cycles', () {
    test('createCycle rejects nonsense lengths instead of generating them',
        () async {
      final repo = MensesRepository(db, _FixedAccount());
      for (final bad in [(0, 5), (1000, 5), (28, 0), (28, 40), (-1, 5)]) {
        expect(() => repo.createCycle('2026-05-01', bad.$1, bad.$2),
            throwsArgumentError,
            reason: 'cycle=${bad.$1} period=${bad.$2}');
      }
      expect(await db.select(db.menstrualCycles).get(), isEmpty);
      expect(await db.select(db.cycleDays).get(), isEmpty,
          reason: 'a 1000-day cycle must not create 1000 day rows');
      expect(await repo.createCycle('2026-05-01', 28, 5), isTrue);
      expect((await db.select(db.cycleDays).get()).length, 28);
    });

    test('updateMenses clamps to sane bounds', () async {
      final repo = SettingsRepository(db, _FixedAccount());
      await repo.updateMenses(99999, 99999);
      final m = await repo.getMenses();
      expect(m.cycleLen, lessThanOrEqualTo(kMaxCycleLength));
      expect(m.periodLen, lessThanOrEqualTo(kMaxPeriodLength));
      await repo.updateMenses(-4, -9);
      final z = await repo.getMenses();
      expect(z.periodLen, 0);
      expect(z.cycleLen, 0);
    });
  });
}
