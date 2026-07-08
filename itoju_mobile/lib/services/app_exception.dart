import 'package:dio/dio.dart';
import 'package:itoju_mobile/core/helpers/logger.dart';
import 'package:itoju_mobile/core/helpers/response_helper/api_response.dart';

class AppException {
  //HANDLE ERROR
  static ApiResponse handleError<T>(e) {
    if (e.response != null) {
      if (e.response!.statusCode! >= 500) {
        return ApiResponse(errorMessage: 'A server error occured');
      } else if (e.response!.statusCode! == 401) {
        return ApiResponse(
            responseMessage: e.response?.data['error'] ??
                'Unauthenticated, Please Log In Again.',
            statusCode: 401);
      } else if (e.response!.statusCode! >= 400) {
        debugLog(e.response?.data);
        return ApiResponse(
            responseMessage: e.response?.data['error'] ?? 'An error occured!',
            statusCode: e.response?.statusCode ?? 400);
      }
    }
    return ApiResponse(
      errorMessage: _mapException(e.type),
    );
  }

  static _mapException(DioExceptionType type) {
    if (DioExceptionType.connectionTimeout == type ||
        DioExceptionType.receiveTimeout == type ||
        DioExceptionType.sendTimeout == type) {
      return "Your connection timed out";
    } else if (DioExceptionType.unknown == type) {
      return "A network error occurred. Please check your connection";
    }
    return "An error occurred!";
  }
}
