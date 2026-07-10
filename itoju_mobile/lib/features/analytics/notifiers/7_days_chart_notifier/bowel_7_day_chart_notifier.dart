import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/data/analytics/local_analytics_service.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

final bowel7ChartProvider =
    StateNotifierProvider<Bowel7ChartProvider, Bowel7ChartState>((ref) {
  return Bowel7ChartProvider(ref, ref.read(localAnalyticsServiceProvider));
});

class Bowel7ChartProvider extends StateNotifier<Bowel7ChartState> {
  Bowel7ChartProvider(this.ref, this.service)
      : super(Bowel7ChartState.initial());
  Ref ref;
  LocalAnalyticsService service;

  Future<void> getBowel7DaysChart() async {
    state = state.copyWith(status: Loader.loading);
    try {
      final data = await service.bowel7Days();
      final bowel7ChartModel = Bowel7ChartModel.fromMap(data);
      state = state.copyWith(
          status: Loader.loaded, bowel7ChartModel: bowel7ChartModel);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }
}

class Bowel7ChartState {
  Bowel7ChartModel? bowel7ChartModel;
  Loader? status;

  Bowel7ChartState({this.bowel7ChartModel, this.status = Loader.loading});
  factory Bowel7ChartState.initial() {
    return Bowel7ChartState();
  }

  Bowel7ChartState copyWith(
      {Bowel7ChartModel? bowel7ChartModel, Loader? status, String? error}) {
    return Bowel7ChartState(
        bowel7ChartModel: bowel7ChartModel ?? this.bowel7ChartModel,
        status: status ?? this.status);
  }
}

class Bowel7ChartModel {
  final List<BowelAnalyticsKeyValue>? sun;
  final List<BowelAnalyticsKeyValue>? mon;
  final List<BowelAnalyticsKeyValue>? tue;
  final List<BowelAnalyticsKeyValue>? wed;
  final List<BowelAnalyticsKeyValue>? thur;
  final List<BowelAnalyticsKeyValue>? fri;
  final List<BowelAnalyticsKeyValue>? sat;
  Bowel7ChartModel({
    this.sun,
    this.mon,
    this.tue,
    this.wed,
    this.thur,
    this.fri,
    this.sat,
  });

  Bowel7ChartModel copyWith({
    List<BowelAnalyticsKeyValue>? sun,
    List<BowelAnalyticsKeyValue>? mon,
    List<BowelAnalyticsKeyValue>? tue,
    List<BowelAnalyticsKeyValue>? wed,
    List<BowelAnalyticsKeyValue>? thur,
    List<BowelAnalyticsKeyValue>? fri,
    List<BowelAnalyticsKeyValue>? sat,
  }) {
    return Bowel7ChartModel(
      sun: sun ?? this.sun,
      mon: mon ?? this.mon,
      tue: tue ?? this.tue,
      wed: wed ?? this.wed,
      thur: thur ?? this.thur,
      fri: fri ?? this.fri,
      sat: sat ?? this.sat,
    );
  }

  factory Bowel7ChartModel.fromMap(Map<String, dynamic> map) {
    return Bowel7ChartModel(
      sun: List<BowelAnalyticsKeyValue>.from(
          map['0'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      mon: List<BowelAnalyticsKeyValue>.from(
          map['1'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      tue: List<BowelAnalyticsKeyValue>.from(
          map['2'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      wed: List<BowelAnalyticsKeyValue>.from(
          map['3'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      thur: List<BowelAnalyticsKeyValue>.from(
          map['4'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      fri: List<BowelAnalyticsKeyValue>.from(
          map['5'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
      sat: List<BowelAnalyticsKeyValue>.from(
          map['6'].map((e) => BowelAnalyticsKeyValue.fromMap(e))),
    );
  }
}

class BowelAnalyticsKeyValue {
  final int key;
  final int value;

  BowelAnalyticsKeyValue({
    required this.key,
    required this.value,
  });

  factory BowelAnalyticsKeyValue.fromMap(Map<String, dynamic> map) {
    return BowelAnalyticsKeyValue(
      key: map['key'] ?? 0,
      value: map['value'] ?? 0,
    );
  }
}
