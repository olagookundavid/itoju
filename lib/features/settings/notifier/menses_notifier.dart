import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final mensesProvider =
    StateNotifierProvider<MensesNotifier, MensesState>((ref) {
  return MensesNotifier(ref, ref.read(dioProvider));
});

class MensesNotifier extends StateNotifier<MensesState> {
  MensesNotifier(this.ref, this.dio) : super(MensesState.initial());
  Ref ref;
  Dio dio;

  Future<void> getMenses() async {
    state = state.copyWith(getStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.get('user/menses');

      var body = response.data;
      if (response.statusCode == 200) {
        final mensesModel = MensesModel.fromMap(body['menses']);
        state =
            state.copyWith(getStatus: Loader.loaded, mensesModel: mensesModel);
      } else {
        state = state.copyWith(getStatus: Loader.error, error: body["error"]);
      }
    } on DioException catch (e) {
      state = state.copyWith(getStatus: Loader.error, error: e.message);
    } catch (e) {
      state = state.copyWith(
          getStatus: Loader.error, error: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse> updateMenses(int periodLen, int cycleLen) async {
    state = state.copyWith(postStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.put('user/menses', data: {
        "period_len": periodLen,
        "cycle_len": cycleLen,
      });

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(postStatus: Loader.loaded);
        return ApiResponse(successMessage: body['message']);
      } else {
        state = state.copyWith(postStatus: Loader.error, error: body["error"]);
        return ApiResponse(
            errorMessage: body['error'], statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      state = state.copyWith(postStatus: Loader.error);
      return AppException.handleError(e);
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

class MensesModel {
  final int? periodLen;
  final int? cycleLen;

  MensesModel({
    required this.periodLen,
    required this.cycleLen,
  });

  factory MensesModel.fromMap(Map<String, dynamic> data) {
    return MensesModel(
      periodLen: data['period_len'] ?? 0,
      cycleLen: data['cycle_len'] ?? 0,
    );
  }
}
