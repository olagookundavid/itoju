class MensesModel {
  final int? periodLen;
  final int? cycleLen;

  MensesModel({required this.periodLen, required this.cycleLen});

  factory MensesModel.fromMap(Map<String, dynamic> data) {
    return MensesModel(
      periodLen: data['period_len'] ?? 0,
      cycleLen: data['cycle_len'] ?? 0,
    );
  }
}

/// Height in centimetres and weight in kilograms, whatever unit the user sees.
class BodyDataModel {
  final double heightCm;
  final double weightKg;

  const BodyDataModel({required this.heightCm, required this.weightKg});
}
