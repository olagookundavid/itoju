class MetricStatusModel {
  final bool? symptoms;
  final bool? sleep;
  final bool? food;
  final bool? exercise;
  final bool? medication;
  final bool? urine;
  final bool? bowel;

  MetricStatusModel({
    required this.symptoms,
    required this.sleep,
    required this.food,
    required this.exercise,
    required this.medication,
    required this.urine,
    required this.bowel,
  });

  factory MetricStatusModel.fromMap(Map<String, dynamic> data) {
    return MetricStatusModel(
        symptoms: data['symptoms'] ?? false,
        sleep: data['sleep'] ?? false,
        exercise: data['exercise'] ?? false,
        food: data['food'] ?? false,
        urine: data['urine'] ?? false,
        bowel: data['bowel'] ?? false,
        medication: data['medication'] ?? false);
  }
}
