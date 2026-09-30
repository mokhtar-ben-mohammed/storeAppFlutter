import 'package:dio/dio.dart';
import 'package:store/core/errors/failures.dart';
import 'package:store/core/exceptions/app_exceptions.dart';
import 'package:store/core/network/api_response_parser.dart';

/// Normalizes network and HTTP errors into domain [Failure] instances.
class NetworkExceptions {
  const NetworkExceptions._();

  static Failure handle(Object error) {
    if (error is ApiException) {
      return _fromStatus(error.message, error.statusCode, error.code);
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkFailure('Connection timeout. Please check your internet connection.');

        case DioExceptionType.connectionError:
          return const NetworkFailure('No internet connection. Please verify your network.');

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          String message = 'Server error occurred';
          String? code;

          if (responseData is Map<String, dynamic>) {
            message = (responseData['message'] as String?) ??
                (responseData['error'] as String?) ??
                message;
            code = responseData['code'] as String?;
          }

          return _fromStatus(message, statusCode, code);

        case DioExceptionType.cancel:
          return const NetworkFailure('Request was cancelled.');

        case DioExceptionType.badCertificate:
          return const NetworkFailure('Security certificate validation failed.');

        case DioExceptionType.unknown:
        default:
          return NetworkFailure(error.message ?? 'Unknown network error.');
      }
    }

    if (error is AppException) {
      return _fromStatus(error.message, error.statusCode, error.code);
    }

    return UnknownFailure(error.toString());
  }

  static Failure _fromStatus(String message, int? statusCode, String? code) {
    if (statusCode == 401 || statusCode == 403) {
      return AuthenticationFailure(message, statusCode, code);
    }
    if (statusCode == 422 || statusCode == 400) {
      return ValidationFailure(message, statusCode, code);
    }
    return ServerFailure(message, statusCode, code);
  }
}
