import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'converters.dart';
import 'seed_catalogs.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    SymptomMetrics,
    FoodMetrics,
    SleepMetrics,
    MedicationMetrics,
    ExerciseMetrics,
    UrineMetrics,
    BowelMetrics,
    MenstrualCycles,
    CycleDays,
    SmileyEntries,
    PointRecords,
    UserTrackedMetrics,
    UserConditions,
    UserSettings,
    Symptoms,
    TrackedMetricsCatalog,
    SmileyCatalog,
    Conditions,
    SyncMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'itoju'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedCatalogs();
        },
      );

  /// Erases every row of user data (health records, points, selections,
  /// settings, and all sync bookkeeping), keeping only the seeded catalogs.
  /// Used when a DIFFERENT server account signs in on this device and the user
  /// confirms the switch — the previous user's health data must not be visible
  /// to, or uploaded under, the new account.
  Future<void> eraseAllUserData() async {
    await transaction(() async {
      for (final table in <TableInfo>[
        symptomMetrics,
        foodMetrics,
        sleepMetrics,
        medicationMetrics,
        exerciseMetrics,
        urineMetrics,
        bowelMetrics,
        menstrualCycles,
        cycleDays,
        smileyEntries,
        pointRecords,
        userTrackedMetrics,
        userConditions,
        userSettings,
        syncMeta,
      ]) {
        await delete(table).go();
      }
      // Re-record the catalog seed so the seeding guard stays meaningful.
      await into(syncMeta).insertOnConflictUpdate(
        SyncMetaCompanion.insert(
            key: 'catalogSeedVersion', value: const Value('1')),
      );
    });
  }

  /// Seeds the catalog tables to match the server SERIAL ids (see seed_catalogs).
  /// Idempotent: guarded by a SyncMeta version so it runs once.
  Future<void> _seedCatalogs() async {
    await batch((b) {
      for (var i = 0; i < kSymptomsSeed.length; i++) {
        b.insert(symptoms, SymptomsCompanion.insert(id: Value(i + 1), name: kSymptomsSeed[i]),
            mode: InsertMode.insertOrReplace);
      }
      for (var i = 0; i < kSmileySeed.length; i++) {
        b.insert(smileyCatalog, SmileyCatalogCompanion.insert(id: Value(i + 1), name: kSmileySeed[i]),
            mode: InsertMode.insertOrReplace);
      }
      for (var i = 0; i < kTrackedMetricsSeed.length; i++) {
        b.insert(trackedMetricsCatalog,
            TrackedMetricsCatalogCompanion.insert(id: Value(i + 1), name: kTrackedMetricsSeed[i]),
            mode: InsertMode.insertOrReplace);
      }
      for (var i = 0; i < kConditionsSeed.length; i++) {
        b.insert(conditions, ConditionsCompanion.insert(id: Value(i + 1), name: kConditionsSeed[i]),
            mode: InsertMode.insertOrReplace);
      }
    });
    await into(syncMeta).insertOnConflictUpdate(
      SyncMetaCompanion.insert(key: 'catalogSeedVersion', value: const Value('1')),
    );
  }
}
