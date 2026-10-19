import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/db/app_database.dart';

/// The seeded catalogs (symptoms, conditions, …) used to be written once, on
/// first install, and never again — so a symptom added in an app update would
/// never reach existing users. Opening the database now re-seeds when the
/// catalog version is behind, without touching user data.
void main() {
  late Directory dir;
  late File file;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('itoju_db');
    file = File('${dir.path}/app.sqlite');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  AppDatabase open() => AppDatabase(NativeDatabase(file));

  Future<String?> meta(AppDatabase db, String k) async =>
      (await (db.select(db.syncMeta)..where((t) => t.key.equals(k)))
              .getSingleOrNull())
          ?.value;

  test('reopening with a current catalog leaves it alone', () async {
    var db = open();
    await (db.delete(db.symptoms)..where((t) => t.id.equals(1))).go();
    await db.close();

    db = open(); // version is current -> no reseed
    addTearDown(db.close);
    expect(
        await (db.select(db.symptoms)..where((t) => t.id.equals(1)))
            .getSingleOrNull(),
        isNull);
  });

  test('an older catalog version is re-seeded, user data untouched', () async {
    var db = open();
    // user data that must survive
    await db.into(db.bowelMetrics).insert(BowelMetricsCompanion.insert(
        id: 'keep-me', localUpdatedAt: DateTime.now(), date: '2026-05-01'));
    // simulate an install seeded by an OLDER app: a missing symptom, old version
    await (db.delete(db.symptoms)..where((t) => t.id.equals(1))).go();
    await db.into(db.syncMeta).insertOnConflictUpdate(SyncMetaCompanion.insert(
        key: 'catalogSeedVersion', value: const Value('0')));
    await db.close();

    db = open();
    addTearDown(db.close);
    expect(
        await (db.select(db.symptoms)..where((t) => t.id.equals(1)))
            .getSingleOrNull(),
        isNotNull,
        reason: 'catalog rows missing from an older seed are restored');
    expect(await meta(db, 'catalogSeedVersion'), '${AppDatabase.catalogSeedVersion}');
    expect(
        (await db.select(db.bowelMetrics).get()).map((r) => r.id), ['keep-me']);
  });

  test('a missing seed version (very old install) is also re-seeded', () async {
    var db = open();
    await (db.delete(db.symptoms)..where((t) => t.id.equals(2))).go();
    await (db.delete(db.syncMeta)..where((t) => t.key.equals('catalogSeedVersion')))
        .go();
    await db.close();

    db = open();
    addTearDown(db.close);
    expect(
        await (db.select(db.symptoms)..where((t) => t.id.equals(2)))
            .getSingleOrNull(),
        isNotNull);
  });

  test('erasing user data keeps the catalog and its version', () async {
    final db = open();
    addTearDown(db.close);
    await db.eraseAllUserData();
    expect((await db.select(db.symptoms).get()).isNotEmpty, isTrue);
    expect(await meta(db, 'catalogSeedVersion'), '${AppDatabase.catalogSeedVersion}');
  });
}
