import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/data/models/food_model.dart';
import 'package:itoju_mobile/data/repositories/food_repository.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

export 'package:itoju_mobile/data/models/food_model.dart';

final foodMetricProvider =
    StateNotifierProvider<FoodMetricNotifier, FoodMetricState>((ref) {
  return FoodMetricNotifier(ref, ref.read(foodRepositoryProvider));
});

/// Offline-first food notifier. Same public surface as before; reads/writes the
/// local Drift store through FoodRepository (deterministic one-per-day row).
class FoodMetricNotifier extends StateNotifier<FoodMetricState> {
  FoodMetricNotifier(this.ref, this.repo) : super(FoodMetricState.initial());
  Ref ref;
  FoodRepository repo;

  Future<void> getFoodMetric(String date) async {
    state = state.copyWith(status: Loader.loading);
    try {
      final existing = await repo.getForDate(date);
      final foodModel = existing ??
          FoodMetricModel(
            id: null,
            breakfastMeal: '',
            breakfastTags: [],
            breakfastExtra: '',
            breakfastFruit: '',
            dinnerExtra: '',
            dinnerFruit: '',
            dinnerMeal: '',
            dinnerTags: [],
            glassNo: 0,
            lunchExtra: '',
            lunchFruit: '',
            lunchMeal: '',
            lunchTags: [],
            snackName: '',
            snackTags: [],
          );
      state = state.copyWith(status: Loader.loaded, foodModel: foodModel);
    } catch (e) {
      state = state.copyWith(
          status: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> updateFoodMetricMetric(
      String date, FoodMetricModel model) async {
    state = state.copyWith(postStatus: Loader.loading);
    try {
      await repo.upsert(date, model);
      state = state.copyWith(postStatus: Loader.loaded);
      return ApiResponse(successMessage: 'Successfully saved food diary');
    } catch (e) {
      state = state.copyWith(
          postStatus: Loader.error, error: 'An unexpected error occurred');
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }
}

class FoodMetricState {
  FoodMetricModel? foodModel;
  Loader? status;
  Loader? postStatus;

  FoodMetricState({
    this.foodModel,
    this.status = Loader.loading,
    this.postStatus = Loader.loaded,
  });
  factory FoodMetricState.initial() {
    return FoodMetricState();
  }

  FoodMetricState copyWith(
      {FoodMetricModel? foodModel,
      Loader? status,
      Loader? postStatus,
      String? error}) {
    return FoodMetricState(
        foodModel: foodModel ?? this.foodModel,
        status: status ?? this.status,
        postStatus: postStatus ?? this.postStatus);
  }
}
