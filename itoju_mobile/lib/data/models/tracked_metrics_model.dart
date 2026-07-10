/// A tracked-metric option from the seeded catalog (server SERIAL id + name).
class MetricModel {
  final int? id;
  final String? name;

  MetricModel({
    required this.id,
    required this.name,
  });

  factory MetricModel.fromMap(Map<String, dynamic> data) {
    return MetricModel(id: data['id'] ?? 0, name: data['name'] ?? '');
  }
}

/// A user's selected tracked metric (catalog id + name). Structurally the same
/// as [MetricModel]; kept as a distinct type for the home surface.
class UserMetricsModel {
  final int? id;
  final String? name;

  UserMetricsModel({
    required this.id,
    required this.name,
  });

  factory UserMetricsModel.fromMap(Map<String, dynamic> data) {
    return UserMetricsModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
    );
  }
}
