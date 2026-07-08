import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final getConditionsProvider = StateNotifierProvider.autoDispose<
    GetConditionsNotifier, GetConditionsState>((ref) {
  return GetConditionsNotifier(ref, ref.read(dioProvider));
});

class GetConditionsNotifier extends StateNotifier<GetConditionsState> {
  GetConditionsNotifier(this.ref, this.dio)
      : super(GetConditionsState.initial());
  Ref ref;
  Dio dio;

  Future<void> getConditions() async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('allconditions');

      var body = response.data;
      if (response.statusCode == 200) {
        List<GetConditionsModel> conditionsLists =
            List<GetConditionsModel>.from(
                body['conditions'].map((e) => GetConditionsModel.fromMap(e)));

        state = state.copyWith(
            status: Loader.loaded, conditionsLists: conditionsLists);
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

  Future<void> getUserConditions() async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/conditions');

      var body = response.data;
      if (response.statusCode == 200) {
        List<GetConditionsModel> userConditionsLists =
            List<GetConditionsModel>.from(
                body['conditions'].map((e) => GetConditionsModel.fromMap(e)));

        state = state.copyWith(
            status: Loader.loaded, userConditionsLists: userConditionsLists);
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

class GetConditionsState {
  List<GetConditionsModel>? conditionsLists;
  List<GetConditionsModel>? userConditionsLists;
  Loader? status;
  String? error;

  GetConditionsState(
      {this.conditionsLists,
      this.userConditionsLists,
      this.status = Loader.loading,
      this.error});
  factory GetConditionsState.initial() {
    return GetConditionsState();
  }

  GetConditionsState copyWith(
      {List<GetConditionsModel>? conditionsLists,
      List<GetConditionsModel>? userConditionsLists,
      Loader? status,
      String? error}) {
    return GetConditionsState(
        conditionsLists: conditionsLists ?? this.conditionsLists,
        status: status ?? this.status,
        userConditionsLists: userConditionsLists ?? this.userConditionsLists,
        error: error ?? this.error);
  }
}

class GetConditionsModel {
  final int? id;
  final String? name;

  GetConditionsModel({
    required this.id,
    required this.name,
  });

  factory GetConditionsModel.fromMap(Map<String, dynamic> data) {
    return GetConditionsModel(id: data['id'] ?? 0, name: data['name'] ?? '');
  }
}
