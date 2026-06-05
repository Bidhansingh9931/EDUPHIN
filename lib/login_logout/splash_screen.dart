import 'dart:math';
import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/services/responsive_helper.dart';
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

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    rotate = Tween<double>(begin: 0, end: pi / 4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.45, curve: Curves.easeInOut),
      ),
    );

    scale = Tween<double>(begin: 1.0, end: 100.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.65, curve: Curves.easeInOut),
      ),
    );

    final textCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
    );
    textFade = Tween<double>(begin: 0.0, end: 1.0).animate(textCurve);
    textSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
            .animate(textCurve);

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_navigated) {
        _navigateToNext();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start from below the screen and move to center (0 offset)
    moveUp = Tween<double>(begin: context.screenHeight, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );
    precacheImage(const AssetImage("assets/images/eduphin_logo_bg.png"), context);
  }

  Future<void> _navigateToNext() async {
    if (_navigated) return;
    _navigated = true;

    if (!mounted) return;

    final token = await ApiService.getToken();
    final roleId = await ApiService.getRoleId();

    if (token != null && token.isNotEmpty && roleId != null) {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
        return;
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // 1. Background Fill Animation
              Center(
                child: Transform.translate(
                  offset: Offset(0, moveUp.value),
                  child: Transform.rotate(
                    angle: rotate.value,
                    child: Transform.scale(
                      scale: scale.value,
                      child: Container(
                        height: context.scale(60),
                        width: context.scale(60),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A47B8), // More professional, less "neon" blue
                          borderRadius: BorderRadius.circular(context.scale(12)),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3), 
                            width: 2
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A47B8).withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Logo and Text Content
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
                          height: context.scale(150),
                          errorBuilder: (_, __, ___) => SizedBox(height: context.scale(150)),
                        ),
                      ),
                    ),
                    SizedBox(height: context.scale(20)),
                    FadeTransition(
                      opacity: textFade,
                      child: SlideTransition(
                        position: textSlide,
                        child: Text(
                          "EDUPHIN",
                          style: TextStyle(
                            fontSize: context.font(48),
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
