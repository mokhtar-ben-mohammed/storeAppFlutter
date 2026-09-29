import 'package:dio/dio.dart';
import 'package:store/core/logging/app_logger.dart';

/// Dio interceptor for sanitized logging of HTTP requests, responses, and errors.
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor({required this.enabled});

  final bool enabled;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      AppLogger.debug(
        '--> ${options.method} ${options.uri}\nHeaders: ${options.headers}\nBody: ${options.data}',
        tag: 'HTTP_REQUEST',
      );
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (enabled) {
      AppLogger.debug(
        '<-- ${response.statusCode} ${response.requestOptions.uri}\nData: ${response.data}',
        tag: 'HTTP_RESPONSE',
      );
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      AppLogger.error(
        '<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri}\nMessage: ${err.message}\nData: ${err.response?.data}',
        tag: 'HTTP_ERROR',
        error: err,
      );
    }
    return handler.next(err);
  }
}
