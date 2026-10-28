import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/models/bp_model.dart';
import 'package:itoju_mobile/data/models/today_summary.dart';
import 'package:itoju_mobile/data/reminder_schedule.dart';
import 'package:itoju_mobile/data/repositories/bp_repository.dart';
import 'package:itoju_mobile/data/repositories/reminder_repository.dart';
import 'package:itoju_mobile/data/repositories/today_repository.dart';

const day = '2026-10-28'; // a Wednesday
final noon = DateTime(2026, 10, 28, 12, 0);

void main() {
  late AppDatabase db;
  late TodayRepository repo;
  var n = 0;
  String id() => 'row-${n++}';
  final stamp = DateTime(2026, 10, 28);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = TodayRepository(db);
  });
  tearDown(() => db.close());

  Future<TodaySummaryAlias> sum([String d = day]) => repo.summary(d, now: noon);

  test('with nothing logged, every box invites a log and the streak is 0', () async {
    final s = await sum();
    for (final name in [
      'Food Diary', 'Symptoms', 'Sleep', 'Bowel Movements', 'Medications',
      'Urination', 'Exercise', 'Blood Pressure',
    ]) {
      expect(s.metrics[name]!.logged, isFalse, reason: name);
      expect(s.metrics[name]!.headline, 'Tap to log', reason: name);
    }
    expect(s.streak, 0);
    expect(s.moodId, isNull);
  });

  test('food counts meals and shows water as the detail', () async {
    await db.into(db.foodMetrics).insert(FoodMetricsCompanion.insert(
        id: id(), localUpdatedAt: stamp, date: day,
        breakfastMeal: const Value('Eggs'), dinnerMeal: const Value('Rice'),
        glassNo: const Value(5)));
    final m = (await sum()).metrics['Food Diary']!;
    expect([m.logged, m.headline, m.detail], [true, '2 meals', '5 glasses of water']);
  });

  test('water alone still counts as logged', () async {
    await db.into(db.foodMetrics).insert(FoodMetricsCompanion.insert(
        id: id(), localUpdatedAt: stamp, date: day, glassNo: const Value(1)));
    final m = (await sum()).metrics['Food Diary']!;
    expect([m.logged, m.headline], [true, '1 glass']);
  });

  test('symptoms count distinct symptoms', () async {
    for (final sid in [3, 3, 7]) {
      await db.into(db.symptomMetrics).insert(SymptomMetricsCompanion.insert(
          id: id(), localUpdatedAt: stamp, symptomsId: sid, date: day));
    }
    expect((await sum()).metrics['Symptoms']!.headline, '2 symptoms');
  });

  test('sleep shows hours slept, summed across entries', () async {
    await db.into(db.sleepMetrics).insert(SleepMetricsCompanion.insert(
        id: id(), localUpdatedAt: stamp, date: day, isNight: true,
        timeSlept: const Value('11:00 PM'), timeWokeUp: const Value('06:30 AM')));
    var m = (await sum()).metrics['Sleep']!;
    expect([m.logged, m.headline, m.detail], [true, '7h 30m', null]);

    await db.into(db.sleepMetrics).insert(SleepMetricsCompanion.insert(
        id: id(), localUpdatedAt: stamp, date: day, isNight: false,
        timeSlept: const Value('01:00 PM'), timeWokeUp: const Value('01:45 PM')));
    m = (await sum()).metrics['Sleep']!;
    expect([m.headline, m.detail], ['8h 15m', '2 sleeps']);
  });

  test('sleep with unreadable times falls back to a count', () async {
    await db.into(db.sleepMetrics).insert(SleepMetricsCompanion.insert(
        id: id(), localUpdatedAt: stamp, date: day, isNight: true));
    final m = (await sum()).metrics['Sleep']!;
    expect([m.logged, m.headline], [true, '1 entry']);
  });

  test('bowel, urine and exercise show counts; exercise names the first activity', () async {
    for (var i = 0; i < 2; i++) {
      await db.into(db.bowelMetrics).insert(
          BowelMetricsCompanion.insert(id: id(), localUpdatedAt: stamp, date: day));
    }
    for (var i = 0; i < 4; i++) {
      await db.into(db.urineMetrics).insert(
          UrineMetricsCompanion.insert(id: id(), localUpdatedAt: stamp, date: day));
    }
    await db.into(db.exerciseMetrics).insert(ExerciseMetricsCompanion.insert(
        id: id(), localUpdatedAt: stamp, date: day, name: const Value('Walking')));
    final s = await sum();
    expect(s.metrics['Bowel Movements']!.headline, '2 movements');
    expect(s.metrics['Urination']!.headline, '4 times');
    expect([s.metrics['Exercise']!.headline, s.metrics['Exercise']!.detail],
        ['1 activity', 'Walking']);
  });

  test('other days and deleted entries are ignored', () async {
    await db.into(db.bowelMetrics).insert(
        BowelMetricsCompanion.insert(id: id(), localUpdatedAt: stamp, date: '2026-10-27'));
    await db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
        id: id(), localUpdatedAt: stamp, date: day, deletedAt: Value(stamp)));
    expect((await sum()).metrics['Bowel Movements']!.logged, isFalse);
  });

  group('medications and the next reminder', () {
    Future<void> remind(List<String> times, {int days = kAllDays, bool enabled = true}) =>
        ReminderRepository(db)
            .save(MedReminderModel(id: null, name: 'Metformin', days: days, times: times, enabled: enabled))
            .then((_) {});

    test('with a reminder later today, the box says when', () async {
      await remind(['08:00', '20:00']);
      final m = (await sum()).metrics['Medications']!;
      expect(m.logged, isFalse);
      expect(m.detail, 'Next reminder ${DateFormat.jm().format(DateTime(2000, 1, 1, 20))}');
    });

    test('past times today are skipped; none left means no detail', () async {
      await remind(['08:00']);
      expect((await sum()).metrics['Medications']!.detail, isNull);
    });

    test('a reminder for other weekdays is not "next" today', () async {
      await remind(['20:00'], days: 1); // Mondays only; the day is a Wednesday
      expect((await sum()).metrics['Medications']!.detail, isNull);
    });

    test('a switched-off reminder is not mentioned', () async {
      await remind(['20:00'], enabled: false);
      expect((await sum()).metrics['Medications']!.detail, isNull);
    });

    test('logged doses are counted alongside the next reminder', () async {
      await remind(['20:00']);
      for (var i = 0; i < 2; i++) {
        await db.into(db.medicationMetrics).insert(MedicationMetricsCompanion.insert(
            id: id(), localUpdatedAt: stamp, date: day, name: const Value('Metformin')));
      }
      final m = (await sum()).metrics['Medications']!;
      expect([m.logged, m.headline], [true, '2 taken']);
      expect(m.detail, contains('Next reminder'));
    });
  });

  group('blood pressure', () {
    BpModel bp(int s, int d, int p, String date, String time) =>
        BpModel(id: null, date: date, time: time, systolic: s, diastolic: d, pulse: p);

    test("today's latest reading with pulse and category", () async {
      final r = BpRepository(db);
      await r.create(day, bp(118, 76, 66, day, '07:00'));
      await r.create(day, bp(134, 86, 72, day, '19:00'));
      final m = (await sum()).metrics['Blood Pressure']!;
      expect([m.logged, m.headline], [true, '134/86']);
      expect(m.detail, '72 bpm · High – Stage 1');
    });

    test('with no reading today, mentions the last one and how long ago', () async {
      await BpRepository(db).create('2026-10-25', bp(120, 80, 70, '2026-10-25', '08:00'));
      final m = (await sum()).metrics['Blood Pressure']!;
      expect([m.logged, m.headline], [false, 'Tap to log']);
      expect(m.detail, 'Last 120/80, 3 days ago');
    });
  });

  group('menstruation', () {
    Future<String> cycle(String start) async {
      final cid = id();
      await db.into(db.menstrualCycles).insert(MenstrualCyclesCompanion.insert(
          id: cid, localUpdatedAt: stamp, startDate: start));
      return cid;
    }

    test('no cycles yet invites setup', () async {
      final m = (await sum()).metrics['Menstruation and Ovulation']!;
      expect([m.logged, m.detail], [false, 'Log your period']);
    });

    test('a period day shows which day of the period', () async {
      final cid = await cycle('2026-10-26');
      await db.into(db.cycleDays).insert(CycleDaysCompanion.insert(
          id: id(), localUpdatedAt: stamp, cycleId: cid, date: day, isPeriod: const Value(true)));
      final m = (await sum()).metrics['Menstruation and Ovulation']!;
      expect([m.logged, m.headline], [true, 'Period day 3']);
    });

    test('an ovulation day says fertile window', () async {
      final cid = await cycle('2026-10-14');
      await db.into(db.cycleDays).insert(CycleDaysCompanion.insert(
          id: id(), localUpdatedAt: stamp, cycleId: cid, date: day, isOvulation: const Value(true)));
      expect((await sum()).metrics['Menstruation and Ovulation']!.headline, 'Fertile window');
    });

    test('an ordinary day in a recent cycle shows the cycle day', () async {
      await cycle('2026-10-14');
      expect((await sum()).metrics['Menstruation and Ovulation']!.headline, 'Cycle day 15');
    });

    test('the cycle day is right after a spring clock change', () async {
      // Started before 29 Mar (UK/EU clocks go forward); counted on 1 Apr.
      await cycle('2026-03-20');
      final s = await repo.summary('2026-04-01', now: DateTime(2026, 4, 1, 12));
      expect(s.metrics['Menstruation and Ovulation']!.headline, 'Cycle day 13');
    });

    test('a long-stale cycle is treated as untracked', () async {
      await cycle('2026-06-01');
      expect((await sum()).metrics['Menstruation and Ovulation']!.logged, isFalse);
    });
  });

  test('mood is today\'s latest smiley only', () async {
    await db.into(db.smileyEntries).insert(SmileyEntriesCompanion.insert(
        id: id(), localUpdatedAt: stamp, smileyId: 4, grantedAt: DateTime(2026, 10, 27, 9)));
    expect((await sum()).moodId, isNull, reason: "yesterday's mood is not today's");
    await db.into(db.smileyEntries).insert(SmileyEntriesCompanion.insert(
        id: id(), localUpdatedAt: stamp, smileyId: 2, grantedAt: DateTime(2026, 10, 28, 8)));
    await db.into(db.smileyEntries).insert(SmileyEntriesCompanion.insert(
        id: id(), localUpdatedAt: stamp, smileyId: 1, grantedAt: DateTime(2026, 10, 28, 10)));
    expect((await sum()).moodId, 1);
  });

  test('streak spans trackers and stays alive before today is logged', () async {
    await db.into(db.bowelMetrics).insert(
        BowelMetricsCompanion.insert(id: id(), localUpdatedAt: stamp, date: '2026-10-27'));
    await db.into(db.symptomMetrics).insert(SymptomMetricsCompanion.insert(
        id: id(), localUpdatedAt: stamp, symptomsId: 1, date: '2026-10-26'));
    await BpRepository(db).create('2026-10-25',
        const BpModel(id: null, date: '2026-10-25', time: '08:00', systolic: 120, diastolic: 80, pulse: 70));
    expect((await sum()).streak, 3);
  });

  test('watch emits again as soon as something is logged', () async {
    final seen = <String>[];
    final sub = repo.watch(day, now: noon).listen((s) => seen.add(s.metrics['Bowel Movements']!.headline));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await db.into(db.bowelMetrics).insert(
        BowelMetricsCompanion.insert(id: id(), localUpdatedAt: stamp, date: day));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await sub.cancel();
    expect(seen.first, 'Tap to log');
    expect(seen.last, '1 movement');
  });
}

typedef TodaySummaryAlias = TodaySummary;
