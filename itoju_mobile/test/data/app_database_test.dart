import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/ids.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('catalogs seed with server-matching ids', () async {
    final syms = await db.select(db.symptoms).get();
    expect(syms.length, 51);
    final one =
        await (db.select(db.symptoms)..where((t) => t.id.equals(1))).getSingle();
    expect(one.name, 'Abdominal Pain (Left)');

    final metrics = await db.select(db.trackedMetricsCatalog).get();
    expect(metrics.length, 8);
    final smileys = await db.select(db.smileyCatalog).get();
    expect(smileys.length, 5);
    final conditions = await db.select(db.conditions).get();
    expect(conditions.length, 21);
  });

  test('bowel row round-trips with tags and syncs default to pending', () async {
    final id = IdMinter.v7();
    await db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
          id: id,
          localUpdatedAt: DateTime.now(),
          date: '2026-05-01',
          type: const Value(3),
          pain: const Value(0.4),
          time: const Value('08:00'),
          tags: Value(const ['morning', 'urgent']),
        ));

    final row = await (db.select(db.bowelMetrics)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    expect(row.tags, ['morning', 'urgent']);
    expect(row.pain, 0.4);
    expect(row.syncState, 'pending');
    expect(row.deletedAt, isNull);
  });

  test('food deterministic id is stable for the same account+date', () async {
    const account = '00000000-0000-0000-0000-000000000001';
    final a = IdMinter.food(account, '2026-05-10');
    final b = IdMinter.food(account, '2026-05-10');
    expect(a, b);
    expect(a, '392ec4ce-09f7-5cb0-848e-921265e26b1f');
  });
}
