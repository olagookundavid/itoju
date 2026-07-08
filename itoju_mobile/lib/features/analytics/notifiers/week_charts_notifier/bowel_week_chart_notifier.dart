import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/bowel_7_day_chart_notifier.dart';

import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final bowelWeekChartProvider =
    StateNotifierProvider<BowelWeekChartProvider, BowelWeekChartState>((ref) {
  return BowelWeekChartProvider(ref, ref.read(dioProvider));
});

class BowelWeekChartProvider extends StateNotifier<BowelWeekChartState> {
  BowelWeekChartProvider(this.ref, this.dio)
      : super(BowelWeekChartState.initial());
  Ref ref;
  Dio dio;

  Future<void> getBowelWeekDaysChart(int month) async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/bowel_month_analytics/$month');

      var body = response.data;
      if (response.statusCode == 200) {
        final bowel7ChartModel =
            BowelWeekChartModel.fromMap(body['analyticsMetrics']);
        state = state.copyWith(
            status: Loader.loaded, bowel7ChartModel: bowel7ChartModel);
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

class BowelWeekChartState {
  BowelWeekChartModel? bowel7ChartModel;
  Loader? status;

  BowelWeekChartState({this.bowel7ChartModel, this.status = Loader.loading});
  factory BowelWeekChartState.initial() {
    return BowelWeekChartState();
  }

  BowelWeekChartState copyWith(
      {BowelWeekChartModel? bowel7ChartModel, Loader? status, String? error}) {
    return BowelWeekChartState(
        bowel7ChartModel: bowel7ChartModel ?? this.bowel7ChartModel,
        status: status ?? this.status);
  }
}

class BowelWeekChartModel {
  final List<BowelAnalyticsKeyValue>? week1;
  final List<BowelAnalyticsKeyValue>? week2;
  final List<BowelAnalyticsKeyValue>? week3;
  final List<BowelAnalyticsKeyValue>? week4;
  final List<BowelAnalyticsKeyValue>? week5;
  BowelWeekChartModel({
    this.week1,
    this.week2,
    this.week3,
    this.week4,
    this.week5,
  });

  BowelWeekChartModel copyWith({
    List<BowelAnalyticsKeyValue>? week1,
    List<BowelAnalyticsKeyValue>? week2,
    List<BowelAnalyticsKeyValue>? week3,
    List<BowelAnalyticsKeyValue>? week4,
    List<BowelAnalyticsKeyValue>? week5,
  }) {
    return BowelWeekChartModel(
      week1: week1 ?? this.week1,
      week2: week2 ?? this.week2,
      week3: week3 ?? this.week3,
      week4: week4 ?? this.week4,
      week5: week5 ?? this.week5,
    );
  }

  factory BowelWeekChartModel.fromMap(Map<String, dynamic> map) {
    return BowelWeekChartModel(
      week1: List<BowelAnalyticsKeyValue>.from(
          map['1'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      week2: List<BowelAnalyticsKeyValue>.from(
          map['2'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      week3: List<BowelAnalyticsKeyValue>.from(
          map['3'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      week4: List<BowelAnalyticsKeyValue>.from(
          map['4'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      week5: List<BowelAnalyticsKeyValue>.from(
          map['5'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
    );
  }
}
