import 'dart:ui' show Color;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/landing_page_theme.dart';

class BuilderThemeCubit extends Cubit<LandingPageTheme> {
  BuilderThemeCubit() : super(LandingPageTheme.defaultDark());

  void updateTheme(LandingPageTheme theme) {
    emit(theme);
  }

  void updateThemeProperty(String key, dynamic value) {
    final currentTheme = state;

    LandingPageTheme newTheme;

    if (value is Color) {
      switch (key) {
        case 'primary':
          newTheme = currentTheme.copyWith(primary: value);
          break;
        case 'secondary':
          newTheme = currentTheme.copyWith(secondary: value);
          break;
        case 'background':
          newTheme = currentTheme.copyWith(background: value);
          break;
        case 'textPrimary':
          newTheme = currentTheme.copyWith(textPrimary: value);
          break;
        case 'textSecondary':
          newTheme = currentTheme.copyWith(textSecondary: value);
          break;
        case 'buttonTextColor':
        case 'button_text_color':
          newTheme = currentTheme.copyWith(buttonTextColor: value);
          break;
        default:
          return;
      }
    } else if (value is String || value == null) {
      switch (key) {
        case 'defaultFont':
          newTheme = currentTheme.copyWith(defaultFont: value as String?);
          break;
        case 'globalBgImageUrl':
          newTheme = currentTheme.copyWith(
            globalBgImageUrl: value as String?,
            clearBgImage: value == null,
          );
          break;
        case 'globalBgColorHex':
          newTheme = currentTheme.copyWith(
            globalBgColorHex: value as String?,
            clearBgColor: value == null,
          );
          break;
        default:
          return;
      }
    } else {
      return;
    }

    emit(newTheme);
  }

  void replaceTheme(LandingPageTheme theme) {
    emit(theme);
  }
}
