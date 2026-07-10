import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/data/analytics/local_analytics_service.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

final symsWeekChartProvider =
    StateNotifierProvider<SymsWeekChartProvider, SymsWeekChartState>((ref) {
  return SymsWeekChartProvider(ref, ref.read(localAnalyticsServiceProvider));
});

class SymsWeekChartProvider extends StateNotifier<SymsWeekChartState> {
  SymsWeekChartProvider(this.ref, this.service)
      : super(SymsWeekChartState.initial());
  Ref ref;
  LocalAnalyticsService service;

  Future<void> getSymsWeekDaysChart(int symsId, int month) async {
    state = state.copyWith(status: Loader.loading);
    try {
      final year = DateTime.now().year;
      final data = await service.symsWeek(symsId, month, year);
      final symsWeekChartModel = SymsWeekChartModel.fromMap(data);
      state = state.copyWith(
          status: Loader.loaded, symsWeekChartModel: symsWeekChartModel);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }
}

class SymsWeekChartState {
  SymsWeekChartModel? symsWeekChartModel;
  Loader? status;

  SymsWeekChartState({this.symsWeekChartModel, this.status = Loader.loading});
  factory SymsWeekChartState.initial() {
    return SymsWeekChartState();
  }

  SymsWeekChartState copyWith(
      {SymsWeekChartModel? symsWeekChartModel, Loader? status, String? error}) {
    return SymsWeekChartState(
        symsWeekChartModel: symsWeekChartModel ?? this.symsWeekChartModel,
        status: status ?? this.status);
  }
}

class SymsWeekChartModel {
  final num? week1;
  final num? week2;
  final num? week3;
  final num? week4;
  final num? week5;
  SymsWeekChartModel({
    this.week1,
    this.week2,
    this.week3,
    this.week4,
    this.week5,
  });

  SymsWeekChartModel copyWith({
    num? week1,
    num? week2,
    num? week3,
    num? week4,
    num? week5,
  }) {
    return SymsWeekChartModel(
      week1: week1 ?? this.week1,
      week2: week2 ?? this.week2,
      week3: week3 ?? this.week3,
      week4: week4 ?? this.week4,
      week5: week5 ?? this.week5,
    );
  }

  factory SymsWeekChartModel.fromMap(Map<String, dynamic> map) {
    return SymsWeekChartModel(
      week1: map['1'] != null ? (map['1'] * 10) as num : 0,
      week2: map['2'] != null ? (map['2'] * 10) as num : 0,
      week3: map['3'] != null ? (map['3'] * 10) as num : 0,
      week4: map['4'] != null ? (map['4'] * 10) as num : 0,
      week5: map['5'] != null ? (map['5'] * 10) as num : 0,
    );
  }
}
