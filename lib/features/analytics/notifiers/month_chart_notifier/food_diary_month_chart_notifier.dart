import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/features/analytics/notifiers/week_charts_notifier/food_week_day_chart_notifier.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final foodDiaryMonthChartProvider = StateNotifierProvider<
    FoodDiaryMonthChartProvider, FoodDiaryMonthChartState>((ref) {
  return FoodDiaryMonthChartProvider(ref, ref.read(dioProvider));
});

class FoodDiaryMonthChartProvider
    extends StateNotifier<FoodDiaryMonthChartState> {
  FoodDiaryMonthChartProvider(this.ref, this.dio)
      : super(FoodDiaryMonthChartState.initial());
  Ref ref;
  Dio dio;

  Future<void> getFoodDiaryMonthDaysChart(String tag, String year) async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/tag_year_analytics/$year/$tag');

      var body = response.data;
      if (response.statusCode == 200) {
        final foodDiary7ChartModel =
            FoodDiaryMonthChartModel.fromMap(body['analyticsMetrics']);
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

class FoodDiaryMonthChartState {
  FoodDiaryMonthChartModel? foodDiary7ChartModel;
  Loader? status;

  FoodDiaryMonthChartState(
      {this.foodDiary7ChartModel, this.status = Loader.loading});
  factory FoodDiaryMonthChartState.initial() {
    return FoodDiaryMonthChartState();
  }

  FoodDiaryMonthChartState copyWith(
      {FoodDiaryMonthChartModel? foodDiary7ChartModel,
      Loader? status,
      String? error}) {
    return FoodDiaryMonthChartState(
        foodDiary7ChartModel: foodDiary7ChartModel ?? this.foodDiary7ChartModel,
        status: status ?? this.status);
  }
}

class FoodDiaryMonthChartModel {
  final List<FoodAnalyticsKeyValue>? jan;
  final List<FoodAnalyticsKeyValue>? feb;
  final List<FoodAnalyticsKeyValue>? mar;
  final List<FoodAnalyticsKeyValue>? apr;
  final List<FoodAnalyticsKeyValue>? may;
  final List<FoodAnalyticsKeyValue>? jun;
  final List<FoodAnalyticsKeyValue>? jul;
  final List<FoodAnalyticsKeyValue>? aug;
  final List<FoodAnalyticsKeyValue>? sept;
  final List<FoodAnalyticsKeyValue>? oct;
  final List<FoodAnalyticsKeyValue>? nov;
  final List<FoodAnalyticsKeyValue>? dec;
  FoodDiaryMonthChartModel({
    this.jan,
    this.feb,
    this.mar,
    this.apr,
    this.may,
    this.jun,
    this.jul,
    this.aug,
    this.sept,
    this.oct,
    this.nov,
    this.dec,
  });

  FoodDiaryMonthChartModel copyWith({
    List<FoodAnalyticsKeyValue>? jan,
    List<FoodAnalyticsKeyValue>? feb,
    List<FoodAnalyticsKeyValue>? mar,
    List<FoodAnalyticsKeyValue>? apr,
    List<FoodAnalyticsKeyValue>? may,
    List<FoodAnalyticsKeyValue>? jun,
    List<FoodAnalyticsKeyValue>? jul,
    List<FoodAnalyticsKeyValue>? aug,
    List<FoodAnalyticsKeyValue>? sept,
    List<FoodAnalyticsKeyValue>? oct,
    List<FoodAnalyticsKeyValue>? nov,
    List<FoodAnalyticsKeyValue>? dec,
  }) {
    return FoodDiaryMonthChartModel(
      jan: jan ?? this.jan,
      feb: feb ?? this.feb,
      mar: mar ?? this.mar,
      apr: apr ?? this.apr,
      may: may ?? this.may,
      jun: jun ?? this.jun,
      jul: jul ?? this.jul,
      aug: aug ?? this.aug,
      sept: sept ?? this.sept,
      oct: oct ?? this.oct,
      nov: nov ?? this.nov,
      dec: dec ?? this.dec,
    );
  }

  factory FoodDiaryMonthChartModel.fromMap(Map<String, dynamic> map) {
    return FoodDiaryMonthChartModel(
      jan: List<FoodAnalyticsKeyValue>.from(
          map['1'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      feb: List<FoodAnalyticsKeyValue>.from(
          map['2'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      mar: List<FoodAnalyticsKeyValue>.from(
          map['3'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      apr: List<FoodAnalyticsKeyValue>.from(
          map['4'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      may: List<FoodAnalyticsKeyValue>.from(
          map['5'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      jun: List<FoodAnalyticsKeyValue>.from(
          map['6'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      jul: List<FoodAnalyticsKeyValue>.from(
          map['7'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      aug: List<FoodAnalyticsKeyValue>.from(
          map['8'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      sept: List<FoodAnalyticsKeyValue>.from(
          map['9'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      oct: List<FoodAnalyticsKeyValue>.from(
          map['10'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      nov: List<FoodAnalyticsKeyValue>.from(
          map['11'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      dec: List<FoodAnalyticsKeyValue>.from(
          map['12'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
    );
  }
}
