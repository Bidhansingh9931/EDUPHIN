import 'dart:async';
import 'dart:convert';

import 'package:eduphin/login_logout/updated_password.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

class VerifyPasswordPage extends StatefulWidget {
  final String email;
  const VerifyPasswordPage({super.key, required this.email});

  @override
  State<VerifyPasswordPage> createState() => _VerifyPasswordPageState();
}

class _VerifyPasswordPageState extends State<VerifyPasswordPage> {
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  bool _isLoading = false;

  // Timer for OTP expiry
  int seconds = 60;
  Timer? timer;

  // Timer for resend button
  bool isResendEnabled = true;
  int resendSeconds = 60;
  Timer? resendTimer;

  @override
  void initState() {
    super.initState();
    startExpiryTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    resendTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter all 4 digits.'),
          backgroundColor: context.theme.colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.post('verify-otp', {
        'email': widget.email,
        'token': otp,
      });

      if (mounted) {
        final theme = context.theme;
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200 && responseData['status'] == true) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['message'] ?? 'OTP verified successfully!'),
                backgroundColor: theme.colorScheme.primary),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UpdatedPasswordPage(email: widget.email, otp: otp)),
          );
        } else {
          throw Exception(responseData['message'] ?? 'Failed to verify OTP.');
        }
      }
    } catch (e) {
      if (mounted) {
        final theme = context.theme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: theme.colorScheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    startResendTimer();
    try {
      final response = await ApiService.post('forgot-password', {
        'email': widget.email,
      });

      if (mounted) {
        final theme = context.theme;
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200 && responseData['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['message'] ?? 'A new code has been sent.'),
                backgroundColor: theme.colorScheme.primary),
          );
        } else {
          throw Exception(responseData['message'] ?? 'Failed to resend code.');
        }
      }
    } catch (e) {
       if (mounted) {
        final theme = context.theme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: theme.colorScheme.error),
        );
      }
    }
  }


  /// OTP expiry timer
  void startExpiryTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
      } else {
        if(mounted){
          setState(() {
            seconds--;
          });
        }
      }
    });
  }

  /// Resend button timer
  void startResendTimer() {
    setState(() {
      isResendEnabled = false;
      resendSeconds = 60;
    });

    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds == 0) {
        timer.cancel();
        setState(() {
          isResendEnabled = true;
        });
      } else {
        if(mounted){
          setState(() {
            resendSeconds--;
          });
        }
      }
    });
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, size: context.scale(100), color: theme.colorScheme.onSurface),
                        SizedBox(height: context.scale(10)),

                        Text(
                          "Verify Your Mail",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: context.font(24),
                          ),
                        ),

                        SizedBox(height: context.scale(8)),
                        Text(
                          "Please enter The 4 Digit Code Sent To Your Email",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: context.font(14),
                          ),
                        ),

                        SizedBox(height: context.scale(15)),

                        Text(
                          "Code will expire in ${seconds}s",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: context.font(16),
                          ),
                        ),

                        SizedBox(height: context.scale(20)),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) => _buildOtpTextField(context, _otpControllers[index])),
                        ),

                        SizedBox(height: context.scale(10)),

                        TextButton(
                          onPressed: isResendEnabled ? _resendCode : null,
                          child: Text(
                            isResendEnabled
                                ? "Resend CODE"
                                : "Resend in $resendSeconds s",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isResendEnabled ? theme.colorScheme.primary : theme.disabledColor,
                              fontSize: context.font(16),
                            ),
                          ),
                        ),

                        SizedBox(height: context.scale(10)),

                        SizedBox(
                          width: double.infinity,
                          height: context.scale(50),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyCode,
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
                                  "VERIFY CODE",
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpTextField(BuildContext context, TextEditingController controller) {
    final theme = context.theme;
    return SizedBox(
      width: context.scale(60),
      height: context.scale(60),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          final focusScope = FocusScope.of(context);
          if (value.length == 1 && focusScope.canRequestFocus) {
            focusScope.nextFocus();
          } else if (value.isEmpty && focusScope.canRequestFocus) {
            focusScope.previousFocus();
          }
        },
        style: theme.textTheme.headlineMedium?.copyWith(
          fontSize: context.font(24),
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.scale(10)),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.scale(10)),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
