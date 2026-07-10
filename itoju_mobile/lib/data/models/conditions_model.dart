/// A condition option from the seeded catalog (server SERIAL id + name), also
/// used to represent a user's selected condition (catalog id + name).
class GetConditionsModel {
  final int? id;
  final String? name;

  GetConditionsModel({
    required this.id,
    required this.name,
  });

  factory GetConditionsModel.fromMap(Map<String, dynamic> data) {
    return GetConditionsModel(id: data['id'] ?? 0, name: data['name'] ?? '');
  }
}
