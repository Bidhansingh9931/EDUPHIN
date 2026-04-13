import 'dart:async';
import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/login_logout/splash_screen.dart';
import 'package:eduphin/services/theme_service.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eduphin',
      
      // Theme Mode: System follows device settings (Light/Dark)
      themeMode: ThemeMode.system,

      // --- CENTRALIZED LIGHT THEME ---
      theme: ThemeService.buildTheme(Brightness.light),

      // --- CENTRALIZED DARK THEME ---
      darkTheme: ThemeService.buildTheme(Brightness.dark),

      // Global Builder: Wraps every page with consistent layout & scaling
      builder: (context, child) {
        return MediaQuery(
          // Ensure text scaling remains consistent across devices
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },

      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
