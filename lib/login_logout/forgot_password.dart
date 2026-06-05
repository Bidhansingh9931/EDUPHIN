import 'dart:convert';

import 'package:eduphin/login_logout/ui_helper.dart';
import 'package:eduphin/login_logout/verify.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    // Basic email validation
    if (emailController.text.isEmpty ||
        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid email address.'),
          backgroundColor: context.theme.colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.post('forgot-password', {
        'email': emailController.text,
      });

      if (mounted) {
        final theme = context.theme;
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200 && responseData['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['message'] ?? 'Password reset link sent!'),
                backgroundColor: theme.colorScheme.primary),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    VerifyPasswordPage(email: emailController.text)),
          );
        } else {
          throw Exception(responseData['message'] ?? 'Failed to send reset link.');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
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
                  width: constraints.maxWidth > 500
                      ? 500
                      : constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: theme.cardColor.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(context.scale(20)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(context.scale(24)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school,
                          size: context.scale(100),
                          color: theme.colorScheme.onSurface,
                        ),
                        SizedBox(height: context.scale(16)),
                        Text(
                          "Forgot Your Password?",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: context.font(24),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.scale(8)),
                        Text(
                          "Enter your email address and we'll send you a link to reset your password.",
                          style: theme.textTheme.bodyMedium?.copyWith(
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
                        SizedBox(height: context.scale(20)),
                        SizedBox(
                          width: double.infinity,
                          height: context.scale(50),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendResetLink,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(context.scale(15)),
                              ),
                              disabledBackgroundColor:
                                  theme.colorScheme.primary.withValues(alpha: 0.5),
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
                                    "SEND RESET LINK",
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            color:
                                                theme.colorScheme.onPrimary,
                                            fontSize: context.font(16),
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
    );
  }
}
