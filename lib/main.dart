import 'dart:async'; // ✅ KEPT (error guarding)
import 'package:eduphin/login_logout/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  // ✅ Catch async / background errors (SAFE for web & mobile)
  runZonedGuarded(() {
    // ✅ MUST be inside the SAME zone
    WidgetsFlutterBinding.ensureInitialized();

    // ✅ Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };

    runApp(const MyApp());
  }, (error, stackTrace) {
    debugPrint('Uncaught error: $error');
    debugPrint('$stackTrace');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2E6CFF);

    final lightScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: const Color(0xFF333333),
      onSurfaceVariant: Colors.grey,
      error: Colors.redAccent,
      onError: Colors.white,
    );

    final darkScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: const Color(0xFFEBEDEF),
      surface: const Color(0xFF112033),
      onSurface: const Color(0xFFEBEDEF),
      onSurfaceVariant: Colors.grey,
      error: Colors.redAccent,
      onError: Colors.white,
    );

    TextTheme buildTextTheme(ColorScheme colorScheme) {
      return TextTheme(
        headlineSmall: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: colorScheme.onSurface,
        ),
        bodyLarge: TextStyle(
          color: colorScheme.onSurface,
        ),
        bodyMedium: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eduphin',
      themeMode: ThemeMode.system,

      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: const Color(0xFFF0F4FF),
        cardColor: lightScheme.surface,
        hintColor: Colors.grey.shade500,
        disabledColor: Colors.grey.shade400,
        appBarTheme: AppBarTheme(
          backgroundColor: lightScheme.surface,
          elevation: 0,
          iconTheme: IconThemeData(color: lightScheme.onSurface),
          titleTextStyle: TextStyle(
            color: lightScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: buildTextTheme(lightScheme),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: const Color(0xFF08111D),
        cardColor: darkScheme.surface,
        hintColor: Colors.grey.shade700,
        disabledColor: Colors.grey.shade600,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF08111D),
          elevation: 0,
          iconTheme: IconThemeData(color: darkScheme.onSurface),
          titleTextStyle: TextStyle(
            color: darkScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: buildTextTheme(darkScheme),
      ),

      // ✅ Kept exactly as-is
      home: const SplashScreen(),
    );
  }
}
