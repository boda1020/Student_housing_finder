import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/dark_theme.dart';
import 'core/theme/light_theme.dart';
import 'screens/owner/owner_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prefer dark status bar icons on the dark background.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Housing Finder',
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.dark,
      home: const OwnerDashboardScreen(),
    );
  }
}
