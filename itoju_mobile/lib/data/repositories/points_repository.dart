import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../db/app_database.dart';
import '../providers.dart';

final pointsRepositoryProvider = Provider<PointsRepository>(
  (ref) => PointsRepository(ref.watch(appDatabaseProvider)),
);

/// Local source of truth for the points display. Point rows are written by the
/// metric repositories on create (scope + point + date); here we only read and
/// aggregate them, mirroring the backend's points totals.
class PointsRepository {
  PointsRepository(this._db);
  final AppDatabase _db;

  /// total = SUM(point) over live rows; today = SUM where date == today;
  /// thisWeek = SUM where date >= Monday. Dates are ISO 'yyyy-MM-dd' so string
  /// comparison sorts correctly.
  Future<PointModel> getPoints() async {
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');
    final todayStr = fmt.format(now);
    final mondayStr = fmt.format(now.subtract(Duration(days: now.weekday - 1)));

    final sum = _db.pointRecords.point.sum();

    Future<int> sumWhere(Expression<bool> extra) async {
      final q = _db.selectOnly(_db.pointRecords)
        ..addColumns([sum])
        ..where(_db.pointRecords.deletedAt.isNull() & extra);
      return (await q.getSingle()).read(sum) ?? 0;
    }

    final total = await sumWhere(const Constant(true));
    final today = await sumWhere(_db.pointRecords.date.equals(todayStr));
    final week =
        await sumWhere(_db.pointRecords.date.isBiggerOrEqualValue(mondayStr));

    return PointModel(total, today, week);
  }
}

class PointModel {
  final int totalPts;
  final int todayPts;
  final int weekPts;

  PointModel(this.totalPts, this.todayPts, this.weekPts);
}
