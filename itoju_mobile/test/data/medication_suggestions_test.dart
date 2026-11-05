import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itoju_mobile/data/db/app_database.dart';
import 'package:itoju_mobile/data/medication_suggestions.dart';
import 'package:itoju_mobile/data/models/medication_model.dart';
import 'package:itoju_mobile/data/repositories/medication_repository.dart';

MedicationModel med(String name, {int dosage = 0, String metric = 'mg'}) =>
    MedicationModel(
        id: null,
        time: '',
        metric: metric,
        name: name,
        dosage: dosage,
        quantity: 1);

void main() {
  group('filterMedSuggestions', () {
    final all = [
      med('Iron'),
      med('Paracetamol'),
      med('Vitamin D'),
      med('Ibuprofen')
    ];

    test('empty box shows the most recent ones', () {
      expect(filterMedSuggestions(all, '', max: 2).map((m) => m.name),
          ['Iron', 'Paracetamol']);
    });
    test('names starting with the text come before ones containing it', () {
      expect(filterMedSuggestions(all, 'i').map((m) => m.name),
          ['Iron', 'Ibuprofen', 'Vitamin D']);
    });
    test('ignores case and spacing', () {
      expect(filterMedSuggestions(all, ' PARA').map((m) => m.name),
          ['Paracetamol']);
    });
    test('hides once the name matches exactly', () {
      expect(filterMedSuggestions(all, 'iron '), isEmpty);
    });
  });

  test('merge keeps one per name, logged doses over reminder doses', () {
    final merged = mergeMedSuggestions(
        [med('Iron', dosage: 65), med('iron ', dosage: 10), med('')],
        [med('IRON', dosage: 200), med('Metformin', dosage: 500)]);
    expect(merged.map((m) => '${m.name}:${m.dosage}'),
        ['Iron:65', 'Metformin:500']);
    expect(medSuggestionLabel(merged.first), 'Iron 65 mg');
    expect(medSuggestionLabel(med('Iron')), 'Iron');
  });

  group('with a database', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('suggestions come from past entries and reminders, not deleted ones',
        () async {
      final repo = MedicationRepository(db);
      await repo.create('2026-11-01', med('Paracetamol', dosage: 500));
      await repo.create('2026-11-02', med('Iron', dosage: 65));
      await repo.create('2026-11-03', med('Aspirin', dosage: 75));
      final aspirin = (await repo.getForDate('2026-11-03')).single;
      await repo.delete(aspirin.id!);
      await db.into(db.medReminders).insert(MedRemindersCompanion.insert(
          id: 'r1',
          localUpdatedAt: DateTime(2026, 11, 4),
          name: 'Metformin',
          dosage: const Value(500)));

      final names = (await repo.suggestions()).map((m) => m.name).toList();
      expect(names, ['Iron', 'Paracetamol', 'Metformin']);
    });
  });
}
