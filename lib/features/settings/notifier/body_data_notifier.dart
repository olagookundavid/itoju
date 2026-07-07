import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final bodyDataProvider =
    StateNotifierProvider.autoDispose<BodyDataNotifier, BodyDataState>((ref) {
  return BodyDataNotifier(ref, ref.read(dioProvider));
});

class BodyDataNotifier extends StateNotifier<BodyDataState> {
  BodyDataNotifier(this.ref, this.dio) : super(BodyDataState.initial());
  Ref ref;
  Dio dio;

  Future<void> getBodyData() async {
    state = state.copyWith(getStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/bodymeasure');

      var body = response.data;
      if (response.statusCode == 200) {
        final bodyDataModel = BodyDataModel.fromMap(body['body_measure']);
        state = state.copyWith(
            getStatus: Loader.loaded, bodyDataModel: bodyDataModel);
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

  Future<ApiResponse> updateBodyData(int height, int weight) async {
    state = state.copyWith(postStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.put('user/bodymeasure', data: {
        "height": height,
        "weight": weight,
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
      state = state.copyWith(postStatus: Loader.error);
      return AppException.handleError(e);
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }
}

class BodyDataState {
  BodyDataModel? bodyDataModel;
  Loader? getStatus;
  Loader? postStatus;

  BodyDataState(
      {this.bodyDataModel,
      this.getStatus = Loader.loaded,
      this.postStatus = Loader.loaded});
  factory BodyDataState.initial() {
    return BodyDataState();
  }

  BodyDataState copyWith(
      {BodyDataModel? bodyDataModel,
      Loader? getStatus,
      String? error,
      Loader? postStatus}) {
    return BodyDataState(
        bodyDataModel: bodyDataModel ?? this.bodyDataModel,
        getStatus: getStatus ?? this.getStatus,
        postStatus: postStatus ?? this.postStatus);
  }
}

class BodyDataModel {
  final int? height;
  final int? weight;

  BodyDataModel({
    required this.height,
    required this.weight,
  });

  factory BodyDataModel.fromMap(Map<String, dynamic> data) {
    return BodyDataModel(
      height: data['height'] ?? 0,
      weight: data['weight'] ?? 0,
    );
  }
}
