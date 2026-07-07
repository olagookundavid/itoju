import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/dashboard/notifiers/get_most_tracked_syms_notifier.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final symsProvider =
    StateNotifierProvider<SymptomsNotifier, SymptomsState>((ref) {
  return SymptomsNotifier(ref, ref.read(dioProvider));
});

class SymptomsNotifier extends StateNotifier<SymptomsState> {
  SymptomsNotifier(this.ref, this.dio) : super(SymptomsState.initial());
  Ref ref;
  Dio dio;

  Future<void> getSymptoms() async {
    state = state.copyWith(getStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.get('allsymptoms');

      var body = response.data;
      if (response.statusCode == 200) {
        List<SymptomsModel> symsModels = List<SymptomsModel>.from(
            body['symptoms'].map((e) => SymptomsModel.fromMap(e)));
        state = state.copyWith(
            getStatus: Loader.loaded,
            symsModels: symsModels,
            filteredSymsModel: symsModels);
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

  Future<void> getFilteredSymptoms({String? searchTerm}) async {
    if (searchTerm == null || searchTerm == '') {
      return;
    }
    List<SymptomsModel> filteredSyms = state.symsModels!
        .where((SymptomsModel syms) =>
            syms.name!.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
    state = state.copyWith(filteredSymsModel: filteredSyms);
  }

  Future<ApiResponse> createSymsMetric(int symptomId, String date) async {
    state = state.copyWith(postStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.post('user/symsMetric', data: {
        "symsptom_id": symptomId,
        "date": date,
      });

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(postStatus: Loader.loaded);
        getSymMetric(date);
        ref.read(getTrackedSymsProvider.notifier).getGetTrackedSyms();
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

  Future<void> getSymMetric(String date) async {
    state = state.copyWith(getSymsStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/symsMetric/$date');

      var body = response.data;
      if (response.statusCode == 200) {
        List<SymptomsMetricModel> symsMetricModels =
            List<SymptomsMetricModel>.from(
                body['symsMetric'].map((e) => SymptomsMetricModel.fromMap(e)));
        state = state.copyWith(
            getSymsStatus: Loader.loaded, symsMetricModels: symsMetricModels);
        // ref.read(metricsStatusProvider.notifier).getMetricsStatus(date);
      } else {
        state =
            state.copyWith(getSymsStatus: Loader.error, error: body["error"]);
      }
    } on DioException catch (e) {
      debugPrint(e.toString());
      state = state.copyWith(getSymsStatus: Loader.error, error: e.message);
    } catch (e) {
      debugPrint(e.toString());
      state = state.copyWith(
          getSymsStatus: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> deleteSymsMetric(int id) async {
    state = state.copyWith(delStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.delete(
        'user/symsMetric/$id',
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

  Future<ApiResponse> updateSymsMetric(int id, double morningSeverity,
      double afternoonSeverity, double nightSeverity, String date) async {
    state = state.copyWith(postSymsStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.put('user/symsMetric/$id', data: {
        "morning_severity": morningSeverity,
        "afternoon_severity": afternoonSeverity,
        "night_severity": nightSeverity,
      });

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(postSymsStatus: Loader.loaded);
        return ApiResponse(successMessage: body['message']);
      } else {
        state =
            state.copyWith(postSymsStatus: Loader.error, error: body["error"]);
        return ApiResponse(
            errorMessage: body['error'], statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      state = state.copyWith(postSymsStatus: Loader.error, error: e.message);
      return AppException.handleError(e);
    } catch (e) {
      state = state.copyWith(
          postSymsStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }
}

class SymptomsState {
  List<SymptomsModel>? symsModels;
  List<SymptomsModel>? filteredSymsModel;
  List<SymptomsMetricModel>? symsMetricModels;
  Loader? getStatus;
  Loader? getSymsStatus;
  Loader? postSymsStatus;
  Loader? postStatus;
  Loader? delStatus;

  SymptomsState({
    this.symsModels = const [],
    this.symsMetricModels = const [],
    this.filteredSymsModel = const [],
    this.getStatus = Loader.loading,
    this.getSymsStatus = Loader.loaded,
    this.postSymsStatus = Loader.loaded,
    this.postStatus = Loader.loaded,
    this.delStatus = Loader.loaded,
  });
  factory SymptomsState.initial() {
    return SymptomsState();
  }

  SymptomsState copyWith(
      {List<SymptomsModel>? symsModels,
      List<SymptomsModel>? filteredSymsModel,
      List<SymptomsMetricModel>? symsMetricModels,
      Loader? getStatus,
      Loader? getSymsStatus,
      Loader? postSymsStatus,
      String? error,
      Loader? postStatus,
      Loader? delStatus}) {
    return SymptomsState(
        symsModels: symsModels ?? this.symsModels,
        symsMetricModels: symsMetricModels ?? this.symsMetricModels,
        filteredSymsModel: filteredSymsModel ?? this.filteredSymsModel,
        getStatus: getStatus ?? this.getStatus,
        getSymsStatus: getSymsStatus ?? this.getSymsStatus,
        postSymsStatus: postSymsStatus ?? this.postSymsStatus,
        postStatus: postStatus ?? this.postStatus,
        delStatus: delStatus ?? this.delStatus);
  }
}

class SymptomsModel {
  final int? id;
  final String? name;

  SymptomsModel(
    this.id,
    this.name,
  );

  factory SymptomsModel.fromMap(Map<String, dynamic> data) {
    return SymptomsModel(data['id'] ?? 0, data['name'] ?? '');
  }
}

class SymptomsMetricModel {
  final int? id;
  final String? name;
  final double? morningSeverity;
  final double? afternoonSeverity;
  final double? nightSeverity;

  SymptomsMetricModel(
    this.id,
    this.name,
    this.morningSeverity,
    this.afternoonSeverity,
    this.nightSeverity,
  );

  factory SymptomsMetricModel.fromMap(Map<String, dynamic> data) {
    return SymptomsMetricModel(
      data['id'] ?? 0,
      data['name'] ?? '',
      (data['morning_severity'] ?? 0).toDouble(),
      (data['afternoon_severity'] ?? 0).toDouble(),
      (data['night_severity'] ?? 0).toDouble(),
    );
  }
}
