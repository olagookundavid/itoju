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
