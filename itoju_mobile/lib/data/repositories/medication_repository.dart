import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../amounts.dart';
import '../limits.dart';
import '../medication_suggestions.dart';
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

  /// Medications this person has logged before (newest first) plus any they
  /// set reminders for, one per name, for the name box to suggest. Local only,
  /// so it works offline and never shows anyone else's medicines.
  Future<List<MedicationModel>> suggestions() async {
    final logged = await (_db.select(_db.medicationMetrics)
          ..where((t) => t.deletedAt.isNull() & t.name.trim().equals('').not())
          // Timestamps are stored to the second; the v7 id breaks ties in
          // creation order.
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.localUpdatedAt, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ])
          ..limit(500))
        .get();
    final reminders = await (_db.select(_db.medReminders)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.localUpdatedAt, mode: OrderingMode.desc)
          ]))
        .get();
    return mergeMedSuggestions(
      logged.map(_toModel).toList(),
      reminders
          .map((r) => MedicationModel(
                id: null,
                time: '',
                metric: r.unit,
                name: r.name,
                dosage: r.dosage,
                quantity: r.quantity,
              ))
          .toList(),
    );
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
          dosage: Value(clampAmount(m.dosage)),
          metric: Value(m.metric),
          quantity: Value(clampAmount(m.quantity)),
          time: Value(clipText(m.time, kMaxShortText)),
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
        dosage: Value(clampAmount(m.dosage)),
        metric: Value(m.metric),
        quantity: Value(clampAmount(m.quantity)),
        time: Value(clipText(m.time, kMaxShortText)),
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
