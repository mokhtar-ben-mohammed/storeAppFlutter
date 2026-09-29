import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/core/storage/local_storage_service.dart';

/// Concrete implementation of [LocalStorageService] backed by [SharedPreferences].
class LocalStorageServiceImpl implements LocalStorageService {
  const LocalStorageServiceImpl(this._preferences);

  final SharedPreferences _preferences;

  @override
  String? getString(String key) => _preferences.getString(key);

  @override
  Future<bool> setString(String key, String value) => _preferences.setString(key, value);

  @override
  bool? getBool(String key) => _preferences.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) => _preferences.setBool(key, value);

  @override
  int? getInt(String key) => _preferences.getInt(key);

  @override
  Future<bool> setInt(String key, int value) => _preferences.setInt(key, value);

  @override
  double? getDouble(String key) => _preferences.getDouble(key);

  @override
  Future<bool> setDouble(String key, double value) => _preferences.setDouble(key, value);

  @override
  List<String>? getStringList(String key) => _preferences.getStringList(key);

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _preferences.setStringList(key, value);

  @override
  bool containsKey(String key) => _preferences.containsKey(key);

  @override
  Future<bool> remove(String key) => _preferences.remove(key);

  @override
  Future<bool> clear() => _preferences.clear();
}
