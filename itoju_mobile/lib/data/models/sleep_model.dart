class SleepModel {
  final String? id;
  final String? timeSlept;
  final String? timeWokeUp;
  final List tags;
  final double severity;
  final bool? isNight;

  SleepModel({
    required this.id,
    required this.timeSlept,
    required this.timeWokeUp,
    required this.tags,
    required this.severity,
    required this.isNight,
  });

  factory SleepModel.fromMap(Map<String, dynamic> data) {
    return SleepModel(
      id: data['id']?.toString() ?? '',
      timeSlept: data['time_slept'] ?? '',
      timeWokeUp: data['time_woke_up'] ?? '',
      severity: (data['severity'] as num).toDouble(),
      tags: data['tags'] ?? const [],
      isNight: data['is_night'] ?? false,
    );
  }
}
