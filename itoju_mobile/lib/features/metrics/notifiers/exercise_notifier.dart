// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/data/models/exercise_model.dart';
import 'package:itoju_mobile/data/repositories/exercise_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

// Re-exported so existing `import '.../exercise_notifier.dart'` users keep
// seeing ExerciseModel after it moved to the shared data layer.
export 'package:itoju_mobile/data/models/exercise_model.dart';

final exerciseProvider =
    StateNotifierProvider<ExerciseNotifier, ExerciseState>((ref) {
  return ExerciseNotifier(ref, ref.read(exerciseRepositoryProvider));
});

/// Offline-first exercise notifier. Same public surface as before, but
/// reads/writes the local Drift store through ExerciseRepository instead of
/// calling the API.
class ExerciseNotifier extends StateNotifier<ExerciseState> {
  ExerciseNotifier(this.ref, this.repo) : super(ExerciseState.initial());
  Ref ref;
  ExerciseRepository repo;

  Future<void> getExercise(String date) async {
    state = state.copyWith(getStatus: Loader.loading);
    try {
      final models = await repo.getForDate(date);
      state =
          state.copyWith(getStatus: Loader.loaded, exerciseModel: models);
    } catch (e) {
      state = state.copyWith(
          getStatus: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> updateExercise(
      String start, String ended, List tags, int noOfTimes, String id) async {
    state = state.copyWith(postStatus: Loader.loading);
    try {
      await repo.update(ExerciseModel(
        id: id,
        tags: tags,
        noOfTimes: noOfTimes,
        started: start,
        ended: ended,
      ));
      state = state.copyWith(postStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully updated Exercise');
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> createExercise(String name, String date) async {
    state = state.copyWith(postStatus: Loader.loading);
    try {
      await repo.create(
          date,
          ExerciseModel(
            name: name,
            tags: const [],
            noOfTimes: 0,
            started: '',
            ended: '',
          ));
      state = state.copyWith(postStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully added Exercise');
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> deleteExercise(String id) async {
    state = state.copyWith(delStatus: Loader.loading);
    try {
      await repo.delete(id);
      state = state.copyWith(delStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Exercise successfully deleted');
    } catch (e) {
      state = state.copyWith(
          delStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }
}

class ExerciseState {
  List<ExerciseModel>? exerciseModel;
  Loader? getStatus;
  Loader? postStatus;
  Loader? delStatus;

  ExerciseState(
      {this.exerciseModel,
      this.getStatus = Loader.loading,
      this.postStatus = Loader.loaded,
      this.delStatus = Loader.loaded});
  factory ExerciseState.initial() {
    return ExerciseState();
  }

  ExerciseState copyWith({
    List<ExerciseModel>? exerciseModel,
    Loader? getStatus,
    String? error,
    Loader? postStatus,
    Loader? delStatus,
  }) {
    return ExerciseState(
        exerciseModel: exerciseModel ?? this.exerciseModel,
        getStatus: getStatus ?? this.getStatus,
        postStatus: postStatus ?? this.postStatus,
        delStatus: delStatus ?? this.delStatus);
  }
}
