import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final periodProvider =
    StateNotifierProvider<PeriodNotifier, PeriodState>((ref) {
  return PeriodNotifier(ref, ref.read(dioProvider));
});

class PeriodNotifier extends StateNotifier<PeriodState> {
  PeriodNotifier(this.ref, this.dio) : super(PeriodState.initial());
  Ref ref;
  Dio dio;

  Future<void> getPeriodList() async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/period');

      var body = response.data;
      if (response.statusCode == 200) {
        List<PeriodModel> periodModels = List<PeriodModel>.from(
            body['period_days'].map((e) => PeriodModel.fromMap(e)));

        Map<String, List<PeriodModel>> periodEvent = {};

        for (var period in periodModels) {
          periodEvent[period.date] = [period];
        }

        state = state.copyWith(
            status: Loader.loaded,
            periodModels: periodModels,
            period: periodEvent);
      } else {
        state = state.copyWith(status: Loader.error, error: body["error"]);
      }
    } on DioException catch (e) {
      debugPrint(e.toString());
      state = state.copyWith(status: Loader.error, error: e.message);
    } catch (e) {
      debugPrint(e.toString());
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> createPeriodMetric(
      String date, int cycleLen, int periodLen) async {
    state = state.copyWith(postStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.post('user/period', data: {
        "start_date": date,
        "cycle_length": cycleLen,
        "period_length": periodLen
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

  Future<ApiResponse> updatePeriodMetric(PeriodModel model) async {
    state = state.copyWith(updateStatus: Loader.loading);
    final Response response;

    try {
      response = await dio.put('user/period/${model.id}', data: {
        "is_period": model.isPeriod,
        "is_ovulation": model.isOvulation,
        "pain": model.pain,
        "flow": model.flow,
        "cmq": model.cmq,
        "tags": model.tags
      });

      debugPrint(model.tags.toString());
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

  Future<ApiResponse> deletePeriodMetric(String id) async {
    state = state.copyWith(delStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.delete(
        'user/period/$id',
      );

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(delStatus: Loader.loaded);
        ref.read(periodProvider.notifier).getPeriodList();
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

class PeriodState {
  List<PeriodModel>? periodModels;
  Map<String, List<PeriodModel>>? period;
  Loader? status;
  Loader? delStatus;
  Loader? updateStatus;
  Loader? postStatus;

  PeriodState(
      {this.periodModels,
      this.period,
      this.status = Loader.loading,
      this.delStatus = Loader.loaded,
      this.updateStatus = Loader.loaded,
      this.postStatus = Loader.loaded});

  factory PeriodState.initial() {
    return PeriodState();
  }

  PeriodState copyWith(
      {List<PeriodModel>? periodModels,
      Map<String, List<PeriodModel>>? period,
      Loader? status,
      Loader? delStatus,
      Loader? updateStatus,
      Loader? postStatus,
      String? error}) {
    return PeriodState(
        periodModels: periodModels ?? this.periodModels,
        period: period ?? this.period,
        status: status ?? this.status,
        delStatus: delStatus ?? this.delStatus,
        updateStatus: updateStatus ?? this.updateStatus,
        postStatus: postStatus ?? this.postStatus);
  }
}

class PeriodModel {
  final String id;
  final String cycleId;
  final String date;
  final bool isPeriod;
  final bool isOvulation;
  final num flow;
  final num pain;
  final List tags;
  final String cmq;

  PeriodModel({
    required this.id,
    required this.cycleId,
    required this.date,
    required this.isPeriod,
    required this.isOvulation,
    required this.flow,
    required this.pain,
    required this.tags,
    required this.cmq,
  });

  factory PeriodModel.fromMap(Map<String, dynamic> map) {
    return PeriodModel(
      id: map['id'] ?? '',
      cycleId: map['cycle_id'] ?? '',
      date: DateFormat('yyyy-MM-dd').format(DateTime.parse(map['date'] ?? '')),
      isPeriod: map['is_period'] ?? false,
      isOvulation: map['is_ovulation'] ?? false,
      flow: map['flow'] ?? 0,
      pain: map['pain'] ?? 0,
      tags: map['tags'] ?? [],
      cmq: map['cmq'] ?? '',
    );
  }
}
