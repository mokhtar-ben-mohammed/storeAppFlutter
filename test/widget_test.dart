import 'package:flutter_test/flutter_test.dart';
import 'package:store/core/constants/app_constants.dart';

void main() {
  test('AppConstants smoke test', () {
    expect(AppConstants.appName, equals('Burhan'));
    expect(AppConstants.otpLength, equals(6));
    expect(AppConstants.defaultLanguage, equals('ar'));
  });
}
