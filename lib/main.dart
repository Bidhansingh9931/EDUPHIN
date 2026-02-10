import 'package:eduphin/login_logout/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
      onSurface: const Color(0xFF333333), // Main text color
      onSurfaceVariant: Colors.grey.shade600, // Secondary text color
      error: Colors.redAccent,
      onError: Colors.white,
    );

    final darkScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor, // Ensure primary color is consistent
      onPrimary: const Color(0xFFEBEDEF),
      surface: const Color(0xFF112033), // Card color
      onSurface: const Color(0xFFEBEDEF), // Main text color
      onSurfaceVariant: Colors.grey.shade400, // Secondary text color
      error: Colors.redAccent,
      onError: Colors.white,
    );

    TextTheme buildTextTheme(ColorScheme colorScheme) {
      return TextTheme(
        headlineSmall: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: colorScheme.onSurface),
        bodyLarge: TextStyle(color: colorScheme.onSurface),
        bodyMedium: TextStyle(color: colorScheme.onSurfaceVariant), // Use for secondary text
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eduphin',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: const Color(0xFFF0F4FF), // Light blue background
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
      home: const SplashScreen(),
    );
  }
}
