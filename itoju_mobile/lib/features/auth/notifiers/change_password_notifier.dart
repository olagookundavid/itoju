import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/Storage/secure_store.dart';
import 'package:itoju_mobile/core/auth/session.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';

final changePasswordNotifier =
    StateNotifierProvider<ChangePasswordNotifier, ChangePasswordState>((ref) {
  return ChangePasswordNotifier(ref, ref.read(dioProvider));
});

class ChangePasswordNotifier extends StateNotifier<ChangePasswordState> {
  ChangePasswordNotifier(this.ref, this.dio)
      : super(ChangePasswordState.initial());

  Ref ref;
  Dio dio;

  Future<ApiResponse> changePassword(String currentPassword, String newPassword,
      String confirmPassword) async {
    state = state.copyWith(loadStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.put('users/change-password', data: {
        "password": currentPassword,
        "new_password": newPassword,
        "confirm_new_password": confirmPassword,
      });

      var body = response.data;
      if (response.statusCode == 200) {
        // Keep the biometric sign-in credential in step with the new password
        // (only if the user opted in; otherwise nothing is stored).
        if (Session.isBiometricLoginEnabled()) {
          await SecureStore.write(SecureKeys.password, newPassword);
        }
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

class ChangePasswordState {
  ChangePasswordState({this.loadStatus});

  Loader? loadStatus;

  factory ChangePasswordState.initial() {
    return ChangePasswordState();
  }

  ChangePasswordState copyWith({
    Loader? loadStatus,
  }) {
    return ChangePasswordState(loadStatus: loadStatus ?? this.loadStatus);
  }
}
