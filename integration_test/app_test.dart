import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eduphin/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Flow', () {
    testWidgets('Splash Screen to Login Page transition', (tester) async {
      // Mock shared preferences to ensure we start from logged out state
      SharedPreferences.setMockInitialValues({});
      
      app.main();
      await tester.pumpAndSettle();

      // Initial screen should be SplashScreen (or wait for it)
      // Since main.dart returns SplashScreen when waiting for token
      expect(find.text('EDUPHIN'), findsOneWidget);

      // Wait for the splash animation and navigation
      // SplashScreen duration is 4 seconds
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should now be on LoginPage
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Sign in to your EDUPHIN account.'), findsOneWidget);
    });

    testWidgets('Login Page interaction - Empty fields', (tester) async {
      SharedPreferences.setMockInitialValues({});
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap Login button without entering email/password
      await tester.tap(find.text('LOGIN'));
      await tester.pumpAndSettle();

      // We expect an error message. Since we haven't mocked the API call yet 
      // (and ApiService.login is static), it will likely fail with an exception
      // that gets caught and displayed as "Login failed: ..."
      expect(find.textContaining('Login failed'), findsOneWidget);
    });
  });
}
