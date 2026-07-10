class MedicationModel {
  final String? id;
  final String time;
  final String metric;
  final String name;
  final int dosage;
  final int quantity;
  MedicationModel({
    required this.id,
    required this.time,
    required this.metric,
    required this.name,
    required this.dosage,
    required this.quantity,
  });

  factory MedicationModel.fromMap(Map<String, dynamic> data) {
    return MedicationModel(
      id: data['id']?.toString() ?? '',
      time: data['time'] ?? '',
      metric: data['metric'] ?? '',
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? 0,
      quantity: data['quantity'] ?? 0,
    );
  }
}
