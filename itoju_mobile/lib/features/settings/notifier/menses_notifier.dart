import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/data/models/settings_model.dart';
import 'package:itoju_mobile/data/repositories/settings_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

export 'package:itoju_mobile/data/models/settings_model.dart' show MensesModel;

final mensesProvider =
    StateNotifierProvider<MensesNotifier, MensesState>((ref) {
  return MensesNotifier(ref, ref.read(settingsRepositoryProvider));
});

class MensesNotifier extends StateNotifier<MensesState> {
  MensesNotifier(this.ref, this.repo) : super(MensesState.initial());
  Ref ref;
  SettingsRepository repo;

  Future<void> getMenses() async {
    state = state.copyWith(getStatus: Loader.loading);
    try {
      final mensesModel = await repo.getMenses();
      state =
          state.copyWith(getStatus: Loader.loaded, mensesModel: mensesModel);
    } catch (e) {
      state = state.copyWith(
          getStatus: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> updateMenses(int periodLen, int cycleLen) async {
    state = state.copyWith(postStatus: Loader.loading);
    try {
      await repo.updateMenses(periodLen, cycleLen);
      state = state.copyWith(postStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully updated cycle settings');
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }
}

class MensesState {
  MensesModel? mensesModel;
  Loader? getStatus;
  Loader? postStatus;

  MensesState(
      {this.mensesModel,
      this.getStatus = Loader.loaded,
      this.postStatus = Loader.loaded});
  factory MensesState.initial() {
    return MensesState();
  }

  MensesState copyWith(
      {MensesModel? mensesModel,
      Loader? getStatus,
      String? error,
      Loader? postStatus}) {
    return MensesState(
        mensesModel: mensesModel ?? this.mensesModel,
        getStatus: getStatus ?? this.getStatus,
        postStatus: postStatus ?? this.postStatus);
  }
}
