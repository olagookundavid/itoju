import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/biometric_helper.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/auth/notifiers/signup_notifier.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'dart:async';

import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';
import 'package:itoju_mobile/core/Storage/storage_class.dart';
import 'package:itoju_mobile/core/Storage/secure_store.dart';
import 'package:itoju_mobile/data/providers.dart';
import 'package:itoju_mobile/sync/purchase_service.dart';
import 'package:itoju_mobile/sync/sync_controller.dart';
import 'package:itoju_mobile/sync/sync_engine.dart';

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
        final switchPending = await _activateSync(body['user_id'] as String?);
        state = state.copyWith(
          loadStatus: Loader.loaded,
        );
        return ApiResponse(
            successMessage: body['message'],
            data: {'accountSwitch': switchPending});
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
        final switchPending = await _activateSync(body['user_id'] as String?);
        state = state.copyWith(loadStatus: Loader.loaded);
        return ApiResponse(
            successMessage: body['message'],
            data: {'accountSwitch': switchPending});
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

  /// After a successful sign-in, bind the local account to the server user
  /// (so deterministic ids re-key on first sync), refresh the cached sync
  /// entitlement, and kick off a sync. All best-effort — never blocks login.
  ///
  /// Returns true when a DIFFERENT server user than the one this device's data
  /// is bound to just signed in. In that case nothing is bound and the engine
  /// refuses to sync (so the two users' health data cannot mix) until the
  /// caller resolves the switch — [confirmAccountSwitch] erases the previous
  /// user's local data and continues, or the user signs out.
  Future<bool> _activateSync(String? serverUserId) async {
    if (serverUserId == null || serverUserId.isEmpty) return false;
    await SecureStore.write(SecureKeys.currentServerUserId, serverUserId);
    final bound = await SecureStore.read(SecureKeys.boundServerUserId);
    if (bound != null && bound.isNotEmpty && bound != serverUserId) {
      return true; // switch pending — do not bind, engine refuses to sync
    }
    await SecureStore.write(SecureKeys.boundServerUserId, serverUserId);
    // Bind RevenueCat purchases to the server user (no-op unless IAP is
    // configured); the webhook re-binds the subscription server-side.
    await ref.read(purchaseServiceProvider).bindTo(serverUserId);
    await ref.read(entitlementServiceProvider).refreshFromServer();
    // Fire-and-forget through the controller so lastSyncAt is stamped; the
    // engine catches its own errors and re-keys on first run.
    unawaited(ref.read(syncControllerProvider).backupNow());
    return false;
  }

  /// Resolves an account switch by erasing the previous user's local health
  /// data and binding this device to the newly signed-in user. The wipe is the
  /// privacy-correct default on a shared device: the new user must not see —
  /// or upload under their account — someone else's health records.
  Future<void> confirmAccountSwitch() async {
    final serverUserId =
        await SecureStore.read(SecureKeys.currentServerUserId);
    if (serverUserId == null || serverUserId.isEmpty) return;
    await ref.read(appDatabaseProvider).eraseAllUserData();
    // Drop the previous user's cached names so the new user isn't greeted by
    // (or prefilled with) the old name — NameStep re-collects from the new
    // account.
    await HiveStorage.delete(HiveKeys.localName);
    await HiveStorage.delete(HiveKeys.userName);
    // Fresh local identity for the new user; nothing left to re-key.
    await SecureStore.write(SecureKeys.localAccountId, null);
    await SecureStore.write(SecureKeys.boundServerUserId, serverUserId);
    await ref.read(purchaseServiceProvider).bindTo(serverUserId);
    await ref.read(entitlementServiceProvider).refreshFromServer();
    unawaited(ref.read(syncControllerProvider).backupNow());
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
