/// Contract for local key-value persistence.
/// Keeps application code completely decoupled from underlying storage implementation (SharedPreferences).
abstract interface class LocalStorageService {
  /// Read a string value.
  String? getString(String key);

  /// Write a string value.
  Future<bool> setString(String key, String value);

  /// Read a boolean value.
  bool? getBool(String key);

  /// Write a boolean value.
  Future<bool> setBool(String key, bool value);

  /// Read an integer value.
  int? getInt(String key);

  /// Write an integer value.
  Future<bool> setInt(String key, int value);

  /// Read a double value.
  double? getDouble(String key);

  /// Write a double value.
  Future<bool> setDouble(String key, double value);

  /// Read a list of strings.
  List<String>? getStringList(String key);

  /// Write a list of strings.
  Future<bool> setStringList(String key, List<String> value);

  /// Check whether [key] exists.
  bool containsKey(String key);

  /// Remove entry by [key].
  Future<bool> remove(String key);

  /// Clear all stored preferences.
  Future<bool> clear();
}
