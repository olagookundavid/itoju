class UrineModel {
  final String? id;
  final String? time;
  final List tags;
  final int type;
  final double pain;
  final double quantity;

  UrineModel({
    this.id,
    required this.time,
    required this.tags,
    required this.type,
    required this.pain,
    required this.quantity,
  });

  factory UrineModel.fromMap(Map<String, dynamic> data) {
    return UrineModel(
      id: data['id']?.toString() ?? '',
      time: data['time'] ?? '',
      type: (data['type'] as num).toInt(),
      pain: (data['pain'] as num).toDouble(),
      quantity: (data['quantity'] as num).toDouble(),
      tags: data['tags'] ?? const [],
    );
  }
}
