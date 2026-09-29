import 'package:dio/dio.dart';
import 'package:store/core/constants/app_constants.dart';
import 'package:store/core/constants/storage_keys.dart';
import 'package:store/core/storage/local_storage_service.dart';

/// Interceptor that attaches the current language to the `Accept-Language` header.
class LanguageInterceptor extends Interceptor {
  LanguageInterceptor(this._storageService);

  final LocalStorageService _storageService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final language = _storageService.getString(StorageKeys.languageCode) ?? AppConstants.defaultLanguage;
    options.headers['Accept-Language'] = language;
    return handler.next(options);
  }
}
