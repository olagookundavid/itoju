// ignore_for_file: avoid_print

import 'package:dio/dio.dart';

class AppInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // timeout for all requests
    options.sendTimeout = const Duration(seconds: 10);
    options.connectTimeout = const Duration(seconds: 10);
    options.receiveTimeout = const Duration(seconds: 10);
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode! >= 200 && response.statusCode! <= 300) {
      print('Yes Data Gotten Successful');
    }
    return super.onResponse(response, handler);
  }
}
