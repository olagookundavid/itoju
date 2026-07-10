import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itoju_mobile/core/helpers/logger.dart';
import 'package:itoju_mobile/core/Storage/secure_store.dart';
import 'package:itoju_mobile/core/auth/session.dart';

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

/// Injected at build time via --dart-define=BASE_URL=...
/// Defaults to the Android-emulator localhost alias for local dev.
const String prodUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://10.0.2.2:8080/v1/',
);

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
    // expired/revoked. Offline-first: we DON'T bounce to login — the app keeps
    // working on local data. We just clear the token so cloud sync pauses until
    // the user re-authenticates. We check for the header so a failed *login*
    // attempt (also 401) doesn't trigger this.
    if (err.response?.statusCode == 401 &&
        err.requestOptions.headers.containsKey('Authorization')) {
      _handleUnauthorized();
    }
    super.onError(err, handler);
  }

  static bool _clearing = false;
  Future<void> _handleUnauthorized() async {
    if (_clearing) return;
    _clearing = true;
    // Clears the session token only; local health data is untouched.
    await Session.clearLocal();
    _clearing = false;
  }
}
