/// A smiley from the seeded catalog with the user's rolling count. `id` is the
/// catalog smiley id (server SERIAL); `count` is how many entries reference it
/// over the requested window.
class SmileyModel {
  final int? id;
  final String? name;
  final int? count;

  SmileyModel({
    required this.id,
    required this.name,
    required this.count,
  });

  factory SmileyModel.fromMap(Map<String, dynamic> data) {
    return SmileyModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      count: data['count'] ?? 0,
    );
  }

  @override
  String toString() => 'SmileyModel(id: $id, name: $name, count: $count)';
}

/// The most recent smiley entry for a day. `id` is the catalog smiley id (the
/// emote the user picked), `tags` are the free-form tags attached to it.
class LatestSmiley {
  final int? id;
  final List tags;

  LatestSmiley({
    required this.id,
    required this.tags,
  });

  factory LatestSmiley.fromMap(Map<String, dynamic> data) {
    return LatestSmiley(
      id: data['id'] ?? 0,
      tags: data['tags'] ?? [],
    );
  }
}

/// The full catalog of smileys with per-smiley counts plus the total across the
/// window (used to compute each smiley's share on the dashboard).
class SmileyCounts {
  final List<SmileyModel> smileys;
  final int totalCount;

  SmileyCounts(this.smileys, this.totalCount);
}
