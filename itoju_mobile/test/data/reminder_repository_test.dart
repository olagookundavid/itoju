import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/reminder_actions.dart';
import 'package:itoju_mobile/data/reminder_schedule.dart';
import 'package:itoju_mobile/data/repositories/medication_repository.dart';
import 'package:itoju_mobile/data/repositories/reminder_repository.dart';

MedReminderModel draft({
  String name = 'Metformin',
  int dosage = 500,
  String unit = 'mg',
  int quantity = 1,
  int days = kAllDays,
  List<String> times = const ['08:00', '20:00'],
  bool enabled = true,
  String? id,
}) =>
    MedReminderModel(
        id: id,
        name: name,
        dosage: dosage,
        unit: unit,
        quantity: quantity,
        days: days,
        times: times,
        enabled: enabled);

void main() {
  late AppDatabase db;
  late ReminderRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ReminderRepository(db);
  });
  tearDown(() => db.close());

  group('ReminderRepository', () {
    test('a saved reminder round-trips and starts pending for sync', () async {
      final id = await repo.save(draft(days: 0x15, times: ['20:00', '08:00']));

      final r = (await repo.getById(id))!;
      expect(
          [r.name, r.dosage, r.unit, r.quantity], ['Metformin', 500, 'mg', 1]);
      expect(r.days, 0x15);
      expect(r.times, ['08:00', '20:00'], reason: 'stored sorted');
      expect(r.enabled, isTrue);
      final row = await db.select(db.medReminders).getSingle();
      expect(row.syncState, 'pending');
      expect(row.updatedAt, isNotNull);
    });

    test(
        'input is normalised: trimmed name, de-duplicated times, bounded numbers',
        () async {
      final id = await repo.save(draft(
          name: '  Ibuprofen  ',
          unit: '  ',
          quantity: 500,
          times: ['8:00', '08:00', '09:30']));
      final r = (await repo.getById(id))!;
      expect(r.name, 'Ibuprofen');
      expect(r.unit, 'mg', reason: 'a blank unit falls back to the default');
      expect(r.quantity, 99);
      expect(r.times, ['08:00', '09:30']);
    });

    test(
        'an invalid reminder is refused with a readable message and not stored',
        () async {
      await expectLater(
          repo.save(draft(name: '')),
          throwsA(isA<ArgumentError>()
              .having((e) => e.message, 'message', contains('name'))));
      await expectLater(
          repo.save(draft(days: 0)), throwsA(isA<ArgumentError>()));
      await expectLater(
          repo.save(draft(times: [])), throwsA(isA<ArgumentError>()));
      expect(await db.select(db.medReminders).get(), isEmpty);
    });

    test('update edits in place and re-marks the row pending', () async {
      final id = await repo.save(draft());
      await db
          .customStatement("UPDATE med_reminders SET sync_state = 'synced'");

      await repo.save(
          (await repo.getById(id))!.copyWith(times: ['07:00'], dosage: 850));

      expect(await db.select(db.medReminders).get(), hasLength(1));
      final r = (await repo.getById(id))!;
      expect([
        r.times,
        r.dosage
      ], [
        ['07:00'],
        850
      ]);
      expect(
          (await db.select(db.medReminders).getSingle()).syncState, 'pending');
    });

    test('delete is a soft delete (tombstone) and hides the reminder',
        () async {
      final id = await repo.save(draft());
      await db
          .customStatement("UPDATE med_reminders SET sync_state = 'synced'");

      await repo.delete(id);

      expect(await repo.getAll(), isEmpty);
      expect(await repo.getById(id), isNull);
      final row = await db.select(db.medReminders).getSingle();
      expect(row.deletedAt, isNotNull);
      expect(row.syncState, 'pending');
    });

    test('setEnabled toggles without touching anything else', () async {
      final id = await repo.save(draft());
      await repo.setEnabled(id, false);
      var r = (await repo.getById(id))!;
      expect(r.enabled, isFalse);
      expect([
        r.name,
        r.times
      ], [
        'Metformin',
        ['08:00', '20:00']
      ]);
      await repo.setEnabled(id, true);
      r = (await repo.getById(id))!;
      expect(r.enabled, isTrue);
    });

    test('the OS notification limit is enforced across reminders', () async {
      final six = ['06:00', '08:00', '10:00', '12:00', '14:00', '16:00'];
      await repo.save(draft(name: 'A', times: six)); // 42 slots
      await expectLater(repo.save(draft(name: 'B', times: six)),
          throwsA(isA<ArgumentError>()));

      // Saved switched off, it is fine - but it can't then be switched on.
      final id = await repo.save(draft(name: 'B', times: six, enabled: false));
      await expectLater(
          repo.setEnabled(id, true), throwsA(isA<ArgumentError>()));
      expect((await repo.getById(id))!.enabled, isFalse);
    });

    test('watchAll emits when reminders change, soft-deleted ones excluded',
        () async {
      final seen = <List<String>>[];
      final sub = repo
          .watchAll()
          .listen((l) => seen.add(l.map((r) => r.name).toList()));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final a = await repo.save(draft(name: 'Alpha'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await repo.save(draft(name: 'Beta'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await repo.delete(a);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      final asText = seen.map((l) => l.join(',')).toList();
      expect(asText.first, isEmpty);
      expect(asText, contains('Alpha,Beta'));
      expect(asText.last, 'Beta');
    });

    test('erasing user data also removes reminders', () async {
      await repo.save(draft());
      await db.eraseAllUserData();
      expect(await db.select(db.medReminders).get(), isEmpty);
    });
  });

  group('Mark as taken', () {
    test('logs a medication entry from the reminder, with points', () async {
      final id = await repo
          .save(draft(name: 'Metformin', dosage: 500, unit: 'mg', quantity: 2));

      final ok = await ReminderActions.markTaken(db, id,
          now: DateTime(2026, 10, 28, 8, 5));

      expect(ok, isTrue);
      final logged = await MedicationRepository(db).getForDate('2026-10-28');
      expect(logged, hasLength(1));
      expect([
        logged[0].name,
        logged[0].dosage,
        logged[0].metric,
        logged[0].quantity
      ], [
        'Metformin',
        500,
        'mg',
        2
      ]);
      expect(logged[0].time, contains('8:05'));
      final pts = await db.select(db.pointRecords).get();
      expect(pts.map((p) => [p.scope, p.point]), [
        ['Medication', 2]
      ]);
    });

    test(
        'does nothing if the reminder was deleted since the notification was scheduled',
        () async {
      final id = await repo.save(draft());
      await repo.delete(id);

      expect(await ReminderActions.markTaken(db, id), isFalse);
      expect(await db.select(db.medicationMetrics).get(), isEmpty);
      expect(await db.select(db.pointRecords).get(), isEmpty);
    });

    test('an unknown id is ignored', () async {
      expect(await ReminderActions.markTaken(db, 'nope'), isFalse);
    });
  });

  group('reminderTexts', () {
    test('shows the medication and dose by default', () {
      final t =
          reminderTexts(draft(name: ' Metformin ', dosage: 500, quantity: 2));
      expect(t.title, 'Time for Metformin');
      expect(t.body, '500 mg · take 2');
    });

    test('falls back to a generic body when there is no dose', () {
      expect(
          reminderTexts(draft(dosage: 0)).body, 'Time to take your medication');
    });

    test('private mode reveals nothing about the medication', () {
      final t =
          reminderTexts(draft(name: 'Metformin', dosage: 500), hideNames: true);
      expect('${t.title} ${t.body}', isNot(contains('Metformin')));
      expect('${t.title} ${t.body}', isNot(contains('500')));
    });
  });
}
