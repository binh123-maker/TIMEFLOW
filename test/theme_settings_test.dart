import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/core/constants/app_constants.dart';
import 'package:timeflow/core/storage/local_storage.dart';
import 'package:timeflow/core/theme/theme_provider.dart';

void main() {
  group('Persistent Theme Settings Unit Tests', () {
    test('1. Default theme is ThemeMode.system when storage is empty', () {
      final storage = MemoryLocalStorage();
      final notifier = ThemeNotifier(storage);

      expect(notifier.state, equals(ThemeMode.system));
      expect(storage.getString(AppConstants.keyThemeMode), isNull);
    });

    test(
      '2. Changing theme mode to Dark saves to storage and updates state',
      () async {
        final storage = MemoryLocalStorage();
        final notifier = ThemeNotifier(storage);

        await notifier.setThemeMode(ThemeMode.dark);

        expect(notifier.state, equals(ThemeMode.dark));
        expect(storage.getString(AppConstants.keyThemeMode), equals('dark'));
      },
    );

    test(
      '3. Changing theme mode to Light saves to storage and updates state',
      () async {
        final storage = MemoryLocalStorage();
        final notifier = ThemeNotifier(storage);

        await notifier.setThemeMode(ThemeMode.light);

        expect(notifier.state, equals(ThemeMode.light));
        expect(storage.getString(AppConstants.keyThemeMode), equals('light'));
      },
    );

    test(
      '4. Initializing with existing stored Dark mode restores Dark theme',
      () {
        final storage = MemoryLocalStorage();
        storage.setString(AppConstants.keyThemeMode, 'dark');

        final notifier = ThemeNotifier(storage);

        expect(notifier.state, equals(ThemeMode.dark));
      },
    );

    test(
      '5. Initializing with existing stored Light mode restores Light theme',
      () {
        final storage = MemoryLocalStorage();
        storage.setString(AppConstants.keyThemeMode, 'light');

        final notifier = ThemeNotifier(storage);

        expect(notifier.state, equals(ThemeMode.light));
      },
    );

    test(
      '6. Corrupted or invalid stored theme string safely falls back to System mode',
      () {
        final storage = MemoryLocalStorage();
        storage.setString(
          AppConstants.keyThemeMode,
          'INVALID_UNKNOWN_MODE_xyz',
        );

        final notifier = ThemeNotifier(storage);

        expect(notifier.state, equals(ThemeMode.system));
      },
    );

    test(
      '7. Toggle theme switches between Dark and Light and updates storage',
      () async {
        final storage = MemoryLocalStorage();
        final notifier = ThemeNotifier(storage);

        // Default system -> toggle -> dark
        await notifier.toggleTheme();
        expect(notifier.state, equals(ThemeMode.dark));
        expect(storage.getString(AppConstants.keyThemeMode), equals('dark'));

        // Dark -> toggle -> light
        await notifier.toggleTheme();
        expect(notifier.state, equals(ThemeMode.light));
        expect(storage.getString(AppConstants.keyThemeMode), equals('light'));
      },
    );

    test(
      '8. Riverpod Provider integration with overridden LocalStorage',
      () async {
        final storage = MemoryLocalStorage();
        await storage.setString(AppConstants.keyThemeMode, 'dark');

        final container = ProviderContainer(
          overrides: [localStorageProvider.overrideWithValue(storage)],
        );
        addTearDown(container.dispose);

        final theme = container.read(themeModeProvider);
        expect(theme, equals(ThemeMode.dark));

        // Update via provider notifier
        await container
            .read(themeModeProvider.notifier)
            .setThemeMode(ThemeMode.light);
        expect(container.read(themeModeProvider), equals(ThemeMode.light));
        expect(storage.getString(AppConstants.keyThemeMode), equals('light'));
      },
    );
  });
}
