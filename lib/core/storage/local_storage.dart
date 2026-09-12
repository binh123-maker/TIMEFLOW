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
