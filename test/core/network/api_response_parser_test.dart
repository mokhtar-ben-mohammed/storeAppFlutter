import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store/core/network/api_response_parser.dart';

void main() {
  group('ApiResponseParser', () {
    test('requireDataMap returns data object on success envelope', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 200,
        data: {
          'success': true,
          'code': 'OTP_SENT',
          'message': 'تم الإرسال',
          'data': {'phone': '770000000', 'country_code': '+967'},
        },
      );

      final data = ApiResponseParser.requireDataMap(response);

      expect(data['phone'], '770000000');
      expect(data['country_code'], '+967');
    });

    test('requireSuccessData throws ApiException when success is false', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 422,
        data: {
          'success': false,
          'code': 'VALIDATION_ERROR',
          'message': 'يرجى التحقق من البيانات المدخلة.',
          'data': null,
          'errors': {
            'phone': ['رقم الهاتف مطلوب.'],
          },
        },
      );

      expect(
        () => ApiResponseParser.requireSuccessData(response),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'VALIDATION_ERROR')
              .having((e) => e.message, 'message', 'يرجى التحقق من البيانات المدخلة.'),
        ),
      );
    });

    test('requireDataList parses countries array', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/countries'),
        statusCode: 200,
        data: {
          'success': true,
          'code': 'SUCCESS',
          'message': 'ok',
          'data': [
            {
              'id': 1,
              'name_ar': 'اليمن',
              'name_en': 'Yemen',
              'iso2': 'YE',
              'dial_code': '+967',
            },
          ],
        },
      );

      final list = ApiResponseParser.requireDataList(response);
      expect(list, hasLength(1));
      expect((list.first as Map)['dial_code'], '+967');
    });
  });
}
