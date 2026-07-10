import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../models/metric_status_model.dart';
import '../providers.dart';

final metricsStatusRepositoryProvider = Provider<MetricsStatusRepository>(
  (ref) => MetricsStatusRepository(ref.watch(appDatabaseProvider)),
);

/// Local source of truth for the daily per-tracker checkmarks. For a given
/// 'yyyy-MM-dd' date, reports which of the 7 trackers has at least one LIVE
/// (deletedAt IS NULL) row for that date. No network here — fully offline.
class MetricsStatusRepository {
  MetricsStatusRepository(this._db);
  final AppDatabase _db;

  Future<MetricStatusModel> statusForDate(String date) async {
    return MetricStatusModel(
      symptoms: await _hasSymptoms(date),
      sleep: await _hasSleep(date),
      food: await _hasFood(date),
      exercise: await _hasExercise(date),
      medication: await _hasMedication(date),
      urine: await _hasUrine(date),
      bowel: await _hasBowel(date),
    );
  }

  Future<bool> _hasSymptoms(String date) async {
    final row = await (_db.select(_db.symptomMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> _hasFood(String date) async {
    final row = await (_db.select(_db.foodMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> _hasSleep(String date) async {
    final row = await (_db.select(_db.sleepMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> _hasMedication(String date) async {
    final row = await (_db.select(_db.medicationMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> _hasExercise(String date) async {
    final row = await (_db.select(_db.exerciseMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> _hasUrine(String date) async {
    final row = await (_db.select(_db.urineMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> _hasBowel(String date) async {
    final row = await (_db.select(_db.bowelMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }
}
