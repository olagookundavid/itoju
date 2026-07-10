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

class BodyDataModel {
  final int? height;
  final int? weight;

  BodyDataModel({required this.height, required this.weight});

  factory BodyDataModel.fromMap(Map<String, dynamic> data) {
    return BodyDataModel(
      height: data['height'] ?? 0,
      weight: data['weight'] ?? 0,
    );
  }
}
