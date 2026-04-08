import 'package:flutter/material.dart';

class RegisteredEventsPage extends StatelessWidget {
  const RegisteredEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Events'),
      ),
      body: const Center(
        child: Text('Registered Events Page'),
      ),
    );
  }
}
