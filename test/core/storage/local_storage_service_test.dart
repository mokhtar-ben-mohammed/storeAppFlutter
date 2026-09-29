import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/core/storage/local_storage_service_impl.dart';

void main() {
  late LocalStorageServiceImpl storageService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'test_key': 'test_value',
      'bool_key': true,
      'int_key': 42,
    });
    final prefs = await SharedPreferences.getInstance();
    storageService = LocalStorageServiceImpl(prefs);
  });

  group('LocalStorageService', () {
    test('reads stored string value', () {
      expect(storageService.getString('test_key'), equals('test_value'));
    });

    test('writes and reads string value', () async {
      final success = await storageService.setString('new_key', 'burhan_app');
      expect(success, isTrue);
      expect(storageService.getString('new_key'), equals('burhan_app'));
    });

    test('reads stored bool value', () {
      expect(storageService.getBool('bool_key'), isTrue);
    });

    test('removes key successfully', () async {
      await storageService.remove('test_key');
      expect(storageService.containsKey('test_key'), isFalse);
    });

    test('clears all preferences', () async {
      await storageService.clear();
      expect(storageService.containsKey('bool_key'), isFalse);
      expect(storageService.containsKey('int_key'), isFalse);
    });
  });
}
