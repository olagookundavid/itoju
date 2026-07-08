import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/biometric_helper.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/auth/notifiers/signup_notifier.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/Storage/secure_store.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier(this.ref, this.dio) : super(LoginState.initial(ref));

  final Ref ref;
  final Dio dio;

  Future<ApiResponse> login(String email, String password) async {
    state = state.copyWith(loadStatus: Loader.loading);
    try {
      final formData = {
        'email': email,
        'password': password,
      };
      final response = await dio.post('login', data: formData);
      var body = response.data;
      if (response.statusCode == 200) {
        // Session token and password (for biometric quick-login) go into the
        // OS-encrypted secure store, never the plaintext Hive box.
        await SecureStore.write(SecureKeys.token, body['data']['token']);
        await SecureStore.write(SecureKeys.password, password);
        await HiveStorage.put(HiveKeys.userName, email);
        state = state.copyWith(
          loadStatus: Loader.loaded,
        );
        return ApiResponse(successMessage: body['message']);
      } else {
        state = state.copyWith(loadStatus: Loader.error);
        return ApiResponse(
            errorMessage: body['error'], statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      state = state.copyWith(loadStatus: Loader.error);
      return AppException.handleError(e);
    } catch (e) {
      state = state.copyWith(loadStatus: Loader.error);
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  /// socialLogin sends a verified Firebase ID token to the backend. On first
  /// sign-up the server also needs a date of birth; pass [dob] then. When the
  /// server responds with `registration_required` (a brand-new user logging in
  /// without a dob), the caller is told to route the user through sign-up.
  Future<ApiResponse> socialLogin(String idToken, {DateTime? dob}) async {
    state = state.copyWith(loadStatus: Loader.loading);
    try {
      final formData = {
        'id_token': idToken,
        if (dob != null) 'dob': _formatDob(dob),
      };
      final response = await dio.post('social-login', data: formData);
      var body = response.data;
      if (response.statusCode == 200 &&
          body['data'] != null &&
          body['data']['token'] != null) {
        await SecureStore.write(SecureKeys.token, body['data']['token']);
        state = state.copyWith(loadStatus: Loader.loaded);
        return ApiResponse(successMessage: body['message']);
      } else if (response.statusCode == 200 &&
          body['registration_required'] == true) {
        state = state.copyWith(loadStatus: Loader.error);
        return ApiResponse(
            responseMessage:
                'Please use "Sign up with Google" to create your account first',
            statusCode: 200);
      } else {
        state = state.copyWith(loadStatus: Loader.error);
        return ApiResponse(
            errorMessage: body['error'], statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      state = state.copyWith(loadStatus: Loader.error);
      return AppException.handleError(e);
    } catch (e) {
      state = state.copyWith(loadStatus: Loader.error);
      return ApiResponse(errorMessage: 'An error occurred');
    }
  }

  static String _formatDob(DateTime dob) {
    final m = dob.month.toString().padLeft(2, '0');
    final d = dob.day.toString().padLeft(2, '0');
    return '${dob.year}-$m-$d';
  }

  Future<ApiResponse> loginWithBioMetric(String email, String password) async {
    final isAuthenticated = await LocalAuthApi.authenticate();
    if (isAuthenticated == "success") {
      final response = await login(email, password);
      return response;
    } else {
      return ApiResponse(errorMessage: isAuthenticated);
    }
  }

  Future<ApiResponse> signInWithGoogle() async {
    final bool ok;
    final String? idToken;
    (ok, idToken) = await ref.read(oAuthProvider).signInWithGoogle();
    if (!ok || idToken == null || idToken.isEmpty) {
      return ApiResponse(errorMessage: 'Couldn\'t authenticate with Google');
    }
    return await socialLogin(idToken);
  }

  Future<ApiResponse> signInWithFB() async {
    return ApiResponse(errorMessage: 'Facebook sign in is not available yet');
  }

  Future<ApiResponse> signInWithApple() async {
    return ApiResponse(errorMessage: 'Apple sign in is not available yet');
  }
}

class LoginState {
  LoginState({
    this.loadStatus,
  });

  Loader? loadStatus;

  factory LoginState.initial(Ref ref) {
    return LoginState();
  }

  LoginState copyWith({
    Loader? loadStatus,
  }) {
    return LoginState(loadStatus: loadStatus ?? this.loadStatus);
  }
}

final loginNotifier = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(ref, ref.read(dioProvider)),
);
