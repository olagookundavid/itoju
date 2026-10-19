import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../account_service.dart';
import '../db/app_database.dart';
import '../limits.dart';
import '../cycle_math.dart';
import '../ids.dart';
import '../models/period_model.dart';
import '../providers.dart';

final mensesRepositoryProvider = Provider<MensesRepository>(
  (ref) => MensesRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(accountServiceProvider),
  ),
);

/// Local source of truth for menstrual cycles + their generated day rows.
/// A cycle's id is deterministic (account + start date); its day rows are minted
/// v7 and generated from the cycle/period lengths, mirroring the backend layout:
///   [0, periodLen)            -> period days
///   ovulationWindow(...)      -> fertile-window days (see cycle_math.dart)
///   everything else           -> regular days
class MensesRepository {
  MensesRepository(this._db, this._account);
  final AppDatabase _db;
  final AccountService _account;

  /// Cycle days whose date falls within [fromIso, toIso] inclusive (both
  /// 'yyyy-MM-dd' strings). Powers the calendar's lazy, per-visible-month load:
  /// instead of only ever showing the 3 most recent cycles, the page queries
  /// just the range it's displaying as the user pages through months.
  Future<List<PeriodModel>> getDaysInRange(String fromIso, String toIso) async {
    final days = await (_db.select(_db.cycleDays)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.date.isBiggerOrEqualValue(fromIso) &
              t.date.isSmallerOrEqualValue(toIso))
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();
    return days.map(_toModel).toList();
  }

  /// Days of the 3 most recent cycles (mirrors GetRecentCycleDays).
  Future<List<PeriodModel>> getRecentDays() async {
    final cycles = await (_db.select(_db.menstrualCycles)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.startDate, mode: OrderingMode.desc)
          ])
          ..limit(3))
        .get();
    final ids = cycles.map((c) => c.id).toList();
    if (ids.isEmpty) return [];
    final days = await (_db.select(_db.cycleDays)
          ..where((t) => t.cycleId.isIn(ids) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();
    return days.map(_toModel).toList();
  }

  /// Creates a cycle and its days. Returns false if a live cycle already exists
  /// for that start date; revives a tombstoned one (keeping its days) instead of
  /// regenerating.
  Future<bool> createCycle(String startDate, int cycleLen, int periodLen) async {
    // One row is generated per day of the cycle, so bound it. The UI validates
    // first and shows a message; this is the backstop for any other caller.
    if (cycleLen < 1 ||
        cycleLen > kMaxCycleLength ||
        periodLen < 1 ||
        periodLen > cycleLen) {
      throw ArgumentError(
          'invalid cycle: length=$cycleLen period=$periodLen (period must be 1..cycle, cycle at most $kMaxCycleLength)');
    }
    final account = await _account.deterministicNamespaceId();
    final cycleId = IdMinter.cycle(account, startDate);
    final now = DateTime.now();

    final existing = await (_db.select(_db.menstrualCycles)
          ..where((t) => t.id.equals(cycleId)))
        .getSingleOrNull();
    if (existing != null && existing.deletedAt == null) return false;

    await _db.transaction(() async {
      if (existing != null) {
        await (_db.update(_db.menstrualCycles)
              ..where((t) => t.id.equals(cycleId)))
            .write(MenstrualCyclesCompanion(
          deletedAt: const Value(null),
          cycleLength: Value(cycleLen),
          periodLength: Value(periodLen),
          updatedAt: Value(now),
          localUpdatedAt: Value(now),
          syncState: const Value('pending'),
        ));
        await (_db.update(_db.cycleDays)
              ..where((t) => t.cycleId.equals(cycleId)))
            .write(CycleDaysCompanion(
          deletedAt: const Value(null),
          updatedAt: Value(now),
          localUpdatedAt: Value(now),
          syncState: const Value('pending'),
        ));
        return;
      }

      await _db.into(_db.menstrualCycles).insert(MenstrualCyclesCompanion.insert(
            id: cycleId,
            localUpdatedAt: now,
            startDate: startDate,
            cycleLength: Value(cycleLen),
            periodLength: Value(periodLen),
            updatedAt: Value(now),
          ));

      final start = DateTime.parse(startDate);
      final window = ovulationWindow(periodLen, cycleLen);
      for (var i = 0; i < cycleLen; i++) {
        final ds = DateFormat('yyyy-MM-dd').format(start.add(Duration(days: i)));
        // Deterministic per (account, cycle, date) so a second device — or the
        // server generating the same cycle — mints the identical id and the
        // rows merge instead of duplicating.
        await _db.into(_db.cycleDays).insert(
              CycleDaysCompanion.insert(
                id: IdMinter.cycleDay(account, cycleId, ds),
                localUpdatedAt: now,
                cycleId: cycleId,
                date: ds,
                isPeriod: Value(i < periodLen),
                isOvulation: Value(window != null &&
                    i >= window.start &&
                    i <= window.end),
                updatedAt: Value(now),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
    });
    return true;
  }

  Future<void> updateDay(PeriodModel m) async {
    final now = DateTime.now();
    await (_db.update(_db.cycleDays)
          ..where((t) => t.id.equals(m.id) & t.deletedAt.isNull()))
        .write(CycleDaysCompanion(
      isPeriod: Value(m.isPeriod),
      isOvulation: Value(m.isOvulation),
      flow: Value(clampUnit(m.flow.toDouble())),
      pain: Value(clampUnit(m.pain.toDouble())),
      cmq: Value(m.cmq),
      tags: Value(List<String>.from(m.tags)),
      updatedAt: Value(now),
      localUpdatedAt: Value(now),
      syncState: const Value('pending'),
    ));
  }

  /// Soft-deletes a cycle and all its day rows (mirrors DeleteMenstrualCycle).
  Future<void> deleteCycle(String cycleId) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.cycleDays)
            ..where((t) => t.cycleId.equals(cycleId)))
          .write(CycleDaysCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncState: const Value('pending'),
      ));
      await (_db.update(_db.menstrualCycles)
            ..where((t) => t.id.equals(cycleId)))
          .write(MenstrualCyclesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncState: const Value('pending'),
      ));
    });
  }

  PeriodModel _toModel(CycleDay r) => PeriodModel(
        id: r.id,
        cycleId: r.cycleId,
        date: r.date,
        isPeriod: r.isPeriod,
        isOvulation: r.isOvulation,
        flow: r.flow,
        pain: r.pain,
        tags: r.tags,
        cmq: r.cmq,
      );
}
