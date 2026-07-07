import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final getTrackedSymsProvider = StateNotifierProvider.autoDispose<
    GetTrackedSymsNotifier, GetTrackedSymsState>((ref) {
  return GetTrackedSymsNotifier(ref, ref.read(dioProvider));
});

class GetTrackedSymsNotifier extends StateNotifier<GetTrackedSymsState> {
  GetTrackedSymsNotifier(this.ref, this.dio)
      : super(GetTrackedSymsState.initial());
  Ref ref;
  Dio dio;

  Future<void> getGetTrackedSyms() async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/symsN/30');

      var body = response.data;
      if (response.statusCode == 200) {
        List<SymsModel> symsModels = List<SymsModel>.from(
            body['symsMetric'].map((e) => SymsModel.fromMap(e)));
        state = state.copyWith(status: Loader.loaded, symsModel: symsModels);
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

class GetTrackedSymsState {
  List<SymsModel>? symsModel;
  Loader? status;

  GetTrackedSymsState({this.symsModel, this.status = Loader.loading});
  factory GetTrackedSymsState.initial() {
    return GetTrackedSymsState();
  }

  GetTrackedSymsState copyWith(
      {List<SymsModel>? symsModel, Loader? status, String? error}) {
    return GetTrackedSymsState(
        symsModel: symsModel ?? this.symsModel, status: status ?? this.status);
  }
}

class SymsModel {
  final int? id;
  final String? name;
  final int? count;

  SymsModel({
    required this.id,
    required this.name,
    required this.count,
  });

  factory SymsModel.fromMap(Map<String, dynamic> data) {
    return SymsModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      count: data['count'] ?? 0,
    );
  }
}
