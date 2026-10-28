import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/data/models/today_summary.dart';
import 'package:itoju_mobile/data/models/tracked_metrics_model.dart';
import 'package:itoju_mobile/data/repositories/today_repository.dart';
import 'package:itoju_mobile/data/repositories/tracked_metrics_repository.dart';

export 'package:itoju_mobile/data/models/today_summary.dart';

String todayKey([DateTime? now]) => DateFormat('yyyy-MM-dd').format(now ?? DateTime.now());

/// The calendar day the Home screen is showing. The screen bumps this when the
/// app resumes after midnight, so "today" never goes stale.
final todayKeyProvider = StateProvider<String>((ref) => todayKey());

/// Live summary of today: updates the moment anything is logged.
final todaySummaryProvider = StreamProvider.autoDispose<TodaySummary>((ref) {
  final date = ref.watch(todayKeyProvider);
  return ref.watch(todayRepositoryProvider).watch(date);
});

/// The metrics the person tracks, live, in catalog order.
final selectedMetricsProvider = StreamProvider.autoDispose<List<MetricModel>>(
    (ref) => ref.watch(trackedMetricsRepositoryProvider).watchSelected());
