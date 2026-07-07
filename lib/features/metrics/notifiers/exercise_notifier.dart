import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final exerciseProvider =
    StateNotifierProvider<ExerciseNotifier, ExerciseState>((ref) {
  return ExerciseNotifier(ref, ref.read(dioProvider));
});

class ExerciseNotifier extends StateNotifier<ExerciseState> {
  ExerciseNotifier(this.ref, this.dio) : super(ExerciseState.initial());
  Ref ref;
  Dio dio;

  Future<void> getExercise(String date) async {
    state = state.copyWith(getStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/exercise_metrics/$date');

      var body = response.data;
      if (response.statusCode == 200) {
        List<ExerciseModel> exerciseModel = List<ExerciseModel>.from(
            body['exerciseMetric'].map((e) => ExerciseModel.fromMap(e)));
        state = state.copyWith(
            getStatus: Loader.loaded, exerciseModel: exerciseModel);
      } else {
        state = state.copyWith(getStatus: Loader.error, error: body["error"]);
      }
    } on DioException catch (e) {
      state = state.copyWith(getStatus: Loader.error, error: e.message);
    } catch (e) {
      state = state.copyWith(
          getStatus: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> updateExercise(
      String start, String ended, List tags, int noOfTimes, int id) async {
    state = state.copyWith(postStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.put('user/exercise_metrics/$id', data: {
        "start": start,
        "ended": ended,
        "no_of_times": noOfTimes,
        "tags": tags,
      });

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(postStatus: Loader.loaded);
        // getExercise();
        return ApiResponse(successMessage: body['message']);
      } else {
        state = state.copyWith(postStatus: Loader.error, error: body["error"]);
        return ApiResponse(
            errorMessage: body['error'], statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      state = state.copyWith(postStatus: Loader.error);
      return AppException.handleError(e);
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> createExercise(String name, String date) async {
    state = state.copyWith(postStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.post('user/exercise_metrics/$date', data: {
        "name": name,
      });

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(postStatus: Loader.loaded);
        // getExercise();
        return ApiResponse(successMessage: body['message']);
      } else {
        state = state.copyWith(postStatus: Loader.error, error: body["error"]);
        return ApiResponse(
            errorMessage: body['error'], statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      state = state.copyWith(postStatus: Loader.error, error: e.message);
      return AppException.handleError(e);
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> deleteExercise(int id) async {
    state = state.copyWith(delStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.delete(
        'user/exercise_metrics/$id',
      );

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(delStatus: Loader.loaded);
        return ApiResponse(successMessage: body['message']);
      } else {
        state = state.copyWith(delStatus: Loader.error, error: body["error"]);
        return ApiResponse(
            errorMessage: body['error'], statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      state = state.copyWith(delStatus: Loader.error, error: e.message);
      return AppException.handleError(e);
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

class ExerciseModel {
  final int? id;
  final int? noOfTimes;
  final String? name;
  final String? started;
  final String? ended;
  final List? tags;

  ExerciseModel(
    this.id,
    this.name,
    this.tags,
    this.noOfTimes,
    this.started,
    this.ended,
  );

  factory ExerciseModel.fromMap(Map<String, dynamic> data) {
    return ExerciseModel(
      data['id'] ?? 0,
      data['name'] ?? '',
      data['tags'] ?? [],
      data['no_of_times'] ?? 0,
      data['start'] ?? '',
      data['ended'] ?? '',
    );
  }
}
