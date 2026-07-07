// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final bowelProvider = StateNotifierProvider<BowelNotifier, BowelState>((ref) {
  return BowelNotifier(ref, ref.read(dioProvider));
});

class BowelNotifier extends StateNotifier<BowelState> {
  BowelNotifier(this.ref, this.dio) : super(BowelState.initial());
  Ref ref;
  Dio dio;

  Future<void> getBowelList(String date) async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/bowel_metrics/$date');

      var body = response.data;
      if (response.statusCode == 200) {
        List<BowelModel> bowelModels = List<BowelModel>.from(
            body['bowelMetrics'].map((e) => BowelModel.fromMap(e)));
        state = state.copyWith(status: Loader.loaded, bowelModels: bowelModels);
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

  Future<ApiResponse> createBowelMetric(String date, BowelModel model) async {
    state = state.copyWith(postStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.post('user/bowel_metrics/$date', data: {
        "time": model.time,
        "type": model.type,
        "pain": model.pain,
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

  Future<ApiResponse> updateBowelMetric(BowelModel model) async {
    state = state.copyWith(updateStatus: Loader.loading);
    final Response response;

    try {
      response = await dio.put('user/bowel_metrics/${model.id}', data: {
        "time": model.time,
        "type": model.type,
        "pain": model.pain,
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

  Future<ApiResponse> deleteSymsMetric(int id) async {
    state = state.copyWith(delStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.delete(
        'user/bowel_metrics/$id',
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

class BowelModel {
  final int? id;
  final String? time;
  final List tags;
  final int type;
  final double pain;
  BowelModel({
    this.id,
    required this.time,
    required this.tags,
    required this.type,
    required this.pain,
  });

  factory BowelModel.fromMap(Map<String, dynamic> data) {
    return BowelModel(
      id: data['id'] ?? 0,
      time: data['time'] ?? '',
      type: data['type'],
      pain: (data['pain'] as num).toDouble(),
      tags: data['tags'] ?? '',
    );
  }
}
