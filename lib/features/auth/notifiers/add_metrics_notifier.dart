import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/auth/notifiers/get_tracked_metric_notifier.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final addMetricsProvider =
    StateNotifierProvider<AddMetricsNotifier, AddMetricsState>((ref) {
  return AddMetricsNotifier(ref, ref.read(dioProvider));
});

class AddMetricsNotifier extends StateNotifier<AddMetricsState> {
  AddMetricsNotifier(this.ref, this.dio) : super(AddMetricsState.initial());

  Ref ref;
  Dio dio;

  Future<ApiResponse> addMetrics(List metrics, List delete) async {
    List addMetrics = [];
    List delMetrics = [];
    List metricsList = [];
    final userMetrics = ref.read(metricProvider).userMetricLists;
    for (MetricModel metric in userMetrics!) {
      metricsList.add(metric.id!);
    }

    for (var e in metrics) {
      if (!metricsList.contains(e)) {
        addMetrics.add(e);
      }
    }
    for (var e in delete) {
      if (metricsList.contains(e)) {
        delMetrics.add(e);
      }
    }
    state = state.copyWith(loadStatus: Loader.loading);
    final Response response, response2;
    try {
      response = await dio.post('user/metrics', data: {"metrics": addMetrics});
      response2 =
          await dio.delete('user/metrics', data: {"metrics": delMetrics});
      var body = response.data;
      var body2 = response2.data;
      if (response.statusCode == 200 && response2.statusCode == 200) {
        state = state.copyWith(loadStatus: Loader.loaded);
        return ApiResponse(
          successMessage: "Successfully Updated User Metrics",
        );
      } else {
        state = state.copyWith(loadStatus: Loader.error);
        return ApiResponse(
          errorMessage: body["error"] ?? body2["error"],
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(loadStatus: Loader.error);
      return AppException.handleError(e);
    } catch (e) {
      state = state.copyWith(loadStatus: Loader.error);
      return ApiResponse(errorMessage: 'An unexpected error occurred');
    }
  }
}

class AddMetricsState {
  AddMetricsState({
    this.loadStatus,
  });

  Loader? loadStatus;

  factory AddMetricsState.initial() {
    return AddMetricsState();
  }

  AddMetricsState copyWith({
    Loader? loadStatus,
  }) {
    return AddMetricsState(
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }
}
