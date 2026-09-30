import 'package:dio/dio.dart';
import 'package:store/core/exceptions/app_exceptions.dart';

/// Parsed Laravel [ApiResponse] envelope: success/code/message/data/errors.
class ApiEnvelope {
  const ApiEnvelope({
    required this.success,
    required this.code,
    required this.message,
    this.data,
    this.errors,
  });

  final bool success;
  final String code;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? errors;
}

/// Thrown when an API envelope reports failure or is malformed.
class ApiException extends AppException {
  const ApiException(
    super.message, [
    super.statusCode,
    super.code,
    this.errors,
  ]);

  final Map<String, dynamic>? errors;
}

/// Shared parser for Queen Admin / Burhan API JSON envelopes.
class ApiResponseParser {
  const ApiResponseParser._();

  static ApiEnvelope parse(dynamic body, {int? statusCode}) {
    if (body is! Map) {
      throw ApiException(
        'Unexpected empty or invalid API response.',
        statusCode,
        'INVALID_RESPONSE',
      );
    }

    final map = Map<String, dynamic>.from(body);
    final success = map['success'] == true;
    final code = (map['code'] ?? (success ? 'SUCCESS' : 'ERROR')).toString();
    final message = (map['message'] as String?)?.trim();
    final errors = map['errors'] is Map
        ? Map<String, dynamic>.from(map['errors'] as Map)
        : null;

    final resolvedMessage = (message != null && message.isNotEmpty)
        ? message
        : _firstErrorMessage(errors) ??
            (success ? 'OK' : 'Request failed.');

    return ApiEnvelope(
      success: success,
      code: code,
      message: resolvedMessage,
      data: map['data'],
      errors: errors,
    );
  }

  /// Parses [response] and returns `data` when `success` is true.
  static dynamic requireSuccessData(Response<dynamic> response) {
    final envelope = parse(response.data, statusCode: response.statusCode);
    if (!envelope.success) {
      throw ApiException(
        envelope.message,
        response.statusCode,
        envelope.code,
        envelope.errors,
      );
    }
    return envelope.data;
  }

  /// Like [requireSuccessData] but asserts `data` is a JSON object.
  static Map<String, dynamic> requireDataMap(Response<dynamic> response) {
    final data = requireSuccessData(response);
    if (data == null) {
      return <String, dynamic>{};
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw ApiException(
      'Unexpected API data shape.',
      response.statusCode,
      'INVALID_RESPONSE',
    );
  }

  /// Like [requireSuccessData] but asserts `data` is a JSON array.
  static List<dynamic> requireDataList(Response<dynamic> response) {
    final data = requireSuccessData(response);
    if (data == null) {
      return <dynamic>[];
    }
    if (data is List) {
      return data;
    }
    throw ApiException(
      'Unexpected API data shape.',
      response.statusCode,
      'INVALID_RESPONSE',
    );
  }

  static String? _firstErrorMessage(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) return null;
    final first = errors.values.first;
    if (first is List && first.isNotEmpty) {
      return first.first.toString();
    }
    return first?.toString();
  }
}
