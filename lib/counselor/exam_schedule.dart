import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'counselor_models.dart';

class ExamSchedulePage extends StatefulWidget {
  final ExamType exam;
  const ExamSchedulePage({super.key, required this.exam});

  @override
  State<ExamSchedulePage> createState() => _ExamSchedulePageState();
}

class _ExamSchedulePageState extends State<ExamSchedulePage> {
  bool _isLoading = true;
  List<ExamPaperSchedule> _schedules = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiService.get('counselor/exams/${widget.exam.id}/schedule');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final List scheduleData = data['data']['schedules'] ?? [];
          _schedules = scheduleData.map((e) => ExamPaperSchedule.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load schedule";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.exam.name} Schedule"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSchedule,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error)))
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: context.pagePadding,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Exam Details", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text("Type: ${widget.exam.type ?? 'N/A'}", style: TextStyle(color: theme.hintColor)),
                                    Text("Code: ${widget.exam.code ?? 'N/A'}", style: TextStyle(color: theme.hintColor)),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              if (_schedules.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(40.0),
                                  child: Center(child: Text("No schedule found for this exam")),
                                )
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: 24,
                                    columns: const [
                                      DataColumn(label: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Time", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Subject", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Class", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Room", style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                    rows: _schedules.map((s) {
                                      return DataRow(cells: [
                                        DataCell(Text(s.date ?? "-")),
                                        DataCell(Text("${s.startTime} - ${s.endTime}", style: const TextStyle(fontSize: 12))),
                                        DataCell(Text(s.subjectName ?? "-")),
                                        DataCell(Text(s.className ?? "-")),
                                        DataCell(Text(s.roomNo ?? "-")),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
