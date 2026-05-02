import 'package:flutter/material.dart';

const _primaryColor = Color(0xFF5C61F2); // الـ Indigo بتاعنا الأساسي
const _lightBg = Color(0xFFF8F9FE);
const _lightCard = Colors.white;
const _lightText = Color(0xFF1A1A1A);
const _lightTextDim = Color(0xFF7D7D7D);

final ThemeData appLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: _lightBg,
  primaryColor: _primaryColor,
  colorScheme: const ColorScheme.light(
    primary: _primaryColor,
    secondary: _primaryColor,
    surface: _lightCard,
    onSurface: _lightText,
    onPrimary: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: _lightBg,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: _primaryColor),
    titleTextStyle: TextStyle(color: _primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
  ),
  cardTheme: CardThemeData(
    color: _lightCard,
    elevation: 2,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    hintStyle: const TextStyle(color: _lightTextDim, fontSize: 14),
    prefixIconColor: _primaryColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: _primaryColor.withOpacity(0.1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: _primaryColor.withOpacity(0.1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _primaryColor, width: 1.5),
    ),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(color: _lightText, fontWeight: FontWeight.bold, fontSize: 24),
    titleLarge: TextStyle(color: _lightText, fontWeight: FontWeight.bold, fontSize: 20),
    bodyLarge: TextStyle(color: _lightText, fontSize: 16),
    bodyMedium: TextStyle(color: _lightText, fontSize: 14),
    bodySmall: TextStyle(color: _lightTextDim, fontSize: 12),
  ),
);
