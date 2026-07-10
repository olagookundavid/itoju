import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/data/repositories/conditions_repository.dart';
import 'package:itoju_mobile/features/auth/notifiers/get_conditions_notifier.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

final addConditionsProvider =
    StateNotifierProvider<AddConditionsNotifier, AddConditionsState>((ref) {
  return AddConditionsNotifier(ref, ref.read(conditionsRepositoryProvider));
});

class AddConditionsNotifier extends StateNotifier<AddConditionsState> {
  AddConditionsNotifier(this.ref, this.repo)
      : super(AddConditionsState.initial());

  Ref ref;
  ConditionsRepository repo;

  Future<ApiResponse> addConditions(List conditions, List delete) async {
    state = state.copyWith(loadStatus: Loader.loading);
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
      for (final e in addConditions) {
        await repo.add(e as int);
      }
      for (final e in delConditions) {
        await repo.remove(e as int);
      }
      state = state.copyWith(loadStatus: Loader.loaded);
      return ApiResponse(
        successMessage: "Successfully Updated User Conditions",
      );
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
