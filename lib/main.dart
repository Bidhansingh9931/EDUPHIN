import 'dart:async';
import 'package:eduphin/login_logout/splash_screen.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

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

  // Global Primary Color - Centralized for easy modification
  static const Color _primaryColor = Color(0xFF2E6CFF);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eduphin',
      
      // Theme Mode: System follows device settings (Light/Dark)
      themeMode: ThemeMode.system,

      // --- LIGHT THEME ---
      theme: _buildTheme(Brightness.light),

      // --- DARK THEME ---
      darkTheme: _buildTheme(Brightness.dark),

      // Global Builder: Can be used to wrap every page with consistent layout
      builder: (context, child) {
        return MediaQuery(
          // Ensure text scaling remains consistent
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },

      home: const SplashScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: brightness,
      primary: _primaryColor,
      onPrimary: Colors.white,
      secondary: isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB),
      surface: isDark ? const Color(0xFF0F172A) : Colors.white,
      onSurface: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
      error: const Color(0xFFEF4444),
      outline: isDark ? Colors.white10 : Colors.black12,
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      
      // Global Card Styling
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Global AppBar Styling
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: GoogleFonts.inter(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Global Button Styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),

      // Global Input Styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14),
      ),
      
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: 24,
      ),
    );

    // Apply Google Fonts to the entire theme
    return baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
    );
  }
}
