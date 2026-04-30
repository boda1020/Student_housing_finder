import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:student_housing_finder/app.dart';
import 'package:student_housing_finder/providers/app_provider.dart';
import 'package:student_housing_finder/providers/auth_provider.dart';

void main() {
  testWidgets('App starts and shows splash screen title', (WidgetTester tester) async {
    // Build our app with providers and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app title from Splash Screen is displayed.
    // We use findsWidgets because it might appear in multiple places (Title, Text widget, etc.)
    expect(find.textContaining('Student Housing'), findsWidgets);
  });
}
