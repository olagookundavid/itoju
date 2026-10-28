import 'package:flutter/material.dart';
import 'package:itoju_mobile/features/metrics/pages/blood_pressure.dart';
import 'package:itoju_mobile/features/metrics/pages/bowel_movements.dart';
import 'package:itoju_mobile/features/metrics/pages/exercise.dart';
import 'package:itoju_mobile/features/metrics/pages/food_metric.dart';
import 'package:itoju_mobile/features/metrics/pages/medication.dart';
import 'package:itoju_mobile/features/metrics/pages/sleep.dart';
import 'package:itoju_mobile/features/metrics/pages/symptoms.dart';
import 'package:itoju_mobile/features/metrics/pages/urination.dart';

/// Everything the UI needs to know about one trackable metric, keyed by its
/// catalog name. Shared by the middle tab and the Home boxes so the two can't
/// disagree about icons, colours or which page logging opens.
class MetricDef {
  const MetricDef(this.name, this.icon, this.color, [this.pageFor]);

  /// Catalog name, e.g. 'Food Diary'.
  final String name;

  /// asset/svg/<icon>.svg
  final String icon;

  /// Pastel background of a box once the metric has been logged today.
  final Color color;

  /// The entry page for a date. Null for Menstruation, which lives in the
  /// Calendar tab rather than on its own page.
  final Widget Function(DateTime date)? pageFor;

  bool get opensCalendar => pageFor == null;
}

const String kMenstruationMetric = 'Menstruation and Ovulation';

final Map<String, MetricDef> kMetricDefs = {
  for (final d in const [
    MetricDef('Food Diary', 'food_diary', Color(0xffFFF8E5), FoodMetric.new),
    MetricDef('Symptoms', 'cough', Color(0xffEDF7F8), SymptomsPage.new),
    MetricDef('Sleep', 'sleep', Color(0xffF5EFF5), SleepWidget.new),
    MetricDef(kMenstruationMetric, 'blood', Color(0xffFFEAE6)),
    MetricDef('Bowel Movements', 'bowel', Color(0xffEDF7F8), BowelMovement.new),
    MetricDef('Medications', 'drug', Color(0xffFFF8E5), MedicationMovement.new),
    MetricDef('Urination', 'bladder', Color(0xffFFEAE6), UrineMovement.new),
    MetricDef('Exercise', 'meditation', Color(0xffEBF9EE), ExercisePage.new),
    MetricDef('Blood Pressure', 'bp', Color(0xffFFEAE6), BloodPressurePage.new),
  ])
    d.name: d,
};
