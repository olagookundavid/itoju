import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itoju_mobile/data/analytics/local_analytics_service.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

final foodDiary7ChartProvider =
    StateNotifierProvider<FoodDiary7ChartProvider, FoodDiary7ChartState>((ref) {
  return FoodDiary7ChartProvider(ref, ref.read(localAnalyticsServiceProvider));
});

class FoodDiary7ChartProvider extends StateNotifier<FoodDiary7ChartState> {
  FoodDiary7ChartProvider(this.ref, this.service)
      : super(FoodDiary7ChartState.initial());
  Ref ref;
  LocalAnalyticsService service;

  Future<void> getFoodDiary7DaysChart(String tag) async {
    state = state.copyWith(status: Loader.loading);
    try {
      final data = await service.foodTags7Days(tag);
      final foodDiary7ChartModel = FoodDiary7ChartModel.fromMap(data);
      state = state.copyWith(
          status: Loader.loaded, foodDiary7ChartModel: foodDiary7ChartModel);
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
  final List<FoodAnalyticsKeyValue>? sun;
  final List<FoodAnalyticsKeyValue>? mon;
  final List<FoodAnalyticsKeyValue>? tue;
  final List<FoodAnalyticsKeyValue>? wed;
  final List<FoodAnalyticsKeyValue>? thur;
  final List<FoodAnalyticsKeyValue>? fri;
  final List<FoodAnalyticsKeyValue>? sat;
  FoodDiary7ChartModel({
    this.sun,
    this.mon,
    this.tue,
    this.wed,
    this.thur,
    this.fri,
    this.sat,
  });

  FoodDiary7ChartModel copyWith({
    List<FoodAnalyticsKeyValue>? sun,
    List<FoodAnalyticsKeyValue>? mon,
    List<FoodAnalyticsKeyValue>? tue,
    List<FoodAnalyticsKeyValue>? wed,
    List<FoodAnalyticsKeyValue>? thur,
    List<FoodAnalyticsKeyValue>? fri,
    List<FoodAnalyticsKeyValue>? sat,
  }) {
    return FoodDiary7ChartModel(
      sun: sun ?? this.sun,
      mon: mon ?? this.mon,
      tue: tue ?? this.tue,
      wed: wed ?? this.wed,
      thur: thur ?? this.thur,
      fri: fri ?? this.fri,
      sat: sat ?? this.sat,
    );
  }

  factory FoodDiary7ChartModel.fromMap(Map<String, dynamic> map) {
    return FoodDiary7ChartModel(
      sun: List<FoodAnalyticsKeyValue>.from(
          map['0'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      mon: List<FoodAnalyticsKeyValue>.from(
          map['1'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      tue: List<FoodAnalyticsKeyValue>.from(
          map['2'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      wed: List<FoodAnalyticsKeyValue>.from(
          map['3'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      thur: List<FoodAnalyticsKeyValue>.from(
          map['4'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      fri: List<FoodAnalyticsKeyValue>.from(
          map['5'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
      sat: List<FoodAnalyticsKeyValue>.from(
          map['6'].map((e) => FoodAnalyticsKeyValue.fromMap(e))),
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
