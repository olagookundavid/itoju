import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final symsMonthChartProvider =
    StateNotifierProvider<SymsMonthChartProvider, SymsMonthChartState>((ref) {
  return SymsMonthChartProvider(ref, ref.read(dioProvider));
});

class SymsMonthChartProvider extends StateNotifier<SymsMonthChartState> {
  SymsMonthChartProvider(this.ref, this.dio)
      : super(SymsMonthChartState.initial());
  Ref ref;
  Dio dio;

  Future<void> getSymsMonthDaysChart(int symsId, String year) async {
    state = state.copyWith(status: Loader.loading);
    final Response response;

    try {
      response = await dio.get('user/syms_year_analytics/$symsId/$year');

      var body = response.data;
      if (response.statusCode == 200) {
        final symsMonthChartModel =
            SymsMonthChartModel.fromMap(body['analyticsMetrics']);
        state = state.copyWith(
            status: Loader.loaded, symsMonthChartModel: symsMonthChartModel);
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

class SymsMonthChartState {
  SymsMonthChartModel? symsMonthChartModel;
  Loader? status;

  SymsMonthChartState({this.symsMonthChartModel, this.status = Loader.loading});
  factory SymsMonthChartState.initial() {
    return SymsMonthChartState();
  }

  SymsMonthChartState copyWith(
      {SymsMonthChartModel? symsMonthChartModel,
      Loader? status,
      String? error}) {
    return SymsMonthChartState(
        symsMonthChartModel: symsMonthChartModel ?? this.symsMonthChartModel,
        status: status ?? this.status);
  }
}

class SymsMonthChartModel {
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

  SymsMonthChartModel({
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

  SymsMonthChartModel copyWith({
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
    return SymsMonthChartModel(
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

  factory SymsMonthChartModel.fromMap(Map<String, dynamic> map) {
    return SymsMonthChartModel(
      jan: map['1'] != null ? (map['1'] * 10) as num : 0,
      feb: map['2'] != null ? (map['2'] * 10) as num : 0,
      mar: map['3'] != null ? (map['3'] * 10) as num : 0,
      apr: map['4'] != null ? (map['4'] * 10) as num : 0,
      may: map['5'] != null ? (map['5'] * 10) as num : 0,
      jun: map['6'] != null ? (map['6'] * 10) as num : 0,
      jul: map['7'] != null ? (map['7'] * 10) as num : 0,
      aug: map['8'] != null ? (map['8'] * 10) as num : 0,
      sep: map['9'] != null ? (map['9'] * 10) as num : 0,
      oct: map['10'] != null ? (map['10'] * 10) as num : 0,
      nov: map['11'] != null ? (map['11'] * 10) as num : 0,
      dec: map['12'] != null ? (map['12'] * 10) as num : 0,
    );
  }
}
