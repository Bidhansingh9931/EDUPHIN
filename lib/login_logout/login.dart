import 'package:eduphin/login_logout/ui_helper.dart';
import 'package:eduphin/manager_dashboard/manager_dashboard.dart';
import 'package:eduphin/moderator_dashboard/moderator_dashboard.dart';
import 'package:flutter/material.dart';

import 'forgot_password.dart';

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay for a better user experience
    await Future.delayed(const Duration(seconds: 1));

    final username = emailController.text.trim();
    final password = passwordController.text.trim();

    // Navigate to the correct dashboard based on credentials
    if (username == "priya@eduphin.com" && password == "eduphin@mod") {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) =>
                const ModeratorDashboardPage()), // Assuming this is the moderator dashboard
      );
    } else if (username == "raj@iias.com" && password == "87654321") {
      if (!mounted) return;
      // Assuming 'Raj' is a manager and should be directed to the ManagerDashboard.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ManagerDashboardPage()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid username or password")),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
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
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPasswordPage()),
                                  );
                                },
                                child: Text(
                                  "Forgot password?",
                                  style: TextStyle(
                                      color: theme.colorScheme.primary),
                                ),
                              ),
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
