import 'dart:math';

import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/manager_dashboard/manager_dashboard.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> moveUp;
  late Animation<double> rotate;
  late Animation<double> scale;
  late Animation<double> textFade;
  late Animation<Offset> textSlide;

  bool _navigated = false; // ✅ ADDED: prevents double navigation

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    moveUp = Tween<double>(begin: 250, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    rotate = Tween<double>(begin: 0, end: pi / 4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.55, curve: Curves.easeInOut),
      ),
    );

    scale = Tween<double>(begin: 1.0, end: 30.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
      ),
    );

    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
    );
    textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
    textSlide =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(textCurve);

    _controller.forward();

    // ✅ SAFE listener
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_navigated) {
        _checkAuthStatusAndNavigate();
      }
    });
  }

  /// ✅ FULLY SAFE AUTH CHECK (NO CRASH)
  Future<void> _checkAuthStatusAndNavigate() async {
    try {
      _navigated = true;

      final token = await ApiService.getToken()
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (token != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ManagerDashboardPage(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      }
    } catch (e) {
      // ✅ FAIL-SAFE: never crash on splash
      debugPrint('Splash auth error: $e');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ ADDED: Preload image to avoid asset crash
    precacheImage(
      const AssetImage("assets/images/eduphin_logo_bg.png"),
      context,
    );
  }

  @override
  void dispose() {
    _controller.removeStatusListener((_) {}); // ✅ extra safety
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              Center(
                child: Transform.translate(
                  offset: Offset(0, moveUp.value),
                  child: Transform.rotate(
                    angle: rotate.value,
                    child: Transform.scale(
                      scale: scale.value,
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: textFade,
                      child: SlideTransition(
                        position: textSlide,
                        child: Image.asset(
                          "assets/images/eduphin_logo_bg.png",
                          height: 150,
                          errorBuilder: (_, __, ___) =>
                          const SizedBox(height: 150), // ✅ NO CRASH
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: textFade,
                      child: SlideTransition(
                        position: textSlide,
                        child: Text(
                          "EDUPHIN",
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
