import 'package:flutter/material.dart';
import '../core/utils/app_constants.dart';

class AppProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.dark;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  bool get isArabic => _locale.languageCode == 'ar';
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleLanguage() {
    _locale = _locale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  String translate(String key) {
    return AppConstants.translations[_locale.languageCode]?[key] ?? key;
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
