import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:student_housing_finder/core/utils/supabase_client.dart';
import 'package:student_housing_finder/screens/splash/splash_screen.dart';
import 'package:student_housing_finder/screens/owner/owner_dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/dark_theme.dart';
import 'core/theme/light_theme.dart';
import 'providers/property_provider.dart';
import 'providers/app_provider.dart';
import 'data/services/auth_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseClientService.initialize();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()..loadProperties()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _listenAuthState();
  }

  void _listenAuthState() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        // إذا كان مستخدم جديد من جوجل، ننشئ له بروفايل افتراضي
        final userId = session.user.id;
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (profile == null) {
          // إنشاء بروفايل أونر افتراضي للمسجلين بجوجل لأول مرة
          await Supabase.instance.client.from('profiles').insert({
            'id': userId,
            'full_name': session.user.userMetadata?['full_name'] ?? 'Google User',
            'role': 'owner',
          });
        }

        // التوجيه للداشبورد
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Student Housing Finder',
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: appProvider.themeMode,
      locale: appProvider.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      home: const SplashScreen(),
    );
  }
}
