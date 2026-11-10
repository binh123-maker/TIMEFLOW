import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';

/// StateNotifier to manage ThemeMode (System, Light, Dark) with persistence
class ThemeNotifier extends StateNotifier<ThemeMode> {
  final LocalStorage? _storage;

  ThemeNotifier([this._storage]) : super(_initialThemeMode(_storage));

  static ThemeMode _initialThemeMode(LocalStorage? storage) {
    if (storage == null) return ThemeMode.system;
    final savedMode = storage.getString(AppConstants.keyThemeMode);
    if (savedMode == null) return ThemeMode.system;
    switch (savedMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    if (_storage != null) {
      await _storage.setString(AppConstants.keyThemeMode, mode.name);
    }
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}

/// Provider for app theme mode
final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  final storage = ref.watch(localStorageProvider);
  return ThemeNotifier(storage);
});
