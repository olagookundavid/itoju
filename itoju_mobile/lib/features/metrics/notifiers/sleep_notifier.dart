// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/data/models/sleep_model.dart';
import 'package:itoju_mobile/data/repositories/sleep_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

// Re-exported so existing `import '.../sleep_notifier.dart'` users keep seeing
// SleepModel after it moved to the shared data layer.
export 'package:itoju_mobile/data/models/sleep_model.dart';

final sleepProvider = StateNotifierProvider<SleepNotifier, SleepState>((ref) {
  return SleepNotifier(ref, ref.read(sleepRepositoryProvider));
});

/// Offline-first sleep notifier. Same public surface as before, but reads/writes
/// the local Drift store through SleepRepository instead of calling the API.
class SleepNotifier extends StateNotifier<SleepState> {
  SleepNotifier(this.ref, this.repo) : super(SleepState.initial());
  Ref ref;
  SleepRepository repo;

  Future<void> getSleepList(String date) async {
    state = state.copyWith(status: Loader.loading);
    try {
      final models = await repo.getForDate(date);
      state = state.copyWith(status: Loader.loaded, sleepModels: models);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> createSleepMetric(String date, SleepModel model) async {
    state = state.copyWith(postStatus: Loader.loading);
    try {
      await repo.create(date, model);
      state = state.copyWith(postStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully added Sleep record');
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> updateSleepMetric(String id, SleepModel model) async {
    state = state.copyWith(updateStatus: Loader.loading);
    try {
      await repo.update(model);
      state = state.copyWith(updateStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully updated Sleep record');
    } catch (e) {
      state = state.copyWith(
          updateStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> deleteSleepMetric(String id) async {
    state = state.copyWith(delStatus: Loader.loading);
    try {
      await repo.delete(id);
      state = state.copyWith(delStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Sleep record successfully deleted');
    } catch (e) {
      state = state.copyWith(
          delStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }
}

class SleepState {
  List<SleepModel>? sleepModels;
  Loader? status;
  Loader? delStatus;
  Loader? updateStatus;
  Loader? postStatus;

  SleepState({
    this.sleepModels,
    this.status = Loader.loading,
    this.delStatus = Loader.loaded,
    this.updateStatus = Loader.loaded,
    this.postStatus = Loader.loaded,
  });
  factory SleepState.initial() {
    return SleepState();
  }

  SleepState copyWith(
      {List<SleepModel>? sleepModels,
      Loader? status,
      Loader? delStatus,
      Loader? updateStatus,
      Loader? postStatus,
      String? error}) {
    return SleepState(
        sleepModels: sleepModels ?? this.sleepModels,
        status: status ?? this.status,
        delStatus: delStatus ?? this.delStatus,
        updateStatus: updateStatus ?? this.updateStatus,
        postStatus: postStatus ?? this.postStatus);
  }
}
