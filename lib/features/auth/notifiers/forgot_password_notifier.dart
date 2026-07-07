import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final forgotPasswordNotifier =
    StateNotifierProvider<ForgotPasswordNotifier, ForgotPassword>((ref) {
  return ForgotPasswordNotifier(ref, ref.read(dioProvider));
});

class ForgotPasswordNotifier extends StateNotifier<ForgotPassword> {
  ForgotPasswordNotifier(this.ref, this.dio) : super(ForgotPassword.initial());

  Ref ref;
  Dio dio;

  // Step 1: request a one-time code. The code is emailed to the user by the
  // backend (via Resend) and is never returned in the response.
  Future<ApiResponse> forgotPassword(
    String email,
  ) async {
    state = state.copyWith(loadStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.post('password-reset', data: {
        "email": email,
      });

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(loadStatus: Loader.loaded, email: email);
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

  // Step 2: verify the code against the backend (server-side, bound to email).
  // The code is only stored locally once the server confirms it is valid.
  Future<ApiResponse> verifyOtp(
    String otp,
  ) async {
    state = state.copyWith(loadStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.post('verify-otp', data: {
        "email": state.email,
        "otp": otp,
      });

      var body = response.data;
      if (response.statusCode == 200) {
        state = state.copyWith(loadStatus: Loader.loaded, otp: otp);
        return ApiResponse(
          successMessage: body["message"] ?? "Successfully verified OTP",
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

  // Step 3: set the new password using email + the verified code.
  Future<ApiResponse> resetPassword(String password) async {
    state = state.copyWith(loadStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.put('users/password', data: {
        "email": state.email,
        "otp": state.otp,
        "password": password,
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

class ForgotPassword {
  ForgotPassword({this.loadStatus, this.email, this.otp});

  Loader? loadStatus;
  String? email;
  String? otp;

  factory ForgotPassword.initial() {
    return ForgotPassword();
  }

  ForgotPassword copyWith({
    Loader? loadStatus,
    String? email,
    String? otp,
  }) {
    return ForgotPassword(
      loadStatus: loadStatus ?? this.loadStatus,
      email: email ?? this.email,
      otp: otp ?? this.otp,
    );
  }
}
