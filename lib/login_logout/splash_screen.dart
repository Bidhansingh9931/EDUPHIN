import 'dart:math';
import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Move from bottom → center
    moveUp = Tween<double>(begin: 250, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    // Rotate 45 degrees
    rotate = Tween<double>(begin: 0, end: pi / 4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.55, curve: Curves.easeInOut),
      ),
    );

    // Scale explosion (fills entire screen)
    scale = Tween<double>(begin: 1.0, end: 30.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
      ),
    );

    // Text animations (fade and slide in)
    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
    );
    textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
    textSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(textCurve);

    _controller.forward();

    // After animation finished, check auth status and navigate
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthStatusAndNavigate();
      }
    });
  }

  Future<void> _checkAuthStatusAndNavigate() async {
    // In a real app, you would check for a token, user session, etc.
    // For this example, we'll simulate a check that finds no logged-in user.
    bool isLoggedIn = false; // Change to true to test the logged-in flow

    if (mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const ModeratorDashboardPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  void dispose() {
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
              // Explosion animation
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

              // Logo and Text reveal
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Text slide and fade-in
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
