import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final syms7ChartProvider =
    StateNotifierProvider<Syms7ChartProvider, Syms7ChartState>((ref) {
  return Syms7ChartProvider(ref, ref.read(dioProvider));
});

class Syms7ChartProvider extends StateNotifier<Syms7ChartState> {
  Syms7ChartProvider(this.ref, this.dio) : super(Syms7ChartState.initial());
  Ref ref;
  Dio dio;

  Future<void> getSyms7DaysChart(int symsId) async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/syms_days_analytics/$symsId/7');

      var body = response.data;
      if (response.statusCode == 200) {
        final syms7ChartModel =
            Syms7ChartModel.fromMap(body['analyticsMetrics']);
        state = state.copyWith(
            status: Loader.loaded, syms7ChartModel: syms7ChartModel);
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

class Syms7ChartState {
  Syms7ChartModel? syms7ChartModel;
  Loader? status;

  Syms7ChartState({this.syms7ChartModel, this.status = Loader.loading});
  factory Syms7ChartState.initial() {
    return Syms7ChartState();
  }

  Syms7ChartState copyWith(
      {Syms7ChartModel? syms7ChartModel, Loader? status, String? error}) {
    return Syms7ChartState(
        syms7ChartModel: syms7ChartModel ?? this.syms7ChartModel,
        status: status ?? this.status);
  }
}

class Syms7ChartModel {
  final num? sun;
  final num? mon;
  final num? tue;
  final num? wed;
  final num? thur;
  final num? fri;
  final num? sat;
  Syms7ChartModel({
    this.sun,
    this.mon,
    this.tue,
    this.wed,
    this.thur,
    this.fri,
    this.sat,
  });

  Syms7ChartModel copyWith({
    num? sun,
    num? mon,
    num? tue,
    num? wed,
    num? thur,
    num? fri,
    num? sat,
  }) {
    return Syms7ChartModel(
      sun: sun ?? this.sun,
      mon: mon ?? this.mon,
      tue: tue ?? this.tue,
      wed: wed ?? this.wed,
      thur: thur ?? this.thur,
      fri: fri ?? this.fri,
      sat: sat ?? this.sat,
    );
  }

  factory Syms7ChartModel.fromMap(Map<String, dynamic> map) {
    return Syms7ChartModel(
      sun: map['0'] != null ? (map['0'] * 10) as num : 0,
      mon: map['1'] != null ? (map['1'] * 10) as num : 0,
      tue: map['2'] != null ? (map['2'] * 10) as num : 0,
      wed: map['3'] != null ? (map['3'] * 10) as num : 0,
      thur: map['4'] != null ? (map['4'] * 10) as num : 0,
      fri: map['5'] != null ? (map['5'] * 10) as num : 0,
      sat: map['6'] != null ? (map['6'] * 10) as num : 0,
    );
  }
}
