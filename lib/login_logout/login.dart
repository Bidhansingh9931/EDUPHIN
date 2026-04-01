import 'package:eduphin/accountant/dashboard/accountant_dashbard.dart';
import 'package:eduphin/login_logout/ui_helper.dart';
import 'package:eduphin/manager_dashboard/manager_dashboard.dart';
import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:eduphin/student/student_dashboard.dart';
import 'package:eduphin/teacher/dashboard/teacher_dashboard.dart';
import 'package:eduphin/staff/staff_dashboard/staff_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';

class Roles {
  static const int moderator = 2;
  static const int manager = 3;
  static const int teacher = 5;
  static const int student = 6;
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
    if (roleId == Roles.moderator) {
      destinationPage = const ModeratorDashboardPage();
    } else if (roleId == Roles.manager) {
      destinationPage = const ManagerDashboardPage();
    } else if (roleId == Roles.teacher) {
      destinationPage = const TeacherDashboardPage();
    } else if (roleId == Roles.student) {
      destinationPage = const StudentDashboard();
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
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/eduphin_theme.jpg'),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 80),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width:
                    constraints.maxWidth > 500 ? 500 : constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/eduphin_logo_bg.png',
                              height: 100, width: 100),
                          const SizedBox(height: 10),
                          Text(
                            "Welcome Back!",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sign in to your EDUPHIN account.",
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: theme.hintColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
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
                            const SizedBox(height: 10),
                            Text(
                              _error,
                              style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontSize: 12),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        isChecked = newValue!;
                                      });
                                    },
                                    activeColor: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    "Remember me",
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface),
                                  ),
                                ],
                              ),
                              // TextButton(
                              //   onPressed: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (context) =>
                              //               const ForgotPasswordPage()),
                              //     );
                              //   },
                              //   child: Text(
                              //     "Forgot password?",
                              //     style: TextStyle(
                              //         color: theme.colorScheme.primary),
                              //   ),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                disabledBackgroundColor:
                                theme.colorScheme.primary,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                                  : Text(
                                "LOGIN",
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(
                                    color:
                                    theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
