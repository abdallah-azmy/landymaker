import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app-wide [ThemeMode] (light / dark / system).
class ThemeCubit extends Cubit<ThemeMode> {
  static const _key = 'theme_mode';

  ThemeCubit() : super(ThemeMode.dark);

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(newMode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, newMode.name);
    } catch (e) {
      debugPrint("Failed to save theme preference: $e");
    }
  }

  void setThemeMode(ThemeMode mode) {
    emit(mode);
    try {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(_key, mode.name);
      });
    } catch (e) {
      debugPrint("Failed to save theme preference: $e");
    }
  }

  Future<void> loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved != null) {
        emit(saved == 'light' ? ThemeMode.light : ThemeMode.dark);
      } else {
        emit(ThemeMode.dark);
      }
    } catch (e) {
      debugPrint("Failed to load theme preference, defaulting to dark: $e");
      emit(ThemeMode.dark);
    }
  }
}
