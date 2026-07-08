import 'package:dio/dio.dart';

class ApiResponse<T> {
  final String successMessage;
  final String errorMessage;
  final DioException? error;
  final String? responseMessage;
  final int? statusCode;
  final T? data;

  ApiResponse(
      {this.errorMessage = 'An error occurred',
      this.successMessage = '',
      this.error,
      this.responseMessage = '',
      this.statusCode,
      this.data});
}
