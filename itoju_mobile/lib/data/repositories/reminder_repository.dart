import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../ids.dart';
import '../limits.dart';
import '../providers.dart';
import '../reminder_schedule.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepository(ref.watch(appDatabaseProvider)),
);

/// Local source of truth for medication reminders. Like every synced table:
/// writes mark the row pending and bump local_updated_at, deletes are soft.
/// The OS-level notifications are derived from these rows elsewhere.
class ReminderRepository {
  ReminderRepository(this._db);
  final AppDatabase _db;

  SimpleSelectStatement<$MedRemindersTable, MedReminder> _live() =>
      _db.select(_db.medReminders)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.name), (t) => OrderingTerm.asc(t.id)]);

  Stream<List<MedReminderModel>> watchAll() =>
      _live().watch().map((rows) => rows.map(_toModel).toList());

  Future<List<MedReminderModel>> getAll() async =>
      (await _live().get()).map(_toModel).toList();

  Future<MedReminderModel?> getById(String id) async {
    final row = await (_db.select(_db.medReminders)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Creates (id == null) or updates a reminder; returns its id. Throws
  /// [ArgumentError] with a user-facing message if it can't be saved.
  Future<String> save(MedReminderModel input) async {
    final r = _normalise(input);
    final others = (await getAll()).where((o) => o.id != r.id).toList();
    final problem = validateReminder(r, others: others);
    if (problem != null) throw ArgumentError(problem);

    final now = DateTime.now();
    if (r.id == null) {
      final id = IdMinter.v7();
      await _db.into(_db.medReminders).insert(MedRemindersCompanion.insert(
            id: id,
            localUpdatedAt: now,
            name: r.name,
            dosage: Value(r.dosage),
            unit: Value(r.unit),
            quantity: Value(r.quantity),
            days: Value(r.days),
            times: Value(r.times),
            enabled: Value(r.enabled),
            updatedAt: Value(now),
          ));
      return id;
    }
    await (_db.update(_db.medReminders)..where((t) => t.id.equals(r.id!))).write(
      MedRemindersCompanion(
        name: Value(r.name),
        dosage: Value(r.dosage),
        unit: Value(r.unit),
        quantity: Value(r.quantity),
        days: Value(r.days),
        times: Value(r.times),
        enabled: Value(r.enabled),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
    return r.id!;
  }

  /// Turning a reminder ON re-checks the OS notification limit; off never fails.
  Future<void> setEnabled(String id, bool enabled) async {
    final current = await getById(id);
    if (current == null) return;
    await save(current.copyWith(enabled: enabled));
  }

  Future<void> delete(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.medReminders)..where((t) => t.id.equals(id))).write(
      MedRemindersCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        localUpdatedAt: Value(now),
        syncState: const Value('pending'),
      ),
    );
  }

  /// Trims and bounds free text to the server's column sizes, and normalises times.
  MedReminderModel _normalise(MedReminderModel r) => r.copyWith(
        name: clipText(r.name.trim(), 100),
        unit: clipText(r.unit.trim().isEmpty ? 'mg' : r.unit.trim(), 16),
        dosage: clampSmallInt(r.dosage),
        quantity: r.quantity.clamp(1, 99),
        days: r.days & kAllDays,
        times: parsedTimes(r.times),
      );

  MedReminderModel _toModel(MedReminder r) => MedReminderModel(
        id: r.id,
        name: r.name,
        dosage: r.dosage,
        unit: r.unit,
        quantity: r.quantity,
        days: r.days & kAllDays,
        times: r.times,
        enabled: r.enabled,
      );
}
