import 'dart:math';

import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/manager_dashboard/manager_dashboard.dart';
import 'package:eduphin/counselor/counselor_dashboard.dart';
import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/student/student_dashboard.dart';
import 'package:eduphin/teacher/dashboard/teacher_dashboard.dart';
import 'package:eduphin/librarian/librarian_dashboard.dart';
import 'package:eduphin/accountant/dashboard/accountant_dashbard.dart';
import 'package:eduphin/staff/staff_dashboard/staff_dashboard.dart';
import 'package:eduphin/superAdmin/super_admin_dashboard.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize moveUp here where context is available for scaling if needed, 
    // but better to keep it in initState and use a fixed value or scale later.
    // Actually, scaling the animation start value:
    moveUp = Tween<double>(begin: context.scale(250), end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    // ✅ ADDED: Preload image to avoid asset crash
    precacheImage(
      const AssetImage("assets/images/eduphin_logo_bg.png"),
      context,
    );
  }

  /// ✅ FULLY SAFE AUTH CHECK (NO CRASH)
  Future<void> _checkAuthStatusAndNavigate() async {
    try {
      _navigated = true;

      final token = await ApiService.getToken()
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (token != null) {
        final roleId = await ApiService.getRoleId();
        
        Widget nextScreen;
        switch (roleId) {
          case 1: nextScreen = const SuperAdminDashboard(); break;
          case 2: nextScreen = const ModeratorDashboardPage(); break;
          case 3: nextScreen = const ManagerDashboardPage(); break;
          case 4: nextScreen = const CounselorDashboardPage(); break;
          case 5: nextScreen = const TeacherDashboardPage(); break;
          case 6: nextScreen = const StudentDashboard(); break;
          case 7: nextScreen = const LibrarianDashboard(); break;
          case 8: nextScreen = const AccountantDashboard(); break;
          case 9: nextScreen = const StaffDashboard(); break;
          default: nextScreen = const LoginPage(); break;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => nextScreen,
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
      debugPrint('Splash Screen Error: $e');

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
  void dispose() {
    _controller.removeStatusListener((_) {}); // ✅ extra safety
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
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(context.scale(12)),
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
                          height: context.scale(150),
                          errorBuilder: (_, __, ___) =>
                          SizedBox(height: context.scale(150)), // ✅ NO CRASH
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
