import 'package:flutter/material.dart';

final ThemeData appDarkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF0F1B2A),
  primaryColor: const Color(0xFF0F1B2A),
  cardColor: const Color(0xFF1E2A3A),
  canvasColor: const Color(0xFF0F1B2A),
  dividerColor: Colors.white24,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F1B2A),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E2A3A),
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E2A3A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: Colors.white54),
  ),
);
