import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../blood_pressure.dart';
import '../db/app_database.dart';
import '../models/today_summary.dart';
import '../providers.dart';
import '../reminder_schedule.dart';
import '../today_logic.dart';

final todayRepositoryProvider = Provider<TodayRepository>(
  (ref) => TodayRepository(ref.watch(appDatabaseProvider)),
);

/// Live per-day summary for the Home screen: one headline per tracked metric,
/// computed from the same local tables the entry pages write to. A stream, so a
/// box updates the moment something is logged — no manual refresh.
class TodayRepository {
  TodayRepository(this._db);
  final AppDatabase _db;

  static final _day = DateFormat('yyyy-MM-dd');
  static const _unlogged = 'Tap to log';

  /// Emits now, then again whenever any table feeding the summary changes.
  ///
  /// Built on a StreamController rather than an `async*` generator: cancelling a
  /// generator that is parked inside `await for` does not complete until the next
  /// database change, which would leak a listener every time a screen closes.
  Stream<TodaySummary> watch(String date, {DateTime? now}) {
    late final StreamController<TodaySummary> controller;
    StreamSubscription<Set<TableUpdate>>? subscription;
    var closed = false;
    var computing = false;
    var dirty = false;

    // One computation at a time; changes that arrive meanwhile trigger exactly
    // one more run afterwards, so a burst of writes costs two summaries, not N.
    Future<void> emit() async {
      if (computing) {
        dirty = true;
        return;
      }
      computing = true;
      try {
        do {
          dirty = false;
          final value = await summary(date, now: now);
          if (!closed) controller.add(value);
        } while (dirty && !closed);
      } catch (e, st) {
        if (!closed) controller.addError(e, st);
      } finally {
        computing = false;
      }
    }

    controller = StreamController<TodaySummary>(
      onListen: () {
        subscription = _db
            .tableUpdates(TableUpdateQuery.onAllTables([
              _db.symptomMetrics,
              _db.foodMetrics,
              _db.sleepMetrics,
              _db.medicationMetrics,
              _db.exerciseMetrics,
              _db.urineMetrics,
              _db.bowelMetrics,
              _db.bpMetrics,
              _db.smileyEntries,
              _db.cycleDays,
              _db.menstrualCycles,
              _db.medReminders,
            ]))
            .listen((_) => emit());
        emit();
      },
      onCancel: () {
        closed = true;
        return subscription?.cancel();
      },
    );
    return controller.stream;
  }

  Future<TodaySummary> summary(String date, {DateTime? now}) async {
    final clock = now ?? DateTime.now();
    return TodaySummary(
      date: date,
      metrics: {
        'Food Diary': await _food(date),
        'Symptoms': await _symptoms(date),
        'Sleep': await _sleep(date),
        'Menstruation and Ovulation': await _menstruation(date),
        'Bowel Movements': await _bowel(date),
        'Medications': await _medications(date, clock),
        'Urination': await _urine(date),
        'Exercise': await _exercise(date),
        'Blood Pressure': await _bloodPressure(date, clock),
      },
      streak: await _streak(clock),
      moodId: await _mood(date),
    );
  }

  // --- per metric ---

  Future<MetricToday> _food(String date) async {
    final rows = await (_db.select(_db.foodMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull()))
        .get();
    var meals = 0, glasses = 0;
    for (final r in rows) {
      for (final m in [r.breakfastMeal, r.lunchMeal, r.dinnerMeal, r.snackName]) {
        if (m.trim().isNotEmpty) meals++;
      }
      glasses += r.glassNo;
    }
    if (meals == 0 && glasses == 0) return const MetricToday(logged: false, headline: _unlogged);
    return MetricToday(
      logged: true,
      headline: meals > 0 ? plural(meals, 'meal') : plural(glasses, 'glass', 'glasses'),
      detail: meals > 0 && glasses > 0 ? '${plural(glasses, 'glass', 'glasses')} of water' : null,
    );
  }

  Future<MetricToday> _symptoms(String date) async {
    final rows = await (_db.select(_db.symptomMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull()))
        .get();
    if (rows.isEmpty) return const MetricToday(logged: false, headline: _unlogged);
    return MetricToday(
        logged: true, headline: plural(rows.map((r) => r.symptomsId).toSet().length, 'symptom'));
  }

  Future<MetricToday> _sleep(String date) async {
    final rows = await (_db.select(_db.sleepMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull()))
        .get();
    if (rows.isEmpty) return const MetricToday(logged: false, headline: _unlogged);
    var minutes = 0;
    for (final r in rows) {
      minutes += sleepMinutes(r.timeSlept, r.timeWokeUp) ?? 0;
    }
    return MetricToday(
      logged: true,
      headline: minutes > 0 ? formatDuration(minutes) : plural(rows.length, 'entry', 'entries'),
      detail: minutes > 0 && rows.length > 1 ? plural(rows.length, 'sleep', 'sleeps') : null,
    );
  }

  Future<MetricToday> _bowel(String date) async {
    final n = await _count(_db.bowelMetrics, date);
    return n == 0
        ? const MetricToday(logged: false, headline: _unlogged)
        : MetricToday(logged: true, headline: plural(n, 'movement'));
  }

  Future<MetricToday> _urine(String date) async {
    final n = await _count(_db.urineMetrics, date);
    return n == 0
        ? const MetricToday(logged: false, headline: _unlogged)
        : MetricToday(logged: true, headline: plural(n, 'time'));
  }

  Future<MetricToday> _exercise(String date) async {
    final rows = await (_db.select(_db.exerciseMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull()))
        .get();
    if (rows.isEmpty) return const MetricToday(logged: false, headline: _unlogged);
    final first = rows.first.name.trim();
    return MetricToday(
      logged: true,
      headline: plural(rows.length, 'activity', 'activities'),
      detail: first.isEmpty ? null : first,
    );
  }

  Future<MetricToday> _medications(String date, DateTime now) async {
    final taken = await _count(_db.medicationMetrics, date);
    final next = await _nextReminder(now);
    final nextText = next == null ? null : 'Next reminder $next';
    if (taken == 0) {
      return MetricToday(logged: false, headline: _unlogged, detail: nextText);
    }
    return MetricToday(logged: true, headline: '$taken taken', detail: nextText);
  }

  /// The next enabled reminder time later today, formatted for display, or null.
  Future<String?> _nextReminder(DateTime now) async {
    final rows = await (_db.select(_db.medReminders)
          ..where((t) => t.deletedAt.isNull() & t.enabled.equals(true)))
        .get();
    final reminders = rows
        .map((r) => MedReminderModel(
            id: r.id, name: r.name, days: r.days, times: r.times, enabled: r.enabled))
        .toList();
    final nowMinutes = now.hour * 60 + now.minute;
    ReminderSlot? best;
    for (final s in buildSlots(reminders)) {
      if (s.weekday != now.weekday) continue;
      final m = s.hour * 60 + s.minute;
      if (m <= nowMinutes) continue;
      if (best == null || m < best.hour * 60 + best.minute) best = s;
    }
    if (best == null) return null;
    return DateFormat.jm().format(DateTime(2000, 1, 1, best.hour, best.minute));
  }

  Future<MetricToday> _bloodPressure(String date, DateTime now) async {
    final today = await (_db.select(_db.bpMetrics)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.time)])
          ..limit(1))
        .getSingleOrNull();
    if (today != null) {
      return MetricToday(
        logged: true,
        headline: '${today.systolic}/${today.diastolic}',
        detail: '${today.pulse} bpm · ${classifyBp(today.systolic, today.diastolic).label}',
      );
    }
    final last = await (_db.select(_db.bpMetrics)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.date), (t) => OrderingTerm.desc(t.time)])
          ..limit(1))
        .getSingleOrNull();
    return MetricToday(
      logged: false,
      headline: _unlogged,
      detail: last == null
          ? null
          : 'Last ${last.systolic}/${last.diastolic}, ${relativeDay(last.date, now)}',
    );
  }

  /// Menstruation is informational rather than a daily to-do: it says where the
  /// person is in their cycle. "logged" means a cycle covers the day.
  Future<MetricToday> _menstruation(String date) async {
    final target = DateTime.tryParse(date);
    if (target == null) return const MetricToday(logged: false, headline: _unlogged);

    final days = await (_db.select(_db.cycleDays)
          ..where((t) => t.date.equals(date) & t.deletedAt.isNull()))
        .get();
    final cycles = await (_db.select(_db.menstrualCycles)
          ..where((t) => t.deletedAt.isNull() & t.startDate.isSmallerOrEqualValue(date))
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .get();
    if (cycles.isEmpty) {
      return const MetricToday(logged: false, headline: _unlogged, detail: 'Log your period');
    }

    int dayOf(MenstrualCycle c) {
      final s = DateTime.parse(c.startDate);
      return DateTime(target.year, target.month, target.day)
              .difference(DateTime(s.year, s.month, s.day))
              .inDays +
          1;
    }

    // Prefer the most recent cycle that has a day row for today (overlapping cycles).
    final byId = {for (final c in cycles) c.id: c};
    final todayRow = days
        .where((d) => byId.containsKey(d.cycleId))
        .fold<CycleDay?>(null, (best, d) {
      if (best == null) return d;
      return byId[d.cycleId]!.startDate.compareTo(byId[best.cycleId]!.startDate) > 0 ? d : best;
    });
    if (todayRow != null) {
      final n = dayOf(byId[todayRow.cycleId]!);
      if (todayRow.isPeriod) {
        return MetricToday(logged: true, headline: 'Period day $n', detail: 'Cycle day $n');
      }
      if (todayRow.isOvulation) {
        return MetricToday(logged: true, headline: 'Fertile window', detail: 'Cycle day $n');
      }
      return MetricToday(logged: true, headline: 'Cycle day $n');
    }
    final n = dayOf(cycles.first);
    if (n > 60) return const MetricToday(logged: false, headline: _unlogged, detail: 'Log your period');
    return MetricToday(logged: true, headline: 'Cycle day $n');
  }

  Future<int?> _mood(String date) async {
    final rows = await (_db.select(_db.smileyEntries)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.grantedAt)]))
        .get();
    for (final r in rows) {
      if (_day.format(r.grantedAt) == date) return r.smileyId;
    }
    return null;
  }

  Future<int> _streak(DateTime today) async {
    final rows = await _db.customSelect('''
      SELECT DISTINCT date FROM (
        SELECT date FROM symptom_metrics    WHERE deleted_at IS NULL UNION
        SELECT date FROM food_metrics       WHERE deleted_at IS NULL UNION
        SELECT date FROM sleep_metrics      WHERE deleted_at IS NULL UNION
        SELECT date FROM medication_metrics WHERE deleted_at IS NULL UNION
        SELECT date FROM exercise_metrics   WHERE deleted_at IS NULL UNION
        SELECT date FROM urine_metrics      WHERE deleted_at IS NULL UNION
        SELECT date FROM bowel_metrics      WHERE deleted_at IS NULL UNION
        SELECT date FROM bp_metrics         WHERE deleted_at IS NULL
      ) ORDER BY date DESC LIMIT 400
    ''').get();
    return computeStreak(rows.map((r) => r.read<String>('date')).toSet(), today);
  }

  /// Live rows for [date] in a table that has `date` and `deleted_at`.
  Future<int> _count(TableInfo<Table, dynamic> table, String date) async {
    final rows = await _db
        .customSelect(
          'SELECT count(*) AS n FROM ${table.actualTableName} WHERE date = ?1 AND deleted_at IS NULL',
          variables: [Variable<String>(date)],
          readsFrom: {table},
        )
        .getSingle();
    return rows.read<int>('n');
  }
}
