import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../db/app_database.dart';
import '../providers.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.watch(appDatabaseProvider)),
);

/// Local dashboard aggregates. Mirrors the backend's GetUserTopNSyms: counts
/// symptom occurrences over a trailing window grouped by symptom.
class DashboardRepository {
  DashboardRepository(this._db);
  final AppDatabase _db;

  /// Top [limit] most-tracked symptoms over the last [days] days: count live
  /// symptom occurrences grouped by symptom, joined to the catalog for the
  /// name, ordered by count desc.
  Future<List<SymsModel>> getTopSyms({int days = 30, int limit = 4}) async {
    final cutoff = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(Duration(days: days)));

    final cnt = _db.symptomMetrics.symptomsId.count();
    final q = _db.selectOnly(_db.symptomMetrics).join([
      innerJoin(_db.symptoms,
          _db.symptoms.id.equalsExp(_db.symptomMetrics.symptomsId)),
    ])
      ..addColumns([_db.symptomMetrics.symptomsId, _db.symptoms.name, cnt])
      ..where(_db.symptomMetrics.deletedAt.isNull() &
          _db.symptomMetrics.date.isBiggerOrEqualValue(cutoff))
      ..groupBy([_db.symptomMetrics.symptomsId, _db.symptoms.name])
      ..orderBy([OrderingTerm(expression: cnt, mode: OrderingMode.desc)])
      ..limit(limit);

    final rows = await q.get();
    return rows
        .map((r) => SymsModel(
              id: r.read(_db.symptomMetrics.symptomsId),
              name: r.read(_db.symptoms.name),
              count: r.read(cnt),
            ))
        .toList();
  }
}

class SymsModel {
  final int? id;
  final String? name;
  final int? count;

  SymsModel({
    required this.id,
    required this.name,
    required this.count,
  });
}
