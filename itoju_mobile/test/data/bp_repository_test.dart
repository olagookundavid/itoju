import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/blood_pressure.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/models/bp_model.dart';
import 'package:itoju_mobile/data/repositories/bp_repository.dart';
import 'package:itoju_mobile/data/repositories/metrics_status_repository.dart';

BpModel reading(int s, int d, int p, {String date = '2026-10-01', String time = '08:00'}) =>
    BpModel(id: null, date: date, time: time, systolic: s, diastolic: d, pulse: p);

void main() {
  late AppDatabase db;
  late BpRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = BpRepository(db);
  });
  tearDown(() => db.close());

  test('a saved reading round-trips with its category and starts pending', () async {
    await repo.create('2026-10-01', reading(132, 84, 71));

    final list = await repo.getForDate('2026-10-01');
    expect(list, hasLength(1));
    expect([list[0].systolic, list[0].diastolic, list[0].pulse], [132, 84, 71]);
    expect(list[0].category, BpCategory.stage1);
    expect(list[0].time, '08:00');

    final row = await db.select(db.bpMetrics).getSingle();
    expect(row.syncState, 'pending');
    expect(row.updatedAt, isNotNull);
  });

  test('readings for a day come back in time order, other days excluded', () async {
    await repo.create('2026-10-01', reading(120, 80, 70, time: '20:30'));
    await repo.create('2026-10-01', reading(118, 78, 66, time: '07:15'));
    await repo.create('2026-10-02', reading(125, 82, 72));

    final day = await repo.getForDate('2026-10-01');
    expect(day.map((r) => r.time), ['07:15', '20:30']);
  });

  test('each reading earns 2 BloodPressure points', () async {
    await repo.create('2026-10-01', reading(120, 80, 70));
    await repo.create('2026-10-01', reading(121, 81, 71));

    final pts = await db.select(db.pointRecords).get();
    expect(pts.map((p) => [p.scope, p.point, p.date]),
        everyElement(['BloodPressure', 2, '2026-10-01']));
    expect(pts, hasLength(2));
  });

  test('an implausible reading is refused and nothing is written', () async {
    await expectLater(repo.create('2026-10-01', reading(80, 120, 70)),
        throwsA(isA<ArgumentError>()));
    await expectLater(repo.create('2026-10-01', reading(300, 80, 70)),
        throwsA(isA<ArgumentError>()));

    expect(await db.select(db.bpMetrics).get(), isEmpty);
    expect(await db.select(db.pointRecords).get(), isEmpty,
        reason: 'no points for a reading that was not saved');
  });

  test('update changes the reading and re-marks it pending', () async {
    await repo.create('2026-10-01', reading(120, 80, 70));
    final saved = (await repo.getForDate('2026-10-01')).single;
    await db.customStatement("UPDATE bp_metrics SET sync_state = 'synced'");

    await repo.update(BpModel(
        id: saved.id, date: saved.date, time: '09:45', systolic: 128, diastolic: 82, pulse: 75));

    final after = (await repo.getForDate('2026-10-01')).single;
    expect([after.systolic, after.diastolic, after.pulse, after.time], [128, 82, 75, '09:45']);
    expect((await db.select(db.bpMetrics).getSingle()).syncState, 'pending');

    await expectLater(
        repo.update(BpModel(
            id: saved.id, date: saved.date, time: '09:45', systolic: 70, diastolic: 90, pulse: 75)),
        throwsA(isA<ArgumentError>()));
    expect((await repo.getForDate('2026-10-01')).single.systolic, 128,
        reason: 'a refused update leaves the stored reading alone');
  });

  test('delete is a soft delete that syncs as a tombstone', () async {
    await repo.create('2026-10-01', reading(120, 80, 70));
    final saved = (await repo.getForDate('2026-10-01')).single;
    await db.customStatement("UPDATE bp_metrics SET sync_state = 'synced'");

    await repo.delete(saved.id!);

    expect(await repo.getForDate('2026-10-01'), isEmpty);
    final row = await db.select(db.bpMetrics).getSingle();
    expect(row.deletedAt, isNotNull, reason: 'row kept as a tombstone');
    expect(row.syncState, 'pending');
  });

  test('dailyAverages averages same-day readings and skips empty days', () async {
    await repo.create('2026-10-01', reading(120, 80, 70));
    await repo.create('2026-10-01', reading(130, 90, 80, time: '20:00'));
    await repo.create('2026-10-04', reading(110, 70, 60));
    await repo.create('2026-09-20', reading(150, 95, 90)); // outside the window
    final gone = (await repo.getForDate('2026-10-04')).single;
    await repo.create('2026-10-03', reading(140, 88, 77));
    await repo.delete(gone.id!); // deleted readings must not be averaged

    final pts = await repo.dailyAverages(DateTime(2026, 9, 28), DateTime(2026, 10, 7));
    expect(pts.map((p) => p.date), ['2026-10-01', '2026-10-03']);
    expect([pts[0].systolic, pts[0].diastolic, pts[0].pulse, pts[0].readings],
        [125.0, 85.0, 75.0, 2]);
  });

  test('latest returns the newest live reading across days', () async {
    expect(await repo.latest(), isNull);
    await repo.create('2026-10-01', reading(120, 80, 70, time: '23:00'));
    await repo.create('2026-10-02', reading(131, 85, 73, time: '06:00'));
    await repo.create('2026-10-02', reading(126, 82, 69, time: '18:00'));

    final l = (await repo.latest())!;
    expect([l.date, l.time, l.systolic], ['2026-10-02', '18:00', 126]);

    await repo.delete(l.id!);
    expect((await repo.latest())!.time, '06:00');
  });

  test('the daily status reports a logged reading', () async {
    final status = MetricsStatusRepository(db);
    expect((await status.statusForDate('2026-10-01')).bp, isFalse);
    await repo.create('2026-10-01', reading(120, 80, 70));
    expect((await status.statusForDate('2026-10-01')).bp, isTrue);
    expect((await status.statusForDate('2026-10-02')).bp, isFalse);
  });

  test('erasing user data also removes blood-pressure readings', () async {
    await repo.create('2026-10-01', reading(120, 80, 70));
    await db.eraseAllUserData();
    expect(await db.select(db.bpMetrics).get(), isEmpty);
  });
}
