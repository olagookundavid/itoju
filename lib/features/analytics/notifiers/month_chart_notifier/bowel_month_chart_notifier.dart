import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/analytics/notifiers/7_days_chart_notifier/bowel_7_day_chart_notifier.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final bowelMonthChartProvider =
    StateNotifierProvider<BowelMonthChartProvider, BowelMonthChartState>((ref) {
  return BowelMonthChartProvider(ref, ref.read(dioProvider));
});

class BowelMonthChartProvider extends StateNotifier<BowelMonthChartState> {
  BowelMonthChartProvider(this.ref, this.dio)
      : super(BowelMonthChartState.initial());
  Ref ref;
  Dio dio;

  Future<void> getBowelMonthDaysChart(String year) async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/bowel_year_analytics/$year');

      var body = response.data;
      if (response.statusCode == 200) {
        final bowelMonthChartModel =
            BowelMonthChartModel.fromMap(body['analyticsMetrics']);
        state = state.copyWith(
            status: Loader.loaded, bowelMonthChartModel: bowelMonthChartModel);
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

class BowelMonthChartState {
  BowelMonthChartModel? bowelMonthChartModel;
  Loader? status;

  BowelMonthChartState(
      {this.bowelMonthChartModel, this.status = Loader.loading});
  factory BowelMonthChartState.initial() {
    return BowelMonthChartState();
  }

  BowelMonthChartState copyWith(
      {BowelMonthChartModel? bowelMonthChartModel,
      Loader? status,
      String? error}) {
    return BowelMonthChartState(
        bowelMonthChartModel: bowelMonthChartModel ?? this.bowelMonthChartModel,
        status: status ?? this.status);
  }
}

class BowelMonthChartModel {
  final List<BowelAnalyticsKeyValue>? jan;
  final List<BowelAnalyticsKeyValue>? feb;
  final List<BowelAnalyticsKeyValue>? mar;
  final List<BowelAnalyticsKeyValue>? apr;
  final List<BowelAnalyticsKeyValue>? may;
  final List<BowelAnalyticsKeyValue>? jun;
  final List<BowelAnalyticsKeyValue>? jul;
  final List<BowelAnalyticsKeyValue>? aug;
  final List<BowelAnalyticsKeyValue>? sept;
  final List<BowelAnalyticsKeyValue>? oct;
  final List<BowelAnalyticsKeyValue>? nov;
  final List<BowelAnalyticsKeyValue>? dec;
  BowelMonthChartModel({
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

  BowelMonthChartModel copyWith({
    List<BowelAnalyticsKeyValue>? jan,
    List<BowelAnalyticsKeyValue>? feb,
    List<BowelAnalyticsKeyValue>? mar,
    List<BowelAnalyticsKeyValue>? apr,
    List<BowelAnalyticsKeyValue>? may,
    List<BowelAnalyticsKeyValue>? jun,
    List<BowelAnalyticsKeyValue>? jul,
    List<BowelAnalyticsKeyValue>? aug,
    List<BowelAnalyticsKeyValue>? sept,
    List<BowelAnalyticsKeyValue>? oct,
    List<BowelAnalyticsKeyValue>? nov,
    List<BowelAnalyticsKeyValue>? dec,
  }) {
    return BowelMonthChartModel(
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

  factory BowelMonthChartModel.fromMap(Map<String, dynamic> map) {
    return BowelMonthChartModel(
      jan: List<BowelAnalyticsKeyValue>.from(
          map['1'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      feb: List<BowelAnalyticsKeyValue>.from(
          map['2'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      mar: List<BowelAnalyticsKeyValue>.from(
          map['3'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      apr: List<BowelAnalyticsKeyValue>.from(
          map['4'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      may: List<BowelAnalyticsKeyValue>.from(
          map['5'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      jun: List<BowelAnalyticsKeyValue>.from(
          map['6'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      jul: List<BowelAnalyticsKeyValue>.from(
          map['7'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      aug: List<BowelAnalyticsKeyValue>.from(
          map['8'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      sept: List<BowelAnalyticsKeyValue>.from(
          map['9'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      oct: List<BowelAnalyticsKeyValue>.from(
          map['10'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      nov: List<BowelAnalyticsKeyValue>.from(
          map['11'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      dec: List<BowelAnalyticsKeyValue>.from(
          map['12'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
    );
  }
}
