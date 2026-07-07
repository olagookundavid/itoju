import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final metricProvider =
    StateNotifierProvider.autoDispose<MetricNotifier, MetricState>((ref) {
  return MetricNotifier(ref, ref.read(dioProvider));
});

class MetricNotifier extends StateNotifier<MetricState> {
  MetricNotifier(this.ref, this.dio) : super(MetricState.initial());
  Ref ref;
  Dio dio;

  Future<void> getMetric() async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('allmetrics');

      var body = response.data;
      if (response.statusCode == 200) {
        List<MetricModel> metricLists = List<MetricModel>.from(
            body['metrics'].map((e) => MetricModel.fromMap(e)));

        state = state.copyWith(status: Loader.loaded, metricLists: metricLists);
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

  Future<void> getUserMetric() async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/metrics');

      var body = response.data;
      if (response.statusCode == 200) {
        List<MetricModel> userMetricLists = List<MetricModel>.from(
            body['metrics'].map((e) => MetricModel.fromMap(e)));

        state = state.copyWith(
            status: Loader.loaded, userMetricLists: userMetricLists);
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
}

class MetricState {
  List<MetricModel>? metricLists;
  List<MetricModel>? userMetricLists;
  Loader? status;
  String? error;

  MetricState(
      {this.metricLists,
      this.userMetricLists,
      this.status = Loader.loading,
      this.error});
  factory MetricState.initial() {
    return MetricState();
  }

  MetricState copyWith(
      {List<MetricModel>? metricLists,
      List<MetricModel>? userMetricLists,
      Loader? status,
      String? error}) {
    return MetricState(
        metricLists: metricLists ?? this.metricLists,
        status: status ?? this.status,
        error: error ?? this.error,
        userMetricLists: userMetricLists ?? this.userMetricLists);
  }
}

class MetricModel {
  final int? id;
  final String? name;

  MetricModel({
    required this.id,
    required this.name,
  });

  factory MetricModel.fromMap(Map<String, dynamic> data) {
    return MetricModel(id: data['id'] ?? 0, name: data['name'] ?? '');
  }
}
