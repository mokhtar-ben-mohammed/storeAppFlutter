import 'package:dio/dio.dart';
import 'package:store/core/constants/storage_keys.dart';
import 'package:store/core/storage/local_storage_service.dart';

/// Interceptor that attaches the authentication token to outgoing requests.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._storageService);

  final LocalStorageService _storageService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storageService.getString(StorageKeys.authToken);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear invalid session when 401 Unauthorized is returned
      _storageService.remove(StorageKeys.authToken);
      _storageService.remove(StorageKeys.isAuthenticated);
    }
    return handler.next(err);
  }
}
