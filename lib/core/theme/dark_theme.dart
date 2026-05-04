import 'package:flutter/material.dart';

const _primaryColor = Color(0xFF5C61F2);
const _darkBg = Color(0xFF000000);
const _darkCard = Color(0xFF1A1D23);
const _darkText = Colors.white;
const _darkTextDim = Color(0xFF8B949E);

final ThemeData appDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _darkBg,
  primaryColor: _primaryColor,
  colorScheme: const ColorScheme.dark(
    primary: _primaryColor,
    secondary: _primaryColor,
    surface: _darkCard,
    onSurface: _darkText,
    onPrimary: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: _darkBg,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
  ),
  cardTheme: CardThemeData(
    color: _darkCard,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E2530),
    hintStyle: const TextStyle(color: _darkTextDim, fontSize: 14),
    prefixIconColor: _primaryColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _primaryColor, width: 1.5),
    ),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(color: _darkText, fontWeight: FontWeight.bold, fontSize: 24),
    titleLarge: TextStyle(color: _darkText, fontWeight: FontWeight.bold, fontSize: 20),
    bodyLarge: TextStyle(color: _darkText, fontSize: 16),
    bodyMedium: TextStyle(color: _darkText, fontSize: 14),
    bodySmall: TextStyle(color: _darkTextDim, fontSize: 12),
  ),
);
