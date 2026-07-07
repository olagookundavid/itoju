import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final addSmileyProvider =
    StateNotifierProvider<AddSmileyNotifier, AddSmileyState>((ref) {
  return AddSmileyNotifier(ref, ref.read(dioProvider));
});

class AddSmileyNotifier extends StateNotifier<AddSmileyState> {
  AddSmileyNotifier(this.ref, this.dio) : super(AddSmileyState.initial());

  Ref ref;
  Dio dio;

  Future<ApiResponse> addSmiley(int id, List tags, DateTime dateTime) async {
    state = state.copyWith(loadStatus: Loader.loading);
    final Response response;

    try {
      String date = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
      response = await dio.post('user/smileys', data: {
        "smiley_id": id,
        "tags": tags,
        "date": date,
      });
      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(loadStatus: Loader.loaded);
        return ApiResponse(
          successMessage: body["message"],
        );
      } else {
        state = state.copyWith(loadStatus: Loader.error);
        return ApiResponse(
          errorMessage: body["error"],
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

class AddSmileyState {
  AddSmileyState({
    this.loadStatus,
  });

  Loader? loadStatus;

  factory AddSmileyState.initial() {
    return AddSmileyState();
  }

  AddSmileyState copyWith({
    Loader? loadStatus,
  }) {
    return AddSmileyState(
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }
}
