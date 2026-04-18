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
    final colorScheme = context.theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Exam Schedule"),
        centerTitle: true,
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
                    constraints: BoxConstraints(maxWidth: context.responsive(800.0, tablet: 1000.0, desktop: 1200.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// EXAM SELECTION CARD
                        Card(
                          elevation: 0,
                          color: colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.scale(20)),
                            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(context.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.assignment_turned_in, color: colorScheme.primary, size: context.scale(20)),
                                    SizedBox(width: context.sm),
                                    Text(
                                      "Select Examination",
                                      style: TextStyle(
                                        fontSize: context.font(16),
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: context.md),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedExamId.toString(),
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                    contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(context.scale(12)),
                                      borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(context.scale(12)),
                                      borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(context.scale(12)),
                                      borderSide: BorderSide(color: colorScheme.primary, width: 1),
                                    ),
                                  ),
                                  items: _allExams.map((e) => DropdownMenuItem(
                                    value: e.id.toString(),
                                    child: Text(e.name, style: TextStyle(fontSize: context.font(14))),
                                  )).toList(),
                                  onChanged: (val) {
                                    if (val != null) _fetchSchedule(int.parse(val));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: context.lg),

                        /// RECORDS SECTION
                        Card(
                          elevation: 0,
                          color: colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.scale(20)),
                            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(context.md),
                                child: Row(
                                  children: [
                                    Text(
                                      "Schedule Details",
                                      style: TextStyle(
                                        fontSize: context.font(16),
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const Spacer(),
                                    _exportIcon(Icons.picture_as_pdf, Colors.red),
                                    _exportIcon(Icons.table_chart, Colors.green),
                                  ],
                                ),
                              ),
                              Divider(height: 1, thickness: 0.5, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),

                              if (_schedules.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: context.xl * 1.5),
                                    child: Column(
                                      children: [
                                        Icon(Icons.event_busy, size: context.scale(48), color: colorScheme.outline),
                                        SizedBox(height: context.md),
                                        Text(
                                          "No schedules found for this exam.",
                                          style: TextStyle(color: colorScheme.outline, fontSize: context.font(14)),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: context.responsive(600.0, tablet: 900.0, desktop: 1100.0)),
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
                                      columnSpacing: context.md * 1.5,
                                      dataRowMinHeight: context.scale(60),
                                      dataRowMaxHeight: context.scale(70),
                                      columns: [
                                        DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                        DataColumn(label: Text("Subject", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                        DataColumn(label: Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                        DataColumn(label: Text("Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                        DataColumn(label: Text("Room", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
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
                                          DataCell(Text(index.toString(), style: TextStyle(fontSize: context.font(14)))),
                                          DataCell(Text(subjectName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: context.font(14)))),
                                          DataCell(Text(s['date']?.toString() ?? 'N/A', style: TextStyle(fontSize: context.font(14)))),
                                          DataCell(Text("${s['start_time'] ?? ''} - ${s['end_time'] ?? ''}", style: TextStyle(fontSize: context.font(14)))),
                                          DataCell(Text(roomName, style: TextStyle(fontSize: context.font(14)))),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              SizedBox(height: context.md),
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
      margin: EdgeInsets.only(left: context.scale(8)),
      padding: EdgeInsets.all(context.scale(8)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(8)),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Icon(icon, color: color, size: context.scale(18)),
    );
  }
}
