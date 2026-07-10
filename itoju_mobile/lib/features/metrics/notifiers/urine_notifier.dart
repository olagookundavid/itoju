// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/data/models/urine_model.dart';
import 'package:itoju_mobile/data/repositories/urine_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

// Re-exported so existing `import '.../urine_notifier.dart'` users keep seeing
// UrineModel after it moved to the shared data layer.
export 'package:itoju_mobile/data/models/urine_model.dart';

final urineProvider = StateNotifierProvider<UrineNotifier, UrineState>((ref) {
  return UrineNotifier(ref, ref.read(urineRepositoryProvider));
});

/// Offline-first urine notifier. Same public surface as before, but reads/writes
/// the local Drift store through UrineRepository instead of calling the API.
class UrineNotifier extends StateNotifier<UrineState> {
  UrineNotifier(this.ref, this.repo) : super(UrineState.initial());
  Ref ref;
  UrineRepository repo;

  Future<void> getUrineList(String date) async {
    state = state.copyWith(status: Loader.loading);
    try {
      final models = await repo.getForDate(date);
      state = state.copyWith(status: Loader.loaded, urineModels: models);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> createUrineMetric(String date, UrineModel model) async {
    state = state.copyWith(postStatus: Loader.loading);
    try {
      await repo.create(date, model);
      state = state.copyWith(postStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully added Urine record');
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> updateUrineMetric(UrineModel model) async {
    state = state.copyWith(updateStatus: Loader.loading);
    try {
      await repo.update(model);
      state = state.copyWith(updateStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully updated Urine record');
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
      return ApiResponse(successMessage: 'Urine record successfully deleted');
    } catch (e) {
      state = state.copyWith(
          delStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }
}

class UrineState {
  List<UrineModel>? urineModels;
  Loader? status;
  Loader? delStatus;
  Loader? updateStatus;
  Loader? postStatus;

  UrineState(
      {this.urineModels = const [],
      this.status = Loader.loading,
      this.delStatus = Loader.loaded,
      this.updateStatus = Loader.loaded,
      this.postStatus = Loader.loaded});

  factory UrineState.initial() {
    return UrineState();
  }

  UrineState copyWith(
      {List<UrineModel>? urineModels,
      Loader? status,
      Loader? delStatus,
      Loader? updateStatus,
      Loader? postStatus,
      String? error}) {
    return UrineState(
        urineModels: urineModels ?? this.urineModels,
        status: status ?? this.status,
        delStatus: delStatus ?? this.delStatus,
        updateStatus: updateStatus ?? this.updateStatus,
        postStatus: postStatus ?? this.postStatus);
  }
}
