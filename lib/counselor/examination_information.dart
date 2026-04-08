import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'counselor_models.dart';
import 'exam_schedule.dart';

class ExamListPage extends StatefulWidget {
  const ExamListPage({super.key});

  @override
  State<ExamListPage> createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage> {
  bool _isLoading = true;
  List<ExamType> _exams = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiService.get('counselor/exams');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            final List examData = data['data'] ?? data['instituteexam'] ?? [];
            _exams = examData.map((e) => ExamType.fromJson(e)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to load exams";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Examination List"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchExams,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                  ))
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: context.pagePadding,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Search Active Exams", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 16),
                                    TextField(
                                      decoration: const InputDecoration(
                                        hintText: "Search by exam name or code...",
                                        prefixIcon: Icon(Icons.search),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text("Exams Collection", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  ),
                                  const Divider(height: 1),
                                  if (_exams.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.all(40.0),
                                      child: Center(child: Text("No active exams found")),
                                    )
                                  else
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                                        columns: const [
                                          DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text("Exam Name", style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text("Type", style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text("Code", style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text("Schedule", style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                                        ],
                                        rows: _exams.asMap().entries.map((entry) {
                                          int idx = entry.key;
                                          ExamType exam = entry.value;
                                          return DataRow(cells: [
                                            DataCell(Text("${idx + 1}")),
                                            DataCell(SizedBox(width: 180, child: Text(exam.name, style: const TextStyle(fontWeight: FontWeight.w500)))),
                                            DataCell(Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                (exam.type ?? "WRITTEN").toUpperCase(),
                                                style: TextStyle(color: theme.colorScheme.onSecondaryContainer, fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            )),
                                            DataCell(Text(exam.code ?? "-")),
                                            DataCell(Text("${exam.startDate ?? ''} - ${exam.endDate ?? ''}", style: const TextStyle(fontSize: 11))),
                                            DataCell(
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (_) => ExamSchedulePage(exam: exam)));
                                                },
                                                child: const Text("VIEW", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                          ]);
                                        }).toList(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
