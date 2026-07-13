import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/data/models/conditions_model.dart';
import 'package:itoju_mobile/data/repositories/conditions_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

export 'package:itoju_mobile/data/models/conditions_model.dart';

final getConditionsProvider = StateNotifierProvider.autoDispose<
    GetConditionsNotifier, GetConditionsState>((ref) {
  return GetConditionsNotifier(ref, ref.read(conditionsRepositoryProvider));
});

/// Offline-first conditions notifier. Same public surface; the catalog now comes
/// from the seeded local table and selections from the local Drift store.
class GetConditionsNotifier extends StateNotifier<GetConditionsState> {
  GetConditionsNotifier(this.ref, this.repo)
      : super(GetConditionsState.initial());
  Ref ref;
  ConditionsRepository repo;

  Future<void> getConditions() async {
    state = state.copyWith(status: Loader.loading);
    try {
      final conditionsLists = await repo.getCatalog();
      state = state.copyWith(
          status: Loader.loaded, conditionsLists: conditionsLists);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<void> getUserConditions() async {
    state = state.copyWith(status: Loader.loading);
    try {
      final userConditionsLists = await repo.getSelected();
      state = state.copyWith(
          status: Loader.loaded, userConditionsLists: userConditionsLists);
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
        userConditionsLists: userConditionsLists ?? this.userConditionsLists,
        status: status ?? this.status,
        error: error ?? this.error);
  }
}
