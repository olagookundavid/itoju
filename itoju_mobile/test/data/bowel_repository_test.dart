import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/models/bowel_model.dart';
import 'package:itoju_mobile/data/repositories/bowel_repository.dart';

void main() {
  late AppDatabase db;
  late BowelRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = BowelRepository(db);
  });
  tearDown(() => db.close());

  test('create → read → update → soft delete, with points awarded', () async {
    const date = '2026-05-01';

    await repo.create(
        date, BowelModel(time: '08:00', tags: const ['am'], type: 3, pain: 0.4));
    var rows = await repo.getForDate(date);
    expect(rows.length, 1);
    expect(rows.first.type, 3);
    expect(rows.first.tags, ['am']);
    expect(rows.first.id, isNotNull);

    // a point ledger row was written (Bowel = 2)
    final points = await db.select(db.pointRecords).get();
    expect(points.length, 1);
    expect(points.first.point, 2);
    expect(points.first.scope, 'Bowel');

    // update
    final id = rows.first.id!;
    await repo.update(
        BowelModel(id: id, time: '09:00', tags: const ['pm'], type: 5, pain: 0.9));
    rows = await repo.getForDate(date);
    expect(rows.single.type, 5);
    expect(rows.single.tags, ['pm']);

    // pending after write
    final row = await (db.select(db.bowelMetrics)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    expect(row.syncState, 'pending');

    // soft delete → gone from reads, tombstone remains
    await repo.delete(id);
    rows = await repo.getForDate(date);
    expect(rows, isEmpty);
    final tombstoned = await (db.select(db.bowelMetrics)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    expect(tombstoned.deletedAt, isNotNull);
  });
}
