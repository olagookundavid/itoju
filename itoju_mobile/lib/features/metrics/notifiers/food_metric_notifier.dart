import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final foodMetricProvider =
    StateNotifierProvider<FoodMetricNotifier, FoodMetricState>((ref) {
  return FoodMetricNotifier(ref, ref.read(dioProvider));
});

class FoodMetricNotifier extends StateNotifier<FoodMetricState> {
  FoodMetricNotifier(this.ref, this.dio) : super(FoodMetricState.initial());
  Ref ref;
  Dio dio;

  Future<void> getFoodMetric(String date) async {
    state = state.copyWith(status: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/food_metrics/$date');

      var body = response.data;
      if (response.statusCode == 200) {
        final foodModel = body['foodMetric'] == null
            ? FoodMetricModel(
                id: 0,
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
                snackTags: [])
            : FoodMetricModel.fromMap(body['foodMetric']);
        state = state.copyWith(status: Loader.loaded, foodModel: foodModel);
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

  Future<ApiResponse> updateFoodMetricMetric(
      String date, FoodMetricModel model) async {
    state = state.copyWith(postStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.put('user/food_metrics/$date', data: {
        "breakfast_meal": model.breakfastMeal,
        "lunch_meal": model.lunchMeal,
        "dinner_meal": model.dinnerMeal,
        "breakfast_extra": model.breakfastExtra,
        "lunch_extra": model.lunchExtra,
        "dinner_extra": model.dinnerExtra,
        "breakfast_fruit": model.breakfastFruit,
        "lunch_fruit": model.lunchFruit,
        "dinner_fruit": model.dinnerFruit,
        "breakfast_tags": model.breakfastTags,
        "lunch_tags": model.lunchTags,
        "dinner_tags": model.dinnerTags,
        "snack_name": model.snackName,
        "snack_tags": model.snackTags,
        "glass_no": model.glassNo
      });

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(postStatus: Loader.loaded);
        // getFoodMetric(date);
        return ApiResponse(successMessage: body['message']);
      } else {
        state = state.copyWith(postStatus: Loader.error, error: body["error"]);
        return ApiResponse(
            errorMessage: body['error'], statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      state = state.copyWith(postStatus: Loader.error, error: e.message);
      return AppException.handleError(e);
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

class FoodMetricModel {
  final int? id;
  final String? breakfastMeal;
  final String? lunchMeal;
  final String? dinnerMeal;
  final String? breakfastExtra;
  final String? lunchExtra;
  final String? dinnerExtra;
  final String? breakfastFruit;
  final String? lunchFruit;
  final String? dinnerFruit;
  final String? snackName;
  final List? breakfastTags;
  final List? lunchTags;
  final List? dinnerTags;
  final List? snackTags;
  final int? glassNo;

  factory FoodMetricModel.fromMap(Map<String, dynamic> data) {
    return FoodMetricModel(
        id: data['id'] ?? 0,
        breakfastExtra: data['breakfast_extra'] ?? '',
        breakfastTags: data['breakfast_tags'] ?? [],
        breakfastFruit: data['breakfast_fruit'] ?? '',
        breakfastMeal: data['breakfast_meal'] ?? '',
        dinnerExtra: data['dinner_extra'] ?? '',
        dinnerFruit: data['dinner_fruit'] ?? '',
        dinnerMeal: data['dinner_meal'] ?? '',
        dinnerTags: data['dinner_tags'] ?? [],
        glassNo: data['glass_no'] ?? 0,
        lunchExtra: data['lunch_extra'] ?? '',
        lunchFruit: data['lunch_fruit'] ?? '',
        lunchMeal: data['lunch_meal'] ?? '',
        lunchTags: data['lunch_tags'] ?? [],
        snackName: data['snack_name'] ?? '',
        snackTags: data['snack_tags'] ?? []);
  }
  FoodMetricModel({
    this.breakfastMeal,
    this.lunchMeal,
    this.dinnerMeal,
    this.breakfastExtra,
    this.lunchExtra,
    this.dinnerExtra,
    this.breakfastFruit,
    this.lunchFruit,
    this.dinnerFruit,
    this.snackName,
    this.breakfastTags,
    this.lunchTags,
    this.dinnerTags,
    this.snackTags,
    this.glassNo,
    required this.id,
  });
}
