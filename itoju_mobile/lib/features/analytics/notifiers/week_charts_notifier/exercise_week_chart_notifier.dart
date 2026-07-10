import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/data/analytics/local_analytics_service.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

final exerciseWeekChartProvider =
    StateNotifierProvider<ExerciseWeekChartProvider, ExerciseWeekChartState>(
        (ref) {
  return ExerciseWeekChartProvider(
      ref, ref.read(localAnalyticsServiceProvider));
});

class ExerciseWeekChartProvider extends StateNotifier<ExerciseWeekChartState> {
  ExerciseWeekChartProvider(this.ref, this.service)
      : super(ExerciseWeekChartState.initial());
  Ref ref;
  LocalAnalyticsService service;

  Future<void> getExerciseWeekDaysChart(int month) async {
    state = state.copyWith(status: Loader.loading);
    try {
      final year = DateTime.now().year;
      final data = await service.exerciseWeek(month, year);
      final exerciseWeekChartModel = ExerciseWeekChartModel.fromMap(data);
      state = state.copyWith(
          status: Loader.loaded,
          exerciseWeekChartModel: exerciseWeekChartModel);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }
}

class ExerciseWeekChartState {
  ExerciseWeekChartModel? exerciseWeekChartModel;
  Loader? status;

  ExerciseWeekChartState(
      {this.exerciseWeekChartModel, this.status = Loader.loading});
  factory ExerciseWeekChartState.initial() {
    return ExerciseWeekChartState();
  }

  ExerciseWeekChartState copyWith(
      {ExerciseWeekChartModel? exerciseWeekChartModel,
      Loader? status,
      String? error}) {
    return ExerciseWeekChartState(
        exerciseWeekChartModel:
            exerciseWeekChartModel ?? this.exerciseWeekChartModel,
        status: status ?? this.status);
  }
}

class ExerciseWeekChartModel {
  final num? week1;
  final num? week2;
  final num? week3;
  final num? week4;
  final num? week5;
  ExerciseWeekChartModel({
    this.week1,
    this.week2,
    this.week3,
    this.week4,
    this.week5,
  });

  ExerciseWeekChartModel copyWith({
    num? week1,
    num? week2,
    num? week3,
    num? week4,
    num? week5,
  }) {
    return ExerciseWeekChartModel(
      week1: week1 ?? this.week1,
      week2: week2 ?? this.week2,
      week3: week3 ?? this.week3,
      week4: week4 ?? this.week4,
      week5: week5 ?? this.week5,
    );
  }

  factory ExerciseWeekChartModel.fromMap(Map<String, dynamic> map) {
    return ExerciseWeekChartModel(
      week1: map['1'] != null ? (map['1']) as num : 0,
      week2: map['2'] != null ? (map['2']) as num : 0,
      week3: map['3'] != null ? (map['3']) as num : 0,
      week4: map['4'] != null ? (map['4']) as num : 0,
      week5: map['5'] != null ? (map['5']) as num : 0,
    );
  }
}
