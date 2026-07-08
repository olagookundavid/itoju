import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/auth/notifiers/get_conditions_notifier.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final addConditionsProvider =
    StateNotifierProvider<AddConditionsNotifier, AddConditionsState>((ref) {
  return AddConditionsNotifier(ref, ref.read(dioProvider));
});

class AddConditionsNotifier extends StateNotifier<AddConditionsState> {
  AddConditionsNotifier(this.ref, this.dio)
      : super(AddConditionsState.initial());

  Ref ref;
  Dio dio;

  Future<ApiResponse> addConditions(List conditions, List delete) async {
    state = state.copyWith(loadStatus: Loader.loading);
    final Response response, response2;
    try {
      List addConditions = [];
      List delConditions = [];
      List conditionsList = [];
      final userConditions =
          ref.read(getConditionsProvider).userConditionsLists;
      for (GetConditionsModel condition in userConditions!) {
        conditionsList.add(condition.id!);
      }

      for (var e in conditions) {
        if (!conditionsList.contains(e)) {
          addConditions.add(e);
        }
      }
      for (var e in delete) {
        if (conditionsList.contains(e)) {
          delConditions.add(e);
        }
      }
      response = await dio
          .post('user/conditions', data: {"conditions": addConditions});
      response2 = await dio
          .delete('user/conditions', data: {"conditions": delConditions});
      var body = response.data;
      var body2 = response2.data;
      if (response.statusCode == 200 && response2.statusCode == 200) {
        state = state.copyWith(loadStatus: Loader.loaded);
        return ApiResponse(
          successMessage: "Successfully Updated User Conditions",
        );
      } else {
        state = state.copyWith(loadStatus: Loader.error);
        return ApiResponse(
          errorMessage: body["error"] ?? body2["error"],
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(loadStatus: Loader.error);
      return AppException.handleError(e);
    } catch (e) {
      state = state.copyWith(loadStatus: Loader.error);
      return ApiResponse(errorMessage: 'An unexpected error occurred');
    }
  }
}

class AddConditionsState {
  AddConditionsState({
    this.loadStatus,
  });

  Loader? loadStatus;

  factory AddConditionsState.initial() {
    return AddConditionsState();
  }

  AddConditionsState copyWith({
    Loader? loadStatus,
  }) {
    return AddConditionsState(
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }
}
