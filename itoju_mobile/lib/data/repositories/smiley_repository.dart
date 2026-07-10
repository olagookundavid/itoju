import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../db/app_database.dart';
import '../ids.dart';
import '../models/smiley_model.dart';
import '../providers.dart';

final smileyRepositoryProvider = Provider<SmileyRepository>(
  (ref) => SmileyRepository(ref.watch(appDatabaseProvider)),
);

/// Local source of truth for mood smileys. Every write marks the row
/// sync_state=pending and bumps local_updated_at so the SyncEngine can find it;
/// deletes are soft (tombstones). No network here — the app works fully offline.
/// Unlike the tracked metrics, smileys award no points.
class SmileyRepository {
  SmileyRepository(this._db);
  final AppDatabase _db;

  static const _dayFormat = 'yyyy-MM-dd';

  Future<void> addSmiley(int smileyId, List<String> tags, String date) async {
    final now = DateTime.now();
    await _db.into(_db.smileyEntries).insert(SmileyEntriesCompanion.insert(
          id: IdMinter.v7(),
          localUpdatedAt: now,
          smileyId: smileyId,
          grantedAt: now,
          tags: Value(List<String>.from(tags)),
          updatedAt: Value(now),
        ));
  }

  /// The latest live smiley entry granted on [date] (a 'yyyy-MM-dd' string), or
  /// null if none. grantedAt carries a timestamp, so the day is matched in Dart.
  Future<LatestSmiley?> getLatestForDate(String date) async {
    final rows = await (_db.select(_db.smileyEntries)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.grantedAt, mode: OrderingMode.desc),
          ]))
        .get();
    for (final r in rows) {
      if (DateFormat(_dayFormat).format(r.grantedAt) == date) {
        return LatestSmiley(id: r.smileyId, tags: List<String>.from(r.tags));
      }
    }
    return null;
  }

  /// Counts of live smiley entries granted within the last [days] days, grouped
  /// by smiley. All catalog smileys are included (missing ones backfilled to 0)
  /// so consumers can index by id safely; also returns the grand total.
  Future<SmileyCounts> countsForLastDays(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));

    final cnt = _db.smileyEntries.id.count();
    final q = _db.selectOnly(_db.smileyEntries).join([
      leftOuterJoin(_db.smileyCatalog,
          _db.smileyCatalog.id.equalsExp(_db.smileyEntries.smileyId)),
    ])
      ..addColumns([_db.smileyEntries.smileyId, _db.smileyCatalog.name, cnt])
      ..where(_db.smileyEntries.deletedAt.isNull() &
          _db.smileyEntries.grantedAt.isBiggerOrEqualValue(cutoff))
      ..groupBy([_db.smileyEntries.smileyId, _db.smileyCatalog.name]);
    final rows = await q.get();

    final counts = <int, int>{};
    var total = 0;
    for (final row in rows) {
      final id = row.read(_db.smileyEntries.smileyId);
      final c = row.read(cnt) ?? 0;
      if (id != null) counts[id] = c;
      total += c;
    }

    final catalog = await (_db.select(_db.smileyCatalog)
          ..orderBy([(t) => OrderingTerm(expression: t.id)]))
        .get();
    final smileys = catalog
        .map((cat) => SmileyModel(
              id: cat.id,
              name: cat.name,
              count: counts[cat.id] ?? 0,
            ))
        .toList();

    return SmileyCounts(smileys, total);
  }
}
