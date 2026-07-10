class BowelModel {
  final String? id;
  final String? time;
  final List tags;
  final int type;
  final double pain;

  BowelModel({
    this.id,
    required this.time,
    required this.tags,
    required this.type,
    required this.pain,
  });

  factory BowelModel.fromMap(Map<String, dynamic> data) {
    return BowelModel(
      id: data['id']?.toString() ?? '',
      time: data['time'] ?? '',
      type: (data['type'] as num).toInt(),
      pain: (data['pain'] as num).toDouble(),
      tags: data['tags'] ?? const [],
    );
  }
}
