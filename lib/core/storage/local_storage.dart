import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Architecture preparation for key-value local storage
abstract class LocalStorage {
  Future<void> setString(String key, String value);
  String? getString(String key);
  Future<void> remove(String key);
}

class MemoryLocalStorage implements LocalStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  String? getString(String key) {
    return _storage[key];
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }
}

/// SharedPreferences implementation of LocalStorage for persistent settings
class SharedPrefsLocalStorage implements LocalStorage {
  final SharedPreferences _prefs;

  SharedPrefsLocalStorage(this._prefs);

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  String? getString(String key) {
    return _prefs.getString(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}

/// LocalStorage provider defaulting to MemoryLocalStorage (overridden in main)
final localStorageProvider = Provider<LocalStorage>((ref) {
  return MemoryLocalStorage();
});
