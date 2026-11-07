import 'dart:io';

import 'package:drift/drift.dart'
    show OpeningDetails, QueryExecutor, QueryExecutorUser, Value;
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
    expect(await meta(db, 'catalogSeedVersion'),
        '${AppDatabase.catalogSeedVersion}');
    expect(
        (await db.select(db.bowelMetrics).get()).map((r) => r.id), ['keep-me']);
  });

  test('a missing seed version (very old install) is also re-seeded', () async {
    var db = open();
    await (db.delete(db.symptoms)..where((t) => t.id.equals(2))).go();
    await (db.delete(db.syncMeta)
          ..where((t) => t.key.equals('catalogSeedVersion')))
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
    expect(await meta(db, 'catalogSeedVersion'),
        '${AppDatabase.catalogSeedVersion}');
  });

  test(
      'upgrading a v1 (1.1.x) database to v2 keeps data and adds the new schema',
      () async {
    // A database exactly as 1.1.x left it: schema version 1, an old catalog
    // seed, and a settings row with whole-number body measurements.
    final raw = NativeDatabase(file, setup: (d) {
      d.execute('''
        CREATE TABLE sync_meta ("key" TEXT NOT NULL PRIMARY KEY, value TEXT NULL);
        CREATE TABLE symptoms (id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL);
        CREATE TABLE tracked_metrics_catalog (id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL);
        CREATE TABLE smiley_catalog (id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL);
        CREATE TABLE conditions (id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL);
        CREATE TABLE user_settings (
          id TEXT NOT NULL PRIMARY KEY, updated_at INTEGER NULL, deleted_at INTEGER NULL,
          sync_state TEXT NOT NULL DEFAULT 'pending', local_updated_at INTEGER NOT NULL,
          period_len INTEGER NOT NULL DEFAULT 0, cycle_len INTEGER NOT NULL DEFAULT 0,
          height INTEGER NOT NULL DEFAULT 0, weight INTEGER NOT NULL DEFAULT 0);
        CREATE TABLE medication_metrics (
          id TEXT NOT NULL PRIMARY KEY, updated_at INTEGER NULL, deleted_at INTEGER NULL,
          sync_state TEXT NOT NULL DEFAULT 'pending', local_updated_at INTEGER NOT NULL,
          date TEXT NOT NULL, name TEXT NOT NULL DEFAULT '', dosage INTEGER NOT NULL DEFAULT 0,
          metric TEXT NOT NULL DEFAULT '', quantity INTEGER NOT NULL DEFAULT 0,
          time TEXT NOT NULL DEFAULT '');
        INSERT INTO medication_metrics (id, sync_state, local_updated_at, date, name, dosage, metric, quantity)
          VALUES ('m1', 'synced', 1700000000, '2026-10-01', 'Iron', 65, 'mg', 2);
        INSERT INTO sync_meta VALUES ('catalogSeedVersion', '1');
        INSERT INTO tracked_metrics_catalog VALUES (1, 'Food Diary');
        INSERT INTO user_settings (id, sync_state, local_updated_at, period_len, cycle_len, height, weight)
          VALUES ('s1', 'synced', 1700000000, 5, 28, 70, 150);
        INSERT INTO user_settings (id, sync_state, local_updated_at) VALUES ('s2', 'synced', 1700000000);
        PRAGMA user_version = 1;
      ''');
    });
    await raw.ensureOpen(_NoUser());
    await raw.close();

    final db = open();
    addTearDown(db.close);

    // New tables exist and work.
    expect(await db.select(db.bpMetrics).get(), isEmpty);
    expect(await db.select(db.medReminders).get(), isEmpty);

    // Whole numbers carried into cm / kg, and queued to sync; untouched row stays synced.
    final withData = await (db.select(db.userSettings)
          ..where((t) => t.id.equals('s1')))
        .getSingle();
    expect([withData.heightCm, withData.weightKg], [70.0, 150.0]);
    expect([withData.periodLen, withData.cycleLen], [5, 28],
        reason: 'other settings untouched');
    expect(withData.syncState, 'pending');
    final empty = await (db.select(db.userSettings)
          ..where((t) => t.id.equals('s2')))
        .getSingle();
    expect([empty.heightCm, empty.weightKg], [0.0, 0.0]);
    expect(empty.syncState, 'synced');

    // Medication entries survive the v3 rebuild, whole numbers as decimals,
    // and are not re-queued (the server already holds the same values).
    final med = await db.select(db.medicationMetrics).getSingle();
    expect([med.name, med.dosage, med.quantity, med.metric],
        ['Iron', 65.0, 2.0, 'mg']);
    expect(med.syncState, 'synced');

    // The catalog top-up delivers Blood Pressure as id 9.
    final bp = await (db.select(db.trackedMetricsCatalog)
          ..where((t) => t.id.equals(9)))
        .getSingle();
    expect(bp.name, 'Blood Pressure');
    expect(await meta(db, 'catalogSeedVersion'),
        '${AppDatabase.catalogSeedVersion}');
  });

  test('upgrading a v2 (1.2.0) database to v3 makes doses decimal, data kept',
      () async {
    final raw = NativeDatabase(file, setup: (d) {
      d.execute('''
        CREATE TABLE sync_meta ("key" TEXT NOT NULL PRIMARY KEY, value TEXT NULL);
        CREATE TABLE symptoms (id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL);
        CREATE TABLE tracked_metrics_catalog (id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL);
        CREATE TABLE smiley_catalog (id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL);
        CREATE TABLE conditions (id INTEGER NOT NULL PRIMARY KEY, name TEXT NOT NULL);
        CREATE TABLE medication_metrics (
          id TEXT NOT NULL PRIMARY KEY, updated_at INTEGER NULL, deleted_at INTEGER NULL,
          sync_state TEXT NOT NULL DEFAULT 'pending', local_updated_at INTEGER NOT NULL,
          date TEXT NOT NULL, name TEXT NOT NULL DEFAULT '', dosage INTEGER NOT NULL DEFAULT 0,
          metric TEXT NOT NULL DEFAULT '', quantity INTEGER NOT NULL DEFAULT 0,
          time TEXT NOT NULL DEFAULT '');
        INSERT INTO medication_metrics (id, sync_state, local_updated_at, date, name, dosage, metric, quantity)
          VALUES ('m1', 'synced', 1700000000, '2026-10-01', 'Iron', 65, 'mg', 2);
        CREATE TABLE med_reminders (
          id TEXT NOT NULL PRIMARY KEY, updated_at INTEGER NULL, deleted_at INTEGER NULL,
          sync_state TEXT NOT NULL DEFAULT 'pending', local_updated_at INTEGER NOT NULL,
          name TEXT NOT NULL, dosage INTEGER NOT NULL DEFAULT 0,
          unit TEXT NOT NULL DEFAULT 'mg', quantity INTEGER NOT NULL DEFAULT 1,
          days INTEGER NOT NULL DEFAULT 127, times TEXT NOT NULL DEFAULT '[]',
          enabled INTEGER NOT NULL DEFAULT 1 CHECK (enabled IN (0, 1)));
        INSERT INTO med_reminders (id, sync_state, local_updated_at, name, dosage, quantity, times)
          VALUES ('r1', 'synced', 1700000000, 'Metformin', 500, 2, '["08:00"]');
        INSERT INTO sync_meta VALUES ('catalogSeedVersion', '${AppDatabase.catalogSeedVersion}');
        PRAGMA user_version = 2;
      ''');
    });
    await raw.ensureOpen(_NoUser(2));
    await raw.close();

    final db = open();
    addTearDown(db.close);

    final med = await db.select(db.medicationMetrics).getSingle();
    expect([med.dosage, med.quantity, med.syncState], [65.0, 2.0, 'synced']);
    final rem = await db.select(db.medReminders).getSingle();
    expect([rem.name, rem.dosage, rem.quantity, rem.times, rem.syncState],
        ['Metformin', 500.0, 2.0, ['08:00'], 'synced']);

    // And a decimal now round-trips.
    await (db.update(db.medicationMetrics)..where((t) => t.id.equals('m1')))
        .write(const MedicationMetricsCompanion(
            dosage: Value(2.5), quantity: Value(0.5)));
    final after = await db.select(db.medicationMetrics).getSingle();
    expect([after.dosage, after.quantity], [2.5, 0.5]);
  });
}

class _NoUser extends QueryExecutorUser {
  _NoUser([this.schemaVersion = 1]);
  @override
  final int schemaVersion;
  @override
  Future<void> beforeOpen(
      QueryExecutor executor, OpeningDetails details) async {}
}
