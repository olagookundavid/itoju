/// A symptom from the seeded catalog (server SERIAL id + name).
class SymptomsModel {
  final int? id;
  final String? name;

  SymptomsModel(this.id, this.name);

  factory SymptomsModel.fromMap(Map<String, dynamic> data) {
    return SymptomsModel(data['id'] ?? 0, data['name'] ?? '');
  }
}

/// A user's logged symptom for a day. `id` is the row's client UUID (deterministic
/// v5 of account + symptom + date); `name` is joined from the catalog.
class SymptomsMetricModel {
  final String? id;
  final String? name;
  final double? morningSeverity;
  final double? afternoonSeverity;
  final double? nightSeverity;

  SymptomsMetricModel(
    this.id,
    this.name,
    this.morningSeverity,
    this.afternoonSeverity,
    this.nightSeverity,
  );

  factory SymptomsMetricModel.fromMap(Map<String, dynamic> data) {
    return SymptomsMetricModel(
      data['id']?.toString() ?? '',
      data['name'] ?? '',
      (data['morning_severity'] ?? 0).toDouble(),
      (data['afternoon_severity'] ?? 0).toDouble(),
      (data['night_severity'] ?? 0).toDouble(),
    );
  }
}
