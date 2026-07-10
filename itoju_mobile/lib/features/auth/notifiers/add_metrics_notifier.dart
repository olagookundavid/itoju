import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/data/repositories/tracked_metrics_repository.dart';
import 'package:itoju_mobile/features/auth/notifiers/get_tracked_metric_notifier.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

final addMetricsProvider =
    StateNotifierProvider<AddMetricsNotifier, AddMetricsState>((ref) {
  return AddMetricsNotifier(ref, ref.read(trackedMetricsRepositoryProvider));
});

class AddMetricsNotifier extends StateNotifier<AddMetricsState> {
  AddMetricsNotifier(this.ref, this.repo) : super(AddMetricsState.initial());

  Ref ref;
  TrackedMetricsRepository repo;

  Future<ApiResponse> addMetrics(List metrics, List delete) async {
    List addMetrics = [];
    List delMetrics = [];
    List metricsList = [];
    final userMetrics = ref.read(metricProvider).userMetricLists;
    for (MetricModel metric in userMetrics!) {
      metricsList.add(metric.id!);
    }

    for (var e in metrics) {
      if (!metricsList.contains(e)) {
        addMetrics.add(e);
      }
    }
    for (var e in delete) {
      if (metricsList.contains(e)) {
        delMetrics.add(e);
      }
    }
    state = state.copyWith(loadStatus: Loader.loading);
    try {
      for (final e in addMetrics) {
        await repo.add(e as int);
      }
      for (final e in delMetrics) {
        await repo.remove(e as int);
      }
      state = state.copyWith(loadStatus: Loader.loaded);
      return ApiResponse(
        successMessage: "Successfully Updated User Metrics",
      );
    } catch (e) {
      state = state.copyWith(loadStatus: Loader.error);
      return ApiResponse(errorMessage: 'An unexpected error occurred');
    }
  }
}

class AddMetricsState {
  AddMetricsState({
    this.loadStatus,
  });

  Loader? loadStatus;

  factory AddMetricsState.initial() {
    return AddMetricsState();
  }

  AddMetricsState copyWith({
    Loader? loadStatus,
  }) {
    return AddMetricsState(
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }
}
