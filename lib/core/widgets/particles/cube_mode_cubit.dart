import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CubeMode { standard, merge, orbit }

class CubeModeCubit extends Cubit<CubeMode> {
  static const _key = 'cube_mode';

  CubeModeCubit() : super(CubeMode.standard);

  Future<void> toggleMode() async {
    final nextMode = switch (state) {
      CubeMode.standard => CubeMode.merge,
      CubeMode.merge => CubeMode.orbit,
      CubeMode.orbit => CubeMode.standard,
    };
    emit(nextMode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, nextMode.name);
    } catch (e) {
      debugPrint("Failed to save cube mode preference: $e");
    }
  }

  Future<void> loadSavedMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved != null) {
        emit(CubeMode.values.firstWhere(
          (m) => m.name == saved,
          orElse: () => CubeMode.standard,
        ));
      }
    } catch (e) {
      debugPrint("Failed to load cube mode preference: $e");
    }
  }
}
