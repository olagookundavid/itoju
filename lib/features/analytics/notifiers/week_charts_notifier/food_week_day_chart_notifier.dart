import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final foodDiaryWeekChartProvider =
    StateNotifierProvider<FoodDiaryWeekChartProvider, FoodDiary7ChartState>(
        (ref) {
  return FoodDiaryWeekChartProvider(ref, ref.read(dioProvider));
});

class FoodDiaryWeekChartProvider extends StateNotifier<FoodDiary7ChartState> {
  FoodDiaryWeekChartProvider(this.ref, this.dio)
      : super(FoodDiary7ChartState.initial());
  Ref ref;
  Dio dio;

  Future<void> getFoodDiaryWeekDaysChart(String tag, int month) async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/tag_month_analytics/$month/$tag');

      var body = response.data;
      if (response.statusCode == 200) {
        final foodDiary7ChartModel =
            FoodDiary7ChartModel.fromMap(body['analyticsMetrics']);
        state = state.copyWith(
            status: Loader.loaded, foodDiary7ChartModel: foodDiary7ChartModel);
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

class FoodDiary7ChartState {
  FoodDiary7ChartModel? foodDiary7ChartModel;
  Loader? status;

  FoodDiary7ChartState(
      {this.foodDiary7ChartModel, this.status = Loader.loading});
  factory FoodDiary7ChartState.initial() {
    return FoodDiary7ChartState();
  }

  FoodDiary7ChartState copyWith(
      {FoodDiary7ChartModel? foodDiary7ChartModel,
      Loader? status,
      String? error}) {
    return FoodDiary7ChartState(
        foodDiary7ChartModel: foodDiary7ChartModel ?? this.foodDiary7ChartModel,
        status: status ?? this.status);
  }
}

class FoodDiary7ChartModel {
  final List<FoodAnalyticsKeyValue>? week1;
  final List<FoodAnalyticsKeyValue>? week2;
  final List<FoodAnalyticsKeyValue>? week3;
  final List<FoodAnalyticsKeyValue>? week4;
  final List<FoodAnalyticsKeyValue>? week5;
  FoodDiary7ChartModel({
    this.week1,
    this.week2,
    this.week3,
    this.week4,
    this.week5,
  });

  FoodDiary7ChartModel copyWith({
    List<FoodAnalyticsKeyValue>? week1,
    List<FoodAnalyticsKeyValue>? week2,
    List<FoodAnalyticsKeyValue>? week3,
    List<FoodAnalyticsKeyValue>? week4,
    List<FoodAnalyticsKeyValue>? week5,
  }) {
    return FoodDiary7ChartModel(
      week1: week1 ?? this.week1,
      week2: week2 ?? this.week2,
      week3: week3 ?? this.week3,
      week4: week4 ?? this.week4,
      week5: week5 ?? this.week5,
    );
  }

  factory FoodDiary7ChartModel.fromMap(Map<String, dynamic> map) {
    return FoodDiary7ChartModel(
      week1: List<FoodAnalyticsKeyValue>.from(
          map['1'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      week2: List<FoodAnalyticsKeyValue>.from(
          map['2'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      week3: List<FoodAnalyticsKeyValue>.from(
          map['3'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      week4: List<FoodAnalyticsKeyValue>.from(
          map['4'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      week5: List<FoodAnalyticsKeyValue>.from(
          map['5'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
    );
  }
}

class FoodAnalyticsKeyValue {
  final String key;
  final int value;

  FoodAnalyticsKeyValue({
    required this.key,
    required this.value,
  });

  factory FoodAnalyticsKeyValue.fromMap(Map<String, dynamic> map) {
    return FoodAnalyticsKeyValue(
      key: map['key'] ?? '',
      value: map['value'] ?? 0,
    );
  }
}
