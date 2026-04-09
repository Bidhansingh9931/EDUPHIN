import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'librarian_models.dart';

class ExamScheduleManagementPage extends StatefulWidget {
  final int examId;
  final String examTitle;
  const ExamScheduleManagementPage({super.key, required this.examId, required this.examTitle});

  @override
  State<ExamScheduleManagementPage> createState() => _ExamScheduleManagementPageState();
}

class _ExamScheduleManagementPageState extends State<ExamScheduleManagementPage> {
  bool _isLoading = true;
  List<dynamic> _schedules = [];
  List<ExamType> _allExams = [];
  late int _selectedExamId;

  @override
  void initState() {
    super.initState();
    _selectedExamId = widget.examId;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getLibrarianExams(),
        ApiService.getLibrarianExamSchedule(_selectedExamId.toString()),
      ]);

      setState(() {
        _allExams = results[0] as List<ExamType>;
        _schedules = (results[1] as Map<String, dynamic>)['schedules'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _fetchSchedule(int id) async {
    setState(() {
      _selectedExamId = id;
      _isLoading = true;
    });
    try {
      final scheduleData = await ApiService.getLibrarianExamSchedule(id.toString());
      setState(() {
        _schedules = scheduleData['schedules'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching schedule: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Schedule"),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _fetchSchedule(_selectedExamId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      children: [
                        /// EXAM SELECTION CARD
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Select Examination", style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: _selectedExamId.toString(),
                                  isExpanded: true,
                                  items: _allExams.map((e) => DropdownMenuItem(
                                    value: e.id.toString(), 
                                    child: Text(e.name, style: const TextStyle(fontSize: 14))
                                  )).toList(), 
                                  onChanged: (val) {
                                    if (val != null) _fetchSchedule(int.parse(val));
                                  }
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// RECORDS SECTION
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Text("Schedule Details", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    _exportIcon(Icons.picture_as_pdf, Colors.red),
                                    _exportIcon(Icons.table_chart, Colors.green),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),

                              if (_schedules.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    child: Text("No schedules found for this exam."),
                                  ),
                                )
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withValues(alpha: 0.05)),
                                  columnSpacing: 25,
                                  columns: const [
                                    DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text("Subject", style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text("Date", style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text("Time", style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text("Room", style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: _schedules.asMap().entries.map((entry) {
                                    int index = entry.key + 1;
                                    var s = entry.value;
                                    String subjectName = "N/A";
                                    if (s['subject'] is Map) {
                                      subjectName = s['subject']['name']?.toString() ?? "N/A";
                                    } else if (s['subject_name'] != null) {
                                      subjectName = s['subject_name'].toString();
                                    }

                                    String roomName = "N/A";
                                    if (s['room'] is Map) {
                                      roomName = s['room']['name']?.toString() ?? "N/A";
                                    } else if (s['room_name'] != null) {
                                      roomName = s['room_name'].toString();
                                    }

                                    return DataRow(cells: [
                                      DataCell(Text(index.toString())),
                                      DataCell(Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold))),
                                      DataCell(Text(s['date']?.toString() ?? 'N/A')),
                                      DataCell(Text("${s['start_time'] ?? ''} - ${s['end_time'] ?? ''}")),
                                      DataCell(Text(roomName)),
                                    ]);
                                  }).toList(),
                                ),
                                ),
                              const SizedBox(height: 16),
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

  Widget _exportIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: color.withValues(alpha: 0.2))
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}
