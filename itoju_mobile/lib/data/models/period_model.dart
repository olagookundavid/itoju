import 'package:intl/intl.dart';

/// A single cycle day (a row of cycles_days). `id` is the day's client UUID and
/// `cycleId` is its parent menstrual cycle.
class PeriodModel {
  final String id;
  final String cycleId;
  final String date;
  final bool isPeriod;
  final bool isOvulation;
  final num flow;
  final num pain;
  final List tags;
  final String cmq;

  PeriodModel({
    required this.id,
    required this.cycleId,
    required this.date,
    required this.isPeriod,
    required this.isOvulation,
    required this.flow,
    required this.pain,
    required this.tags,
    required this.cmq,
  });

  factory PeriodModel.fromMap(Map<String, dynamic> map) {
    final rawDate = (map['date'] ?? '').toString();
    return PeriodModel(
      id: map['id']?.toString() ?? '',
      cycleId: map['cycle_id']?.toString() ?? '',
      date: rawDate.isEmpty
          ? ''
          : DateFormat('yyyy-MM-dd').format(DateTime.parse(rawDate)),
      isPeriod: map['is_period'] ?? false,
      isOvulation: map['is_ovulation'] ?? false,
      flow: map['flow'] ?? 0,
      pain: map['pain'] ?? 0,
      tags: map['tags'] ?? [],
      cmq: map['cmq'] ?? '',
    );
  }
}
