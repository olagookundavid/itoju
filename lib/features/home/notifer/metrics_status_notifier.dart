// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final metricsStatusProvider =
    StateNotifierProvider<MetricsStatusNotifier, MetricsStatusState>((ref) {
  return MetricsStatusNotifier(ref, ref.read(dioProvider));
});

class MetricsStatusNotifier extends StateNotifier<MetricsStatusState> {
  MetricsStatusNotifier(this.ref, this.dio)
      : super(MetricsStatusState.initial());
  Ref ref;
  Dio dio;

  Future<void> getMetricsStatus(String date) async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/metrics_status/$date');

      var body = response.data;
      if (response.statusCode == 200) {
        final metricStatusModel =
            MetricStatusModel.fromMap(body['metrics_status']);
        state = state.copyWith(
            status: Loader.loaded, metricStatusModel: metricStatusModel);
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

class MetricsStatusState {
  MetricStatusModel? metricStatusModel;
  Loader? status;

  MetricsStatusState({this.metricStatusModel, this.status = Loader.loading});
  factory MetricsStatusState.initial() {
    return MetricsStatusState();
  }

  MetricsStatusState copyWith(
      {MetricStatusModel? metricStatusModel, Loader? status, String? error}) {
    return MetricsStatusState(
        metricStatusModel: metricStatusModel ?? this.metricStatusModel,
        status: status ?? this.status);
  }
}

class MetricStatusModel {
  final bool? symptoms;
  final bool? sleep;
  final bool? food;
  final bool? exercise;
  final bool? medication;
  final bool? urine;
  final bool? bowel;

  MetricStatusModel({
    required this.symptoms,
    required this.sleep,
    required this.food,
    required this.exercise,
    required this.medication,
    required this.urine,
    required this.bowel,
  });

  factory MetricStatusModel.fromMap(Map<String, dynamic> data) {
    return MetricStatusModel(
        symptoms: data['symptoms'] ?? false,
        sleep: data['sleep'] ?? false,
        exercise: data['exercise'] ?? false,
        food: data['food'] ?? false,
        urine: data['urine'] ?? false,
        bowel: data['bowel'] ?? false,
        medication: data['medication'] ?? false);
  }
}
