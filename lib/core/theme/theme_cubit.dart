import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the app-wide [ThemeMode] (light / dark / system).
/// Cubits are intentionally stateless here; preference persistence
/// can be added later via SharedPreferences.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark);

  bool get isDarkMode => state == ThemeMode.dark;

  void toggleTheme() {
    emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void setThemeMode(ThemeMode mode) => emit(mode);
}
