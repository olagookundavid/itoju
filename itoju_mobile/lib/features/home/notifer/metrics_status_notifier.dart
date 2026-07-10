// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/data/models/metric_status_model.dart';
import 'package:itoju_mobile/data/repositories/metrics_status_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

// Re-export so existing consumers importing this file keep seeing the model.
export 'package:itoju_mobile/data/models/metric_status_model.dart';

final metricsStatusProvider =
    StateNotifierProvider<MetricsStatusNotifier, MetricsStatusState>((ref) {
  return MetricsStatusNotifier(ref, ref.read(metricsStatusRepositoryProvider));
});

class MetricsStatusNotifier extends StateNotifier<MetricsStatusState> {
  MetricsStatusNotifier(this.ref, this.repo)
      : super(MetricsStatusState.initial());
  Ref ref;
  MetricsStatusRepository repo;

  Future<void> getMetricsStatus(String date) async {
    state = state.copyWith(status: Loader.loading);
    try {
      final metricStatusModel = await repo.statusForDate(date);
      state = state.copyWith(
          status: Loader.loaded, metricStatusModel: metricStatusModel);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }
}

class MetricsStatusState {
  MetricStatusModel? metricStatusModel;
  Loader? status;

  MetricsStatusState({this.metricStatusModel, this.status = Loader.loading});
  factory MetricsStatusState.initial() {
    return MetricsStatusState();
  }

  MetricsStatusState copyWith(
      {MetricStatusModel? metricStatusModel, Loader? status, String? error}) {
    return MetricsStatusState(
        metricStatusModel: metricStatusModel ?? this.metricStatusModel,
        status: status ?? this.status);
  }
}
