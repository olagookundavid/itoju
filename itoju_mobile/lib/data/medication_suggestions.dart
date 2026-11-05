/// Pure helpers behind the medication name suggestions: no database, no Flutter.
library;

import 'models/medication_model.dart';

String _key(String name) => name.trim().toLowerCase();

/// One suggestion per medication name (case and spacing ignored), keeping the
/// first occurrence. [logged] (newest first) wins over [reminders], so a pick
/// fills in the dose the person last actually took.
List<MedicationModel> mergeMedSuggestions(
    List<MedicationModel> logged, List<MedicationModel> reminders) {
  final seen = <String>{};
  final out = <MedicationModel>[];
  for (final m in [...logged, ...reminders]) {
    final k = _key(m.name);
    if (k.isEmpty || !seen.add(k)) continue;
    out.add(m);
  }
  return out;
}

/// The suggestions to show while [typed] is in the name box: all of them
/// (most recent first) when it's empty, otherwise names containing it, with
/// names that start with it first. Nothing once the name matches one exactly,
/// since there's nothing left to complete.
List<MedicationModel> filterMedSuggestions(
    List<MedicationModel> all, String typed,
    {int max = 6}) {
  final q = _key(typed);
  if (q.isEmpty) return all.take(max).toList();
  if (all.any((m) => _key(m.name) == q)) return const [];
  final starts = all.where((m) => _key(m.name).startsWith(q));
  final contains =
      all.where((m) => !_key(m.name).startsWith(q) && _key(m.name).contains(q));
  return [...starts, ...contains].take(max).toList();
}

/// "Iron 65 mg" style label; the name alone when no dose was recorded.
String medSuggestionLabel(MedicationModel m) {
  final name = m.name.trim();
  if (m.dosage <= 0) return name;
  return '$name ${m.dosage} ${m.metric}'.trim();
}
