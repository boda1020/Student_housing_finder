import 'package:flutter/material.dart';

const _lightBg = Color(0xFFF8F9FA);
const _lightCard = Colors.white;
const _lightText = Color(0xFF1A1D21);
const _lightTextDim = Color(0xFF6C757D);
const _blueAccent = Color(0xFF2979FF);

final ThemeData appLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: _lightBg,
  colorScheme: const ColorScheme.light(
    primary: _blueAccent,
    surface: _lightCard,
    onSurface: _lightText,
    onPrimary: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: _lightBg,
    elevation: 0,
    iconTheme: IconThemeData(color: _lightText),
    titleTextStyle: TextStyle(color: _lightText, fontSize: 18, fontWeight: FontWeight.bold),
  ),
  cardTheme: CardThemeData(
    color: _lightCard,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFE9ECEF)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    hintStyle: const TextStyle(color: _lightTextDim, fontSize: 14),
    prefixIconColor: _lightTextDim,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _blueAccent, width: 1.5),
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: _lightText, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: _lightText),
    bodySmall: TextStyle(color: _lightTextDim),
  ),
);
