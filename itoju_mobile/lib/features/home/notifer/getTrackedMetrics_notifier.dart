// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final getUserMetricsProvider =
    StateNotifierProvider<GetUserMetricsNotifier, GetUserMetricsState>((ref) {
  return GetUserMetricsNotifier(ref, ref.read(dioProvider));
});

class GetUserMetricsNotifier extends StateNotifier<GetUserMetricsState> {
  GetUserMetricsNotifier(this.ref, this.dio)
      : super(GetUserMetricsState.initial());
  Ref ref;
  Dio dio;

  Future<void> getGetUserMetrics() async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/metrics');

      var body = response.data;
      if (response.statusCode == 200) {
        List<UserMetricsModel> metricsModel = List<UserMetricsModel>.from(
            body['metrics'].map((e) => UserMetricsModel.fromMap(e)));
        state =
            state.copyWith(status: Loader.loaded, metricsModel: metricsModel);
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

class GetUserMetricsState {
  List<UserMetricsModel>? metricsModel;
  Loader? status;
  String? error;
  GetUserMetricsState({
    this.metricsModel,
    this.status = Loader.loading,
    this.error,
  });
  factory GetUserMetricsState.initial() {
    return GetUserMetricsState();
  }

  GetUserMetricsState copyWith({
    List<UserMetricsModel>? metricsModel,
    Loader? status,
    String? error,
  }) {
    return GetUserMetricsState(
      metricsModel: metricsModel ?? this.metricsModel,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

class UserMetricsModel {
  final int? id;
  final String? name;

  UserMetricsModel({
    required this.id,
    required this.name,
  });

  factory UserMetricsModel.fromMap(Map<String, dynamic> data) {
    return UserMetricsModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
    );
  }
}
