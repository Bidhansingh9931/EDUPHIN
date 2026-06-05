import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeService {
  // Global Primary Color - Centralized for easy modification
  static const Color _primaryColor = Color(0xFF2E6CFF);

  static ThemeData buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: brightness,
      primary: _primaryColor,
      onPrimary: Colors.white,
      secondary: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
      surface: isDark ? const Color(0xFF0F172A) : Colors.white,
      onSurface: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
      error: const Color(0xFFEF4444),
      outline: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
      surfaceContainerHighest: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      outlineVariant: isDark ? Colors.white10 : Colors.black12,
    );

    final baseTheme = brightness == Brightness.dark 
        ? ThemeData.dark(useMaterial3: true) 
        : ThemeData.light(useMaterial3: true);

    return baseTheme.copyWith(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? const Color(0xff0B1220) : const Color(0xFFF8FAFC),
      dividerColor: colorScheme.outline,
      hintColor: isDark ? Colors.white38 : Colors.black38,
      cardColor: isDark ? const Color(0xff1E2746) : Colors.white,
      
      // Global Card Styling
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xff1E2746) : Colors.white,
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
        centerTitle: false,
        iconTheme: IconThemeData(color: isDark ? Colors.white : colorScheme.onSurface),
        titleTextStyle: GoogleFonts.inter(
          color: isDark ? Colors.white : colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Global Button Styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(64, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),

      // Global Input Styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
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
        prefixIconColor: colorScheme.primary,
        suffixIconColor: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: 24,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),

      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
    );
  }
}
