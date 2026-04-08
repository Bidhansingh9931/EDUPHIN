import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/exam_models.dart';
import 'common_widgets.dart';

class ExamSchedulePage extends StatefulWidget {
  final int? examId;

  const ExamSchedulePage({super.key, this.examId});

  @override
  State<ExamSchedulePage> createState() => _ExamSchedulePageState();
}

class _ExamSchedulePageState extends State<ExamSchedulePage> {
  late Future<ExamScheduleData>? _scheduleFuture;

  @override
  void initState() {
    super.initState();
    if (widget.examId != null) {
      _scheduleFuture = ApiService.getExamSchedule(widget.examId!);
    } else {
      _scheduleFuture = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.calendar_month_outlined, size: 20),
            SizedBox(width: 12),
            Text("Examination Paper Schedule"),
          ],
        ),
      ),
      body: widget.examId == null 
        ? _buildPlaceholderContent()
        : FutureBuilder<ExamScheduleData>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data found"));
          }

          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildExamScheduleCard("Class: Financial Accounting Basics - Section: A"),
              const SizedBox(height: 20),
              _buildExamScheduleCard("Class: Cost Analysis and Management - Section: A"),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildExamScheduleCard("Class: Financial Accounting Basics - Section: A"),
        const SizedBox(height: 20),
        _buildExamScheduleCard("Class: Cost Analysis and Management - Section: A"),
      ],
    );
  }

  Widget _buildExamScheduleCard(String classTitle) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Icon(Icons.layers_outlined, color: Colors.grey, size: 30),
                const SizedBox(height: 12),
                Text(classTitle, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
                  child: const Text("Total Papers: 1", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildScheduleTable(),
        ],
      ),
    );
  }

  Widget _buildScheduleTable() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              _headerItem("Subject", flex: 2),
              _headerItem("Date"),
              _headerItem("Time"),
              _headerItem("Venue"),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              _dataItem("Principles of Accounting", flex: 2, isBold: true),
              _dataItem("04 Oct 2025"),
              _dataItem("09:00 AM - 12:00 PM"),
              _dataItem("Room 101"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerItem(String label, {int flex = 1}) {
    return Expanded(flex: flex, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)));
  }

  Widget _dataItem(String value, {int flex = 1, bool isBold = false}) {
    return Expanded(flex: flex, child: Text(value, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)));
  }
}
