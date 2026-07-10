// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/data/models/bowel_model.dart';
import 'package:itoju_mobile/data/repositories/bowel_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

// Re-exported so existing `import '.../bowel_notifier.dart'` users keep seeing
// BowelModel after it moved to the shared data layer.
export 'package:itoju_mobile/data/models/bowel_model.dart';

final bowelProvider = StateNotifierProvider<BowelNotifier, BowelState>((ref) {
  return BowelNotifier(ref, ref.read(bowelRepositoryProvider));
});

/// Offline-first bowel notifier. Same public surface as before, but reads/writes
/// the local Drift store through BowelRepository instead of calling the API.
class BowelNotifier extends StateNotifier<BowelState> {
  BowelNotifier(this.ref, this.repo) : super(BowelState.initial());
  Ref ref;
  BowelRepository repo;

  Future<void> getBowelList(String date) async {
    state = state.copyWith(status: Loader.loading);
    try {
      final models = await repo.getForDate(date);
      state = state.copyWith(status: Loader.loaded, bowelModels: models);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> createBowelMetric(String date, BowelModel model) async {
    state = state.copyWith(postStatus: Loader.loading);
    try {
      await repo.create(date, model);
      state = state.copyWith(postStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully added Bowel Movement');
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> updateBowelMetric(BowelModel model) async {
    state = state.copyWith(updateStatus: Loader.loading);
    try {
      await repo.update(model);
      state = state.copyWith(updateStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully updated Bowel Movement');
    } catch (e) {
      state = state.copyWith(
          updateStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> deleteSymsMetric(String id) async {
    state = state.copyWith(delStatus: Loader.loading);
    try {
      await repo.delete(id);
      state = state.copyWith(delStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Bowel Movement successfully deleted');
    } catch (e) {
      state = state.copyWith(
          delStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }
}

class BowelState {
  List<BowelModel>? bowelModels;
  Loader? status;
  Loader? delStatus;
  Loader? updateStatus;
  Loader? postStatus;

  BowelState(
      {this.bowelModels,
      this.status = Loader.loading,
      this.delStatus = Loader.loaded,
      this.updateStatus = Loader.loaded,
      this.postStatus = Loader.loaded});

  factory BowelState.initial() {
    return BowelState();
  }

  BowelState copyWith(
      {List<BowelModel>? bowelModels,
      Loader? status,
      Loader? delStatus,
      Loader? updateStatus,
      Loader? postStatus,
      String? error}) {
    return BowelState(
        bowelModels: bowelModels ?? this.bowelModels,
        status: status ?? this.status,
        delStatus: delStatus ?? this.delStatus,
        updateStatus: updateStatus ?? this.updateStatus,
        postStatus: postStatus ?? this.postStatus);
  }
}
