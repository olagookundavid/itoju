// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final urineProvider = StateNotifierProvider<UrineNotifier, UrineState>((ref) {
  return UrineNotifier(ref, ref.read(dioProvider));
});

class UrineNotifier extends StateNotifier<UrineState> {
  UrineNotifier(this.ref, this.dio) : super(UrineState.initial());
  Ref ref;
  Dio dio;

  Future<void> getUrineList(String date) async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/urine_metrics/$date');

      var body = response.data;
      if (response.statusCode == 200) {
        List<UrineModel> urineModels = List<UrineModel>.from(
            body['urineMetrics'].map((e) => UrineModel.fromMap(e)));
        state = state.copyWith(status: Loader.loaded, urineModels: urineModels);
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

  Future<ApiResponse> createUrineMetric(String date, UrineModel model) async {
    state = state.copyWith(postStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.post('user/urine_metrics/$date', data: {
        "time": model.time,
        "type": model.type,
        "pain": model.pain,
        "tags": model.tags,
        "quantity": model.quantity
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

  Future<ApiResponse> updateUrineMetric(UrineModel model) async {
    state = state.copyWith(updateStatus: Loader.loading);
    final Response response;

    try {
      response = await dio.put('user/urine_metrics/${model.id}', data: {
        "time": model.time,
        "type": model.type,
        "pain": model.pain,
        "tags": model.tags,
        "quantity": model.quantity
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

  Future<ApiResponse> deleteSymsMetric(int id) async {
    state = state.copyWith(delStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.delete(
        'user/urine_metrics/$id',
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

class UrineModel {
  final int? id;
  final String? time;
  final List tags;
  final int type;
  final double pain;
  final double quantity;
  UrineModel({
    this.id,
    required this.time,
    required this.tags,
    required this.type,
    required this.pain,
    required this.quantity,
  });

  factory UrineModel.fromMap(Map<String, dynamic> data) {
    return UrineModel(
      id: data['id'] ?? 0,
      time: data['time'] ?? '',
      type: data['type'],
      pain: (data['pain'] as num).toDouble(),
      quantity: (data['quantity'] as num).toDouble(),
      tags: data['tags'] ?? '',
    );
  }
}
