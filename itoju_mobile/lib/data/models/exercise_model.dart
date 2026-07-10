class ExerciseModel {
  final String? id;
  final int? noOfTimes;
  final String? name;
  final String? started;
  final String? ended;
  final List? tags;

  ExerciseModel({
    this.id,
    this.name,
    this.tags,
    this.noOfTimes,
    this.started,
    this.ended,
  });

  factory ExerciseModel.fromMap(Map<String, dynamic> data) {
    return ExerciseModel(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? '',
      tags: data['tags'] ?? const [],
      noOfTimes: (data['no_of_times'] as num?)?.toInt() ?? 0,
      started: data['start'] ?? '',
      ended: data['ended'] ?? '',
    );
  }
}
