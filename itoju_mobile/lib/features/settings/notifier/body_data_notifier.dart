import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/data/models/settings_model.dart';
import 'package:itoju_mobile/data/repositories/settings_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

export 'package:itoju_mobile/data/models/settings_model.dart' show BodyDataModel;

final bodyDataProvider =
    StateNotifierProvider.autoDispose<BodyDataNotifier, BodyDataState>((ref) {
  return BodyDataNotifier(ref, ref.read(settingsRepositoryProvider));
});

class BodyDataNotifier extends StateNotifier<BodyDataState> {
  BodyDataNotifier(this.ref, this.repo) : super(BodyDataState.initial());
  Ref ref;
  SettingsRepository repo;

  Future<void> getBodyData() async {
    state = state.copyWith(getStatus: Loader.loading);
    try {
      final bodyDataModel = await repo.getBodyData();
      state = state.copyWith(
          getStatus: Loader.loaded, bodyDataModel: bodyDataModel);
    } catch (e) {
      state = state.copyWith(
          getStatus: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> updateBodyData(int height, int weight) async {
    state = state.copyWith(postStatus: Loader.loading);
    try {
      await repo.updateBodyData(height, weight);
      state = state.copyWith(postStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully updated body data');
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }
}

class BodyDataState {
  BodyDataModel? bodyDataModel;
  Loader? getStatus;
  Loader? postStatus;

  BodyDataState(
      {this.bodyDataModel,
      this.getStatus = Loader.loaded,
      this.postStatus = Loader.loaded});
  factory BodyDataState.initial() {
    return BodyDataState();
  }

  BodyDataState copyWith(
      {BodyDataModel? bodyDataModel,
      Loader? getStatus,
      String? error,
      Loader? postStatus}) {
    return BodyDataState(
        bodyDataModel: bodyDataModel ?? this.bodyDataModel,
        getStatus: getStatus ?? this.getStatus,
        postStatus: postStatus ?? this.postStatus);
  }
}
