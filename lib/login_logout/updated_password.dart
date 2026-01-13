import 'dart:async';

import 'package:eduphin/login_logout/ui_helper.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class UpdatedPasswordPage extends StatefulWidget {
  const UpdatedPasswordPage({super.key});
  @override
  State<UpdatedPasswordPage> createState() => _UpdatedPasswordPageState();
}

class _UpdatedPasswordPageState extends State<UpdatedPasswordPage> {
  @override
  void initState() {
    super.initState();
    _scheduleRedirect();
  }

  void _scheduleRedirect() {
    // After a delay, automatically redirect to the login page.
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
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
                    width: constraints.maxWidth > 500
                        ? 500
                        : constraints.maxWidth,
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
                            "PASSWORD UPDATED",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Your Password has been Updated Successfully!",
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Image.asset('assets/images/icons8-tick-48.png',
                              height: 50, width: 80),
                          const SizedBox(height: 10),
                          UiHelper.customButton(context, () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          }, "LOGIN"),
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
