import 'dart:convert';

import 'package:eduphin/login_logout/login.dart';
import 'package:eduphin/login_logout/ui_helper.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

class UpdatedPasswordPage extends StatefulWidget {
  final String email;
  final String otp;

  const UpdatedPasswordPage({super.key, required this.email, required this.otp});

  @override
  State<UpdatedPasswordPage> createState() => _UpdatedPasswordPageState();
}

class _UpdatedPasswordPageState extends State<UpdatedPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match.'),
          backgroundColor: context.theme.colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post('reset-password', {
        'email': widget.email,
        'token': widget.otp,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
      });

      if (mounted) {
        final theme = context.theme;
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200 && responseData['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Password updated successfully!'),
              backgroundColor: theme.colorScheme.primary,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        } else {
          throw Exception(responseData['message'] ?? 'Failed to reset password.');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: context.pagePadding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth > 500 ? 500 : constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(context.scale(20)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(context.scale(25)),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.school, size: context.scale(100), color: theme.colorScheme.onSurface),
                          SizedBox(height: context.scale(10)),
                          Text(
                            "Reset Password",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: context.font(24),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.scale(8)),
                          Text(
                            "Enter your new password below.",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: context.font(14),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.scale(20)),
                          UiHelper.customTextField(
                            context,
                            _passwordController,
                            "New Password",
                            Icons.lock,
                            true,
                          ),
                          SizedBox(height: context.scale(20)),
                          UiHelper.customTextField(
                            context,
                            _confirmPasswordController,
                            "Confirm New Password",
                            Icons.lock_outline,
                            true,
                          ),
                          SizedBox(height: context.scale(30)),
                           SizedBox(
                            width: double.infinity,
                            height: context.scale(50),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _savePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(context.scale(15)),
                                ),
                                disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Text(
                                      "SAVE PASSWORD",
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.font(16),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
