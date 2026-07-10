// ignore_for_file: file_names

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/data/models/tracked_metrics_model.dart';
import 'package:itoju_mobile/data/repositories/tracked_metrics_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

export 'package:itoju_mobile/data/models/tracked_metrics_model.dart';

final getUserMetricsProvider =
    StateNotifierProvider<GetUserMetricsNotifier, GetUserMetricsState>((ref) {
  return GetUserMetricsNotifier(ref, ref.read(trackedMetricsRepositoryProvider));
});

/// Offline-first: the home screen's list of selected tracked metrics now reads
/// live rows from the local Drift store instead of `user/metrics`.
class GetUserMetricsNotifier extends StateNotifier<GetUserMetricsState> {
  GetUserMetricsNotifier(this.ref, this.repo)
      : super(GetUserMetricsState.initial());
  Ref ref;
  TrackedMetricsRepository repo;

  Future<void> getGetUserMetrics() async {
    state = state.copyWith(status: Loader.loading);
    try {
      final selected = await repo.getSelected();
      final metricsModel = selected
          .map((m) => UserMetricsModel(id: m.id, name: m.name))
          .toList();
      state = state.copyWith(status: Loader.loaded, metricsModel: metricsModel);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }
}

class GetUserMetricsState {
  List<UserMetricsModel>? metricsModel;
  Loader? status;
  String? error;
  GetUserMetricsState({
    this.metricsModel,
    this.status = Loader.loading,
    this.error,
  });
  factory GetUserMetricsState.initial() {
    return GetUserMetricsState();
  }

  GetUserMetricsState copyWith({
    List<UserMetricsModel>? metricsModel,
    Loader? status,
    String? error,
  }) {
    return GetUserMetricsState(
      metricsModel: metricsModel ?? this.metricsModel,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}
