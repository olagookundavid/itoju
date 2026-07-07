import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/logger.dart';
import 'package:itoju_mobile/core/Storage/secure_store.dart';
import 'package:itoju_mobile/core/auth/session.dart';
import 'package:itoju_mobile/features/auth/pages/login.dart';
import 'package:itoju_mobile/main.dart';

///
final dioProvider = Provider((ref) {
  final dio = Dio();
  dio.options.baseUrl = prodUrl;
  dio.options.headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };
  dio.interceptors.add(AppInterceptor());
  return dio;
});

// const String prodUrl = 'https://testy-crysta-davidoh-428d6753.koyeb.app/v1/';
// const String prodUrl = 'http://localhost:8080/v1/';
const String prodUrl = 'http://10.0.2.2:8080/v1/';

final idioProvider = Provider.autoDispose((_) {
  final dio = Dio();
  dio.options.baseUrl = prodUrl;
  dio.options.headers = {"Content-Type": "multipart/form-data"};
  dio.interceptors.add(AppInterceptor());
  return dio;
});

class AppInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.sendTimeout = const Duration(seconds: 30);
    options.connectTimeout = const Duration(seconds: 30);
    options.receiveTimeout = const Duration(seconds: 30);
    debugLog(options.baseUrl + options.path);
    final token = await SecureStore.read(SecureKeys.token) ?? '';
    // Only attach the auth header when we actually have a token, so
    // unauthenticated calls don't send an empty "Bearer ".
    if (token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Always forward the response; the previous status-code guard could drop
    // it and hang the request until timeout.
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugLog(err);
    // A 401 on a request that carried an auth token means the session token is
    // expired/revoked → clear it and bounce to login. We check for the header
    // so a failed *login* attempt (also 401) doesn't trigger this.
    if (err.response?.statusCode == 401 &&
        err.requestOptions.headers.containsKey('Authorization')) {
      _handleUnauthorized();
    }
    super.onError(err, handler);
  }

  static bool _bouncing = false;
  Future<void> _handleUnauthorized() async {
    if (_bouncing) return;
    _bouncing = true;
    await Session.clearLocal();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInPage()),
      (route) => false,
    );
    _bouncing = false;
  }
}
