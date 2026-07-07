import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final sleepProvider = StateNotifierProvider<SleepNotifier, SleepState>((ref) {
  return SleepNotifier(ref, ref.read(dioProvider));
});

class SleepNotifier extends StateNotifier<SleepState> {
  SleepNotifier(this.ref, this.dio) : super(SleepState.initial());
  Ref ref;
  Dio dio;

  // Future<void> getSleep(String date) async {
  //   state = state.copyWith(status: Loader.loading);
  //   final Response response;
  //   try {
  //     response = await dio.get('user/sleep_metrics/$date');
  //     var body = response.data;
  //     if (response.statusCode == 200) {
  //       final dayModel = body['daySleepMetric'] == null
  //           ? SleepModel(
  //               id: 0,
  //               timeSlept: '',
  //               timeWokeUp: '',
  //               tags: [],
  //               severity: 0,
  //               isNight: false)
  //           : SleepModel.fromMap(body['daySleepMetric']);
  //       final nightModel = body['nightSleepMetric'] == null
  //           ? SleepModel(
  //               id: 0,
  //               timeSlept: '',
  //               timeWokeUp: '',
  //               tags: [],
  //               severity: 0,
  //               isNight: true)
  //           : SleepModel.fromMap(body['nightSleepMetric']);
  //       state = state.copyWith(
  //           status: Loader.loaded, dayModel: dayModel, nightModel: nightModel);
  //     } else {
  //       state = state.copyWith(status: Loader.error, error: body["error"]);
  //     }
  //   } on DioException catch (e) {
  //     state = state.copyWith(status: Loader.error, error: e.message);
  //   } catch (e) {
  //     state = state.copyWith(
  //         status: Loader.error, error: 'An unexpected error occurred');
  //   }
  // }

  Future<void> getSleepList(String date) async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/sleep_metrics/$date');

      var body = response.data;
      if (response.statusCode == 200) {
        List<SleepModel> sleepModels = List<SleepModel>.from(
            body['sleepMetrics'].map((e) => SleepModel.fromMap(e)));
        state = state.copyWith(status: Loader.loaded, sleepModels: sleepModels);
      } else {
        state = state.copyWith(status: Loader.error, error: body["error"]);
      }
    } on DioException catch (e) {
      state = state.copyWith(status: Loader.error, error: e.message);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> createSleepMetric(String date, SleepModel model) async {
    state = state.copyWith(postStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.post('user/sleep_metrics/$date', data: {
        "time_slept": model.timeSlept,
        "time_woke_up": model.timeWokeUp,
        "severity": model.severity,
        "is_night": model.isNight,
        "tags": model.tags
      });

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(postStatus: Loader.loaded);
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

  Future<ApiResponse> updateSleepMetric(int id, SleepModel model) async {
    state = state.copyWith(updateStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.put('user/sleep_metrics/$id', data: {
        "time_slept": model.timeSlept,
        "time_woke_up": model.timeWokeUp,
        "severity": model.severity,
        "tags": model.tags
      });

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(updateStatus: Loader.loaded);
        return ApiResponse(successMessage: body['message']);
      } else {
        state =
            state.copyWith(updateStatus: Loader.error, error: body["error"]);
        return ApiResponse(
            errorMessage: body['error'], statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      state = state.copyWith(updateStatus: Loader.error, error: e.message);
      return AppException.handleError(e);
    } catch (e) {
      state = state.copyWith(
          updateStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  Future<ApiResponse> deleteSleepMetric(int id) async {
    state = state.copyWith(delStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.delete(
        'user/sleep_metrics/$id',
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

class SleepModel {
  final int? id;
  final String? timeSlept;
  final String? timeWokeUp;
  final List tags;
  final double severity;
  final bool? isNight;

  factory SleepModel.fromMap(Map<String, dynamic> data) {
    return SleepModel(
        id: data['id'] ?? 0,
        timeSlept: data['time_slept'] ?? '',
        timeWokeUp: data['time_woke_up'] ?? '',
        severity: (data['severity'] as num).toDouble(),
        tags: data['tags'] ?? '',
        isNight: data['is_night'] ?? false);
  }
  SleepModel(
      {required this.id,
      required this.timeSlept,
      required this.timeWokeUp,
      required this.tags,
      required this.severity,
      required this.isNight});
}
