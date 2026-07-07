import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final pointProvider = StateNotifierProvider<PointNotifier, PointState>((ref) {
  return PointNotifier(ref, ref.read(dioProvider));
});

class PointNotifier extends StateNotifier<PointState> {
  PointNotifier(this.ref, this.dio) : super(PointState.initial());
  Ref ref;
  Dio dio;

  Future<void> getPoint() async {
    state = state.copyWith(getStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/point');

      var body = response.data;
      if (response.statusCode == 200) {
        final pointModel = PointModel.fromMap(body['user_point']);
        state =
            state.copyWith(getStatus: Loader.loaded, pointModel: pointModel);
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

  Future<ApiResponse> postPoint(int point) async {
    state = state.copyWith(postStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.post('user/point', data: {"point": point});

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
      state = state.copyWith(postStatus: Loader.error);
      return AppException.handleError(e);
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
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

class PointModel {
  final int totalPts;
  final int todayPts;
  final int weekPts;

  PointModel(this.totalPts, this.todayPts, this.weekPts);

  factory PointModel.fromMap(Map<String, dynamic> data) {
    return PointModel(
      data['total_point'] ?? 0,
      data['today_point'] ?? 0,
      data['week_point'] ?? 0,
    );
  }
}
