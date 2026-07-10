import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../account_service.dart';
import '../db/app_database.dart';
import '../ids.dart';
import '../models/symptoms_model.dart';
import '../providers.dart';

final symptomsRepositoryProvider = Provider<SymptomsRepository>(
  (ref) => SymptomsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(accountServiceProvider),
  ),
);

/// Symptoms are one-per-(symptom, day): the row id is a deterministic UUIDv5 of
/// (account, symptom, date). Re-adding a removed symptom revives its tombstone
/// (keeping any severities) rather than duplicating — mirroring the backend.
class SymptomsRepository {
  SymptomsRepository(this._db, this._account);
  final AppDatabase _db;
  final AccountService _account;

  /// The seeded symptom catalog (replaces the old `allsymptoms` API call).
  Future<List<SymptomsModel>> getCatalog() async {
    final rows = await (_db.select(_db.symptoms)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
    return rows.map((r) => SymptomsModel(r.id, r.name)).toList();
  }

  Future<List<SymptomsMetricModel>> getForDate(String date) async {
    final query = _db.select(_db.symptomMetrics).join([
      innerJoin(_db.symptoms,
          _db.symptoms.id.equalsExp(_db.symptomMetrics.symptomsId)),
    ])
      ..where(_db.symptomMetrics.date.equals(date) &
          _db.symptomMetrics.deletedAt.isNull());
    final rows = await query.get();
    return rows.map((r) {
      final m = r.readTable(_db.symptomMetrics);
      final s = r.readTable(_db.symptoms);
      return SymptomsMetricModel(
        m.id,
        s.name,
        m.morningSeverity,
        m.afternoonSeverity,
        m.nightSeverity,
      );
    }).toList();
  }

  /// Returns true if the symptom was added (new or revived); false if a live row
  /// already exists for that (symptom, day).
  Future<bool> create(int symptomId, String date) async {
    final account = await _account.deterministicNamespaceId();
    final id = IdMinter.symptoms(account, symptomId, date);
    final now = DateTime.now();

    final existing = await (_db.select(_db.symptomMetrics)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (existing != null && existing.deletedAt == null) {
      return false; // live duplicate
    }
    if (existing != null) {
      // revive tombstone, preserving its severities
      await (_db.update(_db.symptomMetrics)..where((t) => t.id.equals(id)))
          .write(SymptomMetricsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncState: const Value('pending'),
      ));
    } else {
      await _db.into(_db.symptomMetrics).insert(SymptomMetricsCompanion.insert(
            id: id,
            localUpdatedAt: now,
            symptomsId: symptomId,
            date: date,
            updatedAt: Value(now),
          ));
    }
    await _awardPoints(date, 10, 'Symptoms');
    return true;
  }

  Future<void> update(String id, double morning, double afternoon,
      double night, String date) async {
    final now = DateTime.now();
    await (_db.update(_db.symptomMetrics)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .write(SymptomMetricsCompanion(
      morningSeverity: Value(morning),
      afternoonSeverity: Value(afternoon),
      nightSeverity: Value(night),
      updatedAt: Value(now),
      localUpdatedAt: Value(now),
      syncState: const Value('pending'),
    ));
  }

  Future<void> delete(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.symptomMetrics)..where((t) => t.id.equals(id))).write(
      SymptomMetricsCompanion(
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
}
