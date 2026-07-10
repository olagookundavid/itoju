class FoodMetricModel {
  final String? id;
  final String? breakfastMeal;
  final String? lunchMeal;
  final String? dinnerMeal;
  final String? breakfastExtra;
  final String? lunchExtra;
  final String? dinnerExtra;
  final String? breakfastFruit;
  final String? lunchFruit;
  final String? dinnerFruit;
  final String? snackName;
  final List? breakfastTags;
  final List? lunchTags;
  final List? dinnerTags;
  final List? snackTags;
  final int? glassNo;

  FoodMetricModel({
    required this.id,
    this.breakfastMeal,
    this.lunchMeal,
    this.dinnerMeal,
    this.breakfastExtra,
    this.lunchExtra,
    this.dinnerExtra,
    this.breakfastFruit,
    this.lunchFruit,
    this.dinnerFruit,
    this.snackName,
    this.breakfastTags,
    this.lunchTags,
    this.dinnerTags,
    this.snackTags,
    this.glassNo,
  });

  factory FoodMetricModel.fromMap(Map<String, dynamic> data) {
    return FoodMetricModel(
      id: data['id']?.toString() ?? '',
      breakfastExtra: data['breakfast_extra'] ?? '',
      breakfastTags: data['breakfast_tags'] ?? [],
      breakfastFruit: data['breakfast_fruit'] ?? '',
      breakfastMeal: data['breakfast_meal'] ?? '',
      dinnerExtra: data['dinner_extra'] ?? '',
      dinnerFruit: data['dinner_fruit'] ?? '',
      dinnerMeal: data['dinner_meal'] ?? '',
      dinnerTags: data['dinner_tags'] ?? [],
      glassNo: data['glass_no'] ?? 0,
      lunchExtra: data['lunch_extra'] ?? '',
      lunchFruit: data['lunch_fruit'] ?? '',
      lunchMeal: data['lunch_meal'] ?? '',
      lunchTags: data['lunch_tags'] ?? [],
      snackName: data['snack_name'] ?? '',
      snackTags: data['snack_tags'] ?? [],
    );
  }
}
