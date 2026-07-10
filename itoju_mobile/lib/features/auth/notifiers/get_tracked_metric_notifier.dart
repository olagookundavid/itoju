import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/data/models/tracked_metrics_model.dart';
import 'package:itoju_mobile/data/repositories/tracked_metrics_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

export 'package:itoju_mobile/data/models/tracked_metrics_model.dart';

final metricProvider =
    StateNotifierProvider.autoDispose<MetricNotifier, MetricState>((ref) {
  return MetricNotifier(ref, ref.read(trackedMetricsRepositoryProvider));
});

/// Offline-first tracked-metrics notifier. Same public surface; the catalog now
/// comes from the seeded local table and selections from the local Drift store.
class MetricNotifier extends StateNotifier<MetricState> {
  MetricNotifier(this.ref, this.repo) : super(MetricState.initial());
  Ref ref;
  TrackedMetricsRepository repo;

  Future<void> getMetric() async {
    state = state.copyWith(status: Loader.loading);
    try {
      final metricLists = await repo.getCatalog();
      state = state.copyWith(status: Loader.loaded, metricLists: metricLists);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<void> getUserMetric() async {
    state = state.copyWith(status: Loader.loading);
    try {
      final userMetricLists = await repo.getSelected();
      state = state.copyWith(
          status: Loader.loaded, userMetricLists: userMetricLists);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }
}

class MetricState {
  List<MetricModel>? metricLists;
  List<MetricModel>? userMetricLists;
  Loader? status;
  String? error;

  MetricState(
      {this.metricLists,
      this.userMetricLists,
      this.status = Loader.loading,
      this.error});
  factory MetricState.initial() {
    return MetricState();
  }

  MetricState copyWith(
      {List<MetricModel>? metricLists,
      List<MetricModel>? userMetricLists,
      Loader? status,
      String? error}) {
    return MetricState(
        metricLists: metricLists ?? this.metricLists,
        status: status ?? this.status,
        error: error ?? this.error,
        userMetricLists: userMetricLists ?? this.userMetricLists);
  }
}
