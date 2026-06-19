import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CubeMode { standard, merge }

class CubeModeCubit extends Cubit<CubeMode> {
  static const _key = 'cube_mode';

  CubeModeCubit() : super(CubeMode.standard);

  bool get isMergeMode => state == CubeMode.merge;

  Future<void> toggleMode() async {
    final newMode =
        state == CubeMode.standard ? CubeMode.merge : CubeMode.standard;
    emit(newMode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, newMode.name);
    } catch (e) {
      debugPrint("Failed to save cube mode preference: $e");
    }
  }

  Future<void> loadSavedMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (saved != null) {
        emit(saved == 'merge' ? CubeMode.merge : CubeMode.standard);
      }
    } catch (e) {
      debugPrint("Failed to load cube mode preference: $e");
    }
  }
}
