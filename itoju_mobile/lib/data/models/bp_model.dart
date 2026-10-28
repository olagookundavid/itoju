import '../blood_pressure.dart';

class BpModel {
  final String? id;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm (24 h, sortable)
  final int systolic;
  final int diastolic;
  final int pulse;

  const BpModel({
    required this.id,
    required this.date,
    required this.time,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
  });

  BpCategory get category => classifyBp(systolic, diastolic);
}

/// One day on the trend chart: the average of that day's readings.
class BpDayPoint {
  final String date; // yyyy-MM-dd
  final double systolic;
  final double diastolic;
  final double pulse;
  final int readings;

  const BpDayPoint({
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.readings,
  });
}
