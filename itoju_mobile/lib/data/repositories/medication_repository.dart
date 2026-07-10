import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../ids.dart';
import '../models/medication_model.dart';
import '../providers.dart';

final medicationRepositoryProvider = Provider<MedicationRepository>(
  (ref) => MedicationRepository(ref.watch(appDatabaseProvider)),
);

/// Local source of truth for medication metrics. Every write marks the row
/// sync_state=pending and bumps local_updated_at so the SyncEngine can find it;
/// deletes are soft (tombstones). No network here — the app works fully offline.
class MedicationRepository {
  MedicationRepository(this._db);
  final AppDatabase _db;

  Future<List<MedicationModel>> getForDate(String date) async {
    final rows = await (_db.select(_db.medicationMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.localUpdatedAt, mode: OrderingMode.desc)
          ]))
        .get();
    return rows.map(_toModel).toList();
  }

  Future<void> create(String date, MedicationModel m) async {
    final now = DateTime.now();
    await _db
        .into(_db.medicationMetrics)
        .insert(MedicationMetricsCompanion.insert(
          id: IdMinter.v7(),
          localUpdatedAt: now,
          date: date,
          name: Value(m.name),
          dosage: Value(m.dosage),
          metric: Value(m.metric),
          quantity: Value(m.quantity),
          time: Value(m.time),
          updatedAt: Value(now),
        ));
    await _awardPoints(date, 2, 'Medication');
  }

  Future<void> update(MedicationModel m) async {
    final now = DateTime.now();
    await (_db.update(_db.medicationMetrics)..where((t) => t.id.equals(m.id!)))
        .write(
      MedicationMetricsCompanion(
        name: Value(m.name),
        dosage: Value(m.dosage),
        metric: Value(m.metric),
        quantity: Value(m.quantity),
        time: Value(m.time),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
  }

  Future<void> delete(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.medicationMetrics)..where((t) => t.id.equals(id)))
        .write(
      MedicationMetricsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
  }

  Future<void> _awardPoints(String date, int points, String scope) async {
    await _db.into(_db.pointRecords).insert(PointRecordsCompanion.insert(
          id: IdMinter.v7(),
          localUpdatedAt: DateTime.now(),
          point: points,
          scope: scope,
          date: date,
        ));
  }

  MedicationModel _toModel(MedicationMetric r) => MedicationModel(
        id: r.id,
        time: r.time,
        metric: r.metric,
        name: r.name,
        dosage: r.dosage,
        quantity: r.quantity,
      );
}
