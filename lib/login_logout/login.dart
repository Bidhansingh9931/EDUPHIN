import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/accountant/dashboard/accountant_dashbard.dart';
import 'package:eduphin/counselor/counselor_dashboard.dart';
import 'package:eduphin/librarian/librarian_dashboard.dart';
import 'package:eduphin/login_logout/ui_helper.dart';
import 'package:eduphin/manager_dashboard/manager_dashboard.dart';
import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/student/student_dashboard.dart';
import 'package:eduphin/teacher/dashboard/teacher_dashboard.dart';
import 'package:eduphin/staff/staff_dashboard/staff_dashboard.dart';
import 'package:eduphin/superAdmin/super_admin_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Roles {
  static const int superAdmin = 1;
  static const int moderator = 2;
  static const int manager = 3;
  static const int counselor = 4;
  static const int teacher = 5;
  static const int student = 6;
  static const int librarian = 7;
  static const int accountant = 8;
  static const int staff = 9;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isChecked = false;
  bool _isObscure = true;
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remember_email');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe && savedEmail != null) {
      setState(() {
        emailController.text = savedEmail;
        isChecked = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (isChecked) {
      await prefs.setString('remember_email', emailController.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('remember_email');
      await prefs.setBool('remember_me', false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final roleId = await ApiService.login(emailController.text.trim(), passwordController.text.trim());
      await _saveCredentials();
      if (!mounted) return;
      _navigateToDashboard(roleId);
    } catch (e) {
      debugPrint('An error occurred during login: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDashboard(int roleId) {
    if (!mounted) return;

    Widget? destinationPage;
    if (roleId == Roles.superAdmin) {
      destinationPage = const SuperAdminDashboard();
    } else if (roleId == Roles.moderator) {
      destinationPage = const ModeratorDashboardPage();
    } else if (roleId == Roles.manager) {
      destinationPage = const ManagerDashboardPage();
    } else if (roleId == Roles.counselor) {
      destinationPage = const CounselorDashboardPage();
    } else if (roleId == Roles.teacher) {
      destinationPage = const TeacherDashboardPage();
    } else if (roleId == Roles.student) {
      destinationPage = const StudentDashboard();
    } else if (roleId == Roles.librarian) {
      destinationPage = const LibrarianDashboard();
    } else if (roleId == Roles.accountant) {
      destinationPage = const AccountantDashboard();
    } else if (roleId == Roles.staff) {
      destinationPage = const StaffDashboard();
    }

    if (destinationPage != null) {
      final page = destinationPage;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => page,
        ),
      );
    } else {
      setState(() {
        _error = 'Unauthorized role. Role ID: $roleId';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: const AssetImage('assets/images/eduphin_theme.jpg'),
              fit: BoxFit.cover,
              colorFilter: context.isDarkMode 
                  ? ColorFilter.mode(Colors.black.withValues(alpha: 0.6), BlendMode.darken)
                  : null,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsive(20.0, tablet: 40.0, desktop: 60.0),
              vertical: 20.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.responsive(450.0, tablet: 500.0, desktop: 550.0),
              ),
              child: Card(
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: EdgeInsets.all(context.responsive(24.0, tablet: 32.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/eduphin_logo_bg.png',
                        height: context.scale(80),
                        width: context.scale(80),
                      ),
                      SizedBox(height: context.scale(16)),
                      Text(
                        "Welcome Back!",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          fontSize: context.font(24),
                        ),
                      ),
                      SizedBox(height: context.scale(8)),
                      Text(
                        "Sign in to your EDUPHIN account.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                          fontSize: context.font(14),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.scale(32)),
                      UiHelper.customTextField(
                        context,
                        emailController,
                        "your.email@example.com",
                        Icons.mail_outline,
                        false,
                      ),
                      UiHelper.customTextField(
                        context,
                        passwordController,
                        "Password",
                        Icons.lock_outline,
                        _isObscure,
                        suffixIcon: _isObscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        onSuffixPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                      if (_error.isNotEmpty) ...[
                        SizedBox(height: context.scale(12)),
                        Text(
                          _error,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: context.font(12),
                          ),
                        ),
                      ],
                      SizedBox(height: context.scale(12)),
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: isChecked,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  isChecked = newValue!;
                                });
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Remember me",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: context.font(14),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.scale(24)),
                      SizedBox(
                        width: double.infinity,
                        height: context.scale(54),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    fontSize: context.font(16),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
