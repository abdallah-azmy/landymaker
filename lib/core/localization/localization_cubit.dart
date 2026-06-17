import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'translations_ar.dart';
import 'translations_en.dart';

class LocalizationCubit extends Cubit<Locale> {
  LocalizationCubit() : super(const Locale('ar')); // Default is Arabic

  bool get isRtl => state.languageCode == 'ar';

  void toggleLanguage() {
    emit(state.languageCode == 'ar' ? const Locale('en') : const Locale('ar'));
  }

  void setLocale(String langCode) {
    if (langCode == 'ar' || langCode == 'en') {
      emit(Locale(langCode));
    }
  }

  String translate(String key) {
    if (state.languageCode == 'ar') {
      return translationsAr[key] ?? key;
    } else {
      return translationsEn[key] ?? key;
    }
  }
}

extension LocalizationExtension on BuildContext {
  String translate(String key) {
    return BlocProvider.of<LocalizationCubit>(this).translate(key);
  }

  bool get isRtl {
    return BlocProvider.of<LocalizationCubit>(this).isRtl;
  }
}
