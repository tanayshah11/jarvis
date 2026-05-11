import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/local_storage.dart';

/// Theme mode provider for managing app-wide theme state
/// Persists user preference to local storage.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _storageKey = 'theme_mode';
  late LocalStorage _localStorage;

  @override
  ThemeMode build() {
    _localStorage = ref.watch(localStorageProvider);
    _loadThemeMode();
    return ThemeMode.system;
  }

  Future<void> _loadThemeMode() async {
    final stored = await _localStorage.getSetting(_storageKey);
    if (stored != null) {
      state = _themeModeFromString(stored as String);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _localStorage.saveSetting(_storageKey, _themeModeToString(mode));
  }

  Future<void> toggleTheme() async {
    switch (state) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.system);
        break;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

/// Helper to get the current brightness from theme mode and platform
Brightness resolveThemeBrightness(ThemeMode mode, BuildContext context) {
  switch (mode) {
    case ThemeMode.light:
      return Brightness.light;
    case ThemeMode.dark:
      return Brightness.dark;
    case ThemeMode.system:
      return MediaQuery.platformBrightnessOf(context);
  }
}

/// Provider for resolved brightness based on theme mode and platform
final resolvedBrightnessProvider = Provider.family<Brightness, BuildContext>((ref, context) {
  final themeMode = ref.watch(themeModeProvider);
  return resolveThemeBrightness(themeMode, context);
});
