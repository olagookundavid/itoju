import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final exerciseMonthChartProvider =
    StateNotifierProvider<ExerciseMonthChartProvider, ExerciseMonthChartState>(
        (ref) {
  return ExerciseMonthChartProvider(ref, ref.read(dioProvider));
});

class ExerciseMonthChartProvider
    extends StateNotifier<ExerciseMonthChartState> {
  ExerciseMonthChartProvider(this.ref, this.dio)
      : super(ExerciseMonthChartState.initial());
  Ref ref;
  Dio dio;

  Future<void> getExerciseMonthDaysChart(String year) async {
    state = state.copyWith(status: Loader.loading);
    final Response response;

    try {
      response = await dio.get('user/exercise_year_analytics/$year');

      var body = response.data;
      if (response.statusCode == 200) {
        final exerciseMonthChartModel =
            ExerciseMonthChartModel.fromMap(body['analyticsMetrics']);
        state = state.copyWith(
            status: Loader.loaded,
            exerciseMonthChartModel: exerciseMonthChartModel);
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

class ExerciseMonthChartState {
  ExerciseMonthChartModel? exerciseMonthChartModel;
  Loader? status;

  ExerciseMonthChartState(
      {this.exerciseMonthChartModel, this.status = Loader.loading});
  factory ExerciseMonthChartState.initial() {
    return ExerciseMonthChartState();
  }

  ExerciseMonthChartState copyWith(
      {ExerciseMonthChartModel? exerciseMonthChartModel,
      Loader? status,
      String? error}) {
    return ExerciseMonthChartState(
        exerciseMonthChartModel:
            exerciseMonthChartModel ?? this.exerciseMonthChartModel,
        status: status ?? this.status);
  }
}

class ExerciseMonthChartModel {
  final num? jan;
  final num? feb;
  final num? mar;
  final num? apr;
  final num? may;
  final num? jun;
  final num? jul;
  final num? aug;
  final num? sep;
  final num? oct;
  final num? nov;
  final num? dec;

  ExerciseMonthChartModel({
    this.jan,
    this.feb,
    this.mar,
    this.apr,
    this.may,
    this.jun,
    this.jul,
    this.aug,
    this.sep,
    this.oct,
    this.nov,
    this.dec,
  });

  ExerciseMonthChartModel copyWith({
    num? jan,
    num? feb,
    num? mar,
    num? apr,
    num? may,
    num? jun,
    num? jul,
    num? aug,
    num? sep,
    num? oct,
    num? nov,
    num? dec,
  }) {
    return ExerciseMonthChartModel(
      jan: jan ?? this.jan,
      feb: feb ?? this.feb,
      mar: mar ?? this.mar,
      apr: apr ?? this.apr,
      may: may ?? this.may,
      jun: jun ?? this.jun,
      jul: jul ?? this.jul,
      aug: aug ?? this.aug,
      sep: sep ?? this.sep,
      oct: oct ?? this.oct,
      nov: nov ?? this.nov,
      dec: dec ?? this.dec,
    );
  }

  factory ExerciseMonthChartModel.fromMap(Map<String, dynamic> map) {
    return ExerciseMonthChartModel(
      jan: map['1'] != null ? (map['1']) as num : 0,
      feb: map['2'] != null ? (map['2']) as num : 0,
      mar: map['3'] != null ? (map['3']) as num : 0,
      apr: map['4'] != null ? (map['4']) as num : 0,
      may: map['5'] != null ? (map['5']) as num : 0,
      jun: map['6'] != null ? (map['6']) as num : 0,
      jul: map['7'] != null ? (map['7']) as num : 0,
      aug: map['8'] != null ? (map['8']) as num : 0,
      sep: map['9'] != null ? (map['9']) as num : 0,
      oct: map['10'] != null ? (map['10']) as num : 0,
      nov: map['11'] != null ? (map['11']) as num : 0,
      dec: map['12'] != null ? (map['12']) as num : 0,
    );
  }
}
