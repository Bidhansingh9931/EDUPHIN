import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

class LendingBooksScreen extends StatefulWidget {
  const LendingBooksScreen({super.key});

  @override
  State<LendingBooksScreen> createState() => _LendingBooksScreenState();
}

class _LendingBooksScreenState extends State<LendingBooksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lending Books')),
      body: const Center(child: Text('Lending Books Screen')),
    );
  }
}
