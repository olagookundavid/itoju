import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:itoju_mobile/features/auth/notifiers/login_notifier.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';
import 'package:itoju_mobile/features/widgets/constants.dart';
import 'package:itoju_mobile/services/app_exception.dart';
import 'package:itoju_mobile/services/dio_provider.dart';

final registerProvider =
    StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  return RegisterNotifier(ref, ref.read(dioProvider));
});

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier(this.ref, this.dio) : super(RegisterState.initial());

  Ref ref;
  Dio dio;

  Future<ApiResponse> register(
    String fname,
    String lname,
    String email,
    DateTime dob,
    String password,
  ) async {
    state = state.copyWith(loadStatus: Loader.loading);
    final Response response;
    try {
      response = await dio.post('register', data: {
        "first_name": fname,
        "last_name": lname,
        "dob": "${dob.toIso8601String()}Z",
        "email": email,
        "password": password
      });

      var body = response.data;
      if (response.statusCode == 201) {
        state = state.copyWith(loadStatus: Loader.loaded);
        return ApiResponse(
            successMessage: body['message'],
            data: '${body['user']['first_name']}'
                ' ${body['user']['last_name']}');
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

  Future<ApiResponse> registerUpWithGoogle(
    String fname,
    String lname,
    DateTime dob,
  ) async {
    final bool ok;
    final String? idToken;
    (ok, idToken) = await ref.read(oAuthProvider).signInWithGoogle();
    if (!ok || idToken == null || idToken.isEmpty) {
      return ApiResponse(errorMessage: 'Couldn\'t sign up user with Google');
    }
    // Sign-up and sign-in share one verified endpoint: the server creates the
    // account from the verified token + supplied date of birth.
    final res =
        await ref.read(loginNotifier.notifier).socialLogin(idToken, dob: dob);
    // Surface the entered name so the success screen can greet the user (the
    // server response carries the session token, not the name), and carry
    // through the account-switch flag from socialLogin so the sign-up UI can
    // resolve a device linked to a different account before proceeding.
    if (res.successMessage.isNotEmpty) {
      final switchPending =
          res.data is Map && (res.data as Map)['accountSwitch'] == true;
      return ApiResponse(
          successMessage: res.successMessage,
          data: {
            'name': '$fname $lname'.trim(),
            'accountSwitch': switchPending,
          });
    }
    return res;
  }

  Future<ApiResponse> registerUpWithFB(
    String fname,
    String lname,
    DateTime dob,
  ) async {
    return ApiResponse(
        errorMessage: 'Facebook sign up is not available yet');
  }

  Future<ApiResponse> registerUpWithApple(
    String fname,
    String lname,
    DateTime dob,
  ) async {
    return ApiResponse(errorMessage: 'Apple sign up is not available yet');
  }
}

class RegisterState {
  RegisterState({
    this.loadStatus,
  });

  Loader? loadStatus;

  factory RegisterState.initial() {
    return RegisterState();
  }

  RegisterState copyWith({
    Loader? loadStatus,
  }) {
    return RegisterState(
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }
}

final oAuthProvider = Provider<OAuthService>((ref) {
  return OAuthService();
});

class OAuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<(bool, String?)> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      // Check if user canceled the sign-in
      if (googleSignInAccount == null) {
        return (false, "Sign in canceled");
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      UserCredential result =
          await firebaseAuth.signInWithCredential(credential);

      // Return the Firebase ID token (a signed JWT). The backend verifies this
      // against Google's public keys — we never send a bare, unverifiable email.
      final String? idToken = await result.user?.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        return (false, "Couldn't obtain Google identity token");
      }
      return (true, idToken);
    } catch (e) {
      debugPrint(e.toString());

      if (e is PlatformException) {
        if (e.code == 'sign_in_failed') {
          return (false, "Configuration error - check Google Cloud Console");
        }
      }
      return (false, null);
    }
  }

}
