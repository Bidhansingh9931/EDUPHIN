import 'dart:async';
import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/login_logout/splash_screen.dart';
import 'package:eduphin/services/theme_service.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/superAdmin/super_admin_dashboard.dart';
import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/manager_dashboard/manager_dashboard.dart';
import 'package:eduphin/counselor/counselor_dashboard.dart';
import 'package:eduphin/teacher/dashboard/teacher_dashboard.dart';
import 'package:eduphin/student/student_dashboard.dart';
import 'package:eduphin/librarian/librarian_dashboard.dart';
import 'package:eduphin/accountant/dashboard/accountant_dashbard.dart';
import 'package:eduphin/staff/staff_dashboard/staff_dashboard.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runZonedGuarded(() async {
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

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final int? roleId;

  const MyApp({super.key, this.isLoggedIn = false, this.roleId});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isLoggedIn;
  int? _roleId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
    _roleId = widget.roleId;
    _initAuth();
  }

  Future<void> _initAuth() async {
    // Even if passed from main, re-verify to ensure we have the latest state
    final token = await ApiService.getToken();
    final roleId = await ApiService.getRoleId();
    if (mounted) {
      setState(() {
        _isLoggedIn = token != null;
        _roleId = roleId;
        _isLoading = false;
      });
    }
  }

  Widget _getDashboard(int? roleId) {
    switch (roleId) {
      case 1: return const SuperAdminDashboard();
      case 2: return const ModeratorDashboardPage();
      case 3: return const ManagerDashboardPage();
      case 4: return const CounselorDashboardPage();
      case 5: return const TeacherDashboardPage();
      case 6: return const StudentDashboard();
      case 7: return const LibrarianDashboard();
      case 8: return const AccountantDashboard();
      case 9: return const StaffDashboard();
      default:
        debugPrint('⚠️ [AUTH] Unknown Role ID: $roleId. Showing Login.');
        return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Eduphin',
      themeMode: ThemeMode.system,
      theme: ThemeService.buildTheme(Brightness.light),
      darkTheme: ThemeService.buildTheme(Brightness.dark),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/splash': (context) => const SplashScreen(),
        '/dashboard': (context) => _getDashboard(_roleId),
      },
    );
  }
}
