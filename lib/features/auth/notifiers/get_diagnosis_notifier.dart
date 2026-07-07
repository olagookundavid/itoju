import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final getDiagnosisProvider =
    StateNotifierProvider.autoDispose<GetDiagnosisNotifier, GetDiagnosisState>(
        (ref) {
  return GetDiagnosisNotifier(ref, ref.read(dioProvider));
});

class GetDiagnosisNotifier extends StateNotifier<GetDiagnosisState> {
  GetDiagnosisNotifier(this.ref, this.dio) : super(GetDiagnosisState.initial());
  Ref ref;
  Dio dio;

  Future<void> getDiagnosis() async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('alldiagnosis');

      var body = response.data;
      if (response.statusCode == 200) {
        List<GetDiagnosisModel> diagnosisLists = List<GetDiagnosisModel>.from(
            body['diagnosis'].map((e) => GetDiagnosisModel.fromMap(e)));

        state = state.copyWith(
            status: Loader.loaded, diagnosisLists: diagnosisLists);
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

  Future<void> getUserDiagnosis() async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/diagnosis');

      var body = response.data;
      if (response.statusCode == 200) {
        List<GetDiagnosisModel> diagnosisLists = List<GetDiagnosisModel>.from(
            body['diagnosis'].map((e) => GetDiagnosisModel.fromMap(e)));

        state = state.copyWith(
            status: Loader.loaded, diagnosisLists: diagnosisLists);
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

class GetDiagnosisState {
  List<GetDiagnosisModel>? diagnosisLists;
  Loader? status;
  String? error;

  GetDiagnosisState(
      {this.diagnosisLists, this.status = Loader.loading, this.error});
  factory GetDiagnosisState.initial() {
    return GetDiagnosisState();
  }

  GetDiagnosisState copyWith(
      {List<GetDiagnosisModel>? diagnosisLists,
      Loader? status,
      String? error}) {
    return GetDiagnosisState(
        diagnosisLists: diagnosisLists ?? this.diagnosisLists,
        status: status ?? this.status,
        error: error ?? this.error);
  }
}

class GetDiagnosisModel {
  final int? id;
  final String? name;

  GetDiagnosisModel({
    required this.id,
    required this.name,
  });

  factory GetDiagnosisModel.fromMap(Map<String, dynamic> data) {
    return GetDiagnosisModel(id: data['id'] ?? 0, name: data['name'] ?? '');
  }
}
