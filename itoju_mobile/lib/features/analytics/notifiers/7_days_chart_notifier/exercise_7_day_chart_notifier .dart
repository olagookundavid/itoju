// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final exercise7ChartProvider =
    StateNotifierProvider<Exercise7ChartProvider, Exercise7ChartState>((ref) {
  return Exercise7ChartProvider(ref, ref.read(dioProvider));
});

class Exercise7ChartProvider extends StateNotifier<Exercise7ChartState> {
  Exercise7ChartProvider(this.ref, this.dio)
      : super(Exercise7ChartState.initial());
  Ref ref;
  Dio dio;

  Future<void> getExercise7DaysChart() async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/exercise_days_analytics/7');

      var body = response.data;
      if (response.statusCode == 200) {
        final exercise7ChartModel =
            Exercise7ChartModel.fromMap(body['analyticsMetrics']);
        state = state.copyWith(
            status: Loader.loaded, exercise7ChartModel: exercise7ChartModel);
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

class Exercise7ChartState {
  Exercise7ChartModel? exercise7ChartModel;
  Loader? status;

  Exercise7ChartState({this.exercise7ChartModel, this.status = Loader.loading});
  factory Exercise7ChartState.initial() {
    return Exercise7ChartState();
  }

  Exercise7ChartState copyWith(
      {Exercise7ChartModel? exercise7ChartModel,
      Loader? status,
      String? error}) {
    return Exercise7ChartState(
        exercise7ChartModel: exercise7ChartModel ?? this.exercise7ChartModel,
        status: status ?? this.status);
  }
}

class Exercise7ChartModel {
  final num? sun;
  final num? mon;
  final num? tue;
  final num? wed;
  final num? thur;
  final num? fri;
  final num? sat;
  Exercise7ChartModel({
    this.sun,
    this.mon,
    this.tue,
    this.wed,
    this.thur,
    this.fri,
    this.sat,
  });

  Exercise7ChartModel copyWith({
    num? sun,
    num? mon,
    num? tue,
    num? wed,
    num? thur,
    num? fri,
    num? sat,
  }) {
    return Exercise7ChartModel(
      sun: sun ?? this.sun,
      mon: mon ?? this.mon,
      tue: tue ?? this.tue,
      wed: wed ?? this.wed,
      thur: thur ?? this.thur,
      fri: fri ?? this.fri,
      sat: sat ?? this.sat,
    );
  }

  factory Exercise7ChartModel.fromMap(Map<String, dynamic> map) {
    return Exercise7ChartModel(
      sun: map['0'] != null ? (map['0']) as num : 0,
      mon: map['1'] != null ? (map['1']) as num : 0,
      tue: map['2'] != null ? (map['2']) as num : 0,
      wed: map['3'] != null ? (map['3']) as num : 0,
      thur: map['4'] != null ? (map['4']) as num : 0,
      fri: map['5'] != null ? (map['5']) as num : 0,
      sat: map['6'] != null ? (map['6']) as num : 0,
    );
  }
}
