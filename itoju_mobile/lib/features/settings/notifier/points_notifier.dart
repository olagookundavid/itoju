import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/data/repositories/points_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

// PointModel now lives with the repository; re-export so existing consumers
// (dashboard, profile) that import this notifier keep compiling unchanged.
export 'package:itoju_mobile/data/repositories/points_repository.dart'
    show PointModel;

final pointProvider = StateNotifierProvider<PointNotifier, PointState>((ref) {
  return PointNotifier(ref, ref.read(pointsRepositoryProvider));
});

class PointNotifier extends StateNotifier<PointState> {
  PointNotifier(this.ref, this.repository) : super(PointState.initial());
  Ref ref;
  PointsRepository repository;

  Future<void> getPoint() async {
    state = state.copyWith(getStatus: Loader.loading);
    try {
      final pointModel = await repository.getPoints();
      state = state.copyWith(getStatus: Loader.loaded, pointModel: pointModel);
    } catch (e) {
      state = state.copyWith(
          getStatus: Loader.error, error: 'An unexpected error occurred');
    }
  }
}

class PointState {
  PointModel? pointModel;
  Loader? getStatus;
  Loader? postStatus;

  PointState(
      {this.pointModel,
      this.getStatus = Loader.loaded,
      this.postStatus = Loader.loaded});
  factory PointState.initial() {
    return PointState();
  }

  PointState copyWith(
      {PointModel? pointModel,
      Loader? getStatus,
      String? error,
      Loader? postStatus}) {
    return PointState(
        pointModel: pointModel ?? this.pointModel,
        getStatus: getStatus ?? this.getStatus,
        postStatus: postStatus ?? this.postStatus);
  }
}
