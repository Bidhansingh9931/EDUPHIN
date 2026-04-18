import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'counselor_models.dart';

class CounselorClassRoutinePage extends StatefulWidget {
  const CounselorClassRoutinePage({super.key});

  @override
  State<CounselorClassRoutinePage> createState() => _CounselorClassRoutinePageState();
}

class _CounselorClassRoutinePageState extends State<CounselorClassRoutinePage> {
  bool _isLoading = true;
  List<ClassSchedule> _schedules = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiService.get('counselor/schedules');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            dynamic scheduleData = data['schedules'] ?? data['data'] ?? [];
            List rawList = [];
            if (scheduleData is List) {
              rawList = scheduleData;
            } else if (scheduleData is Map && scheduleData['data'] is List) {
              rawList = scheduleData['data'];
            }
            
            _schedules = rawList.map((json) => ClassSchedule.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = ApiService.errorMessage(response, "Failed to load schedules");
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Class Routines",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSchedules,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(context.spacing * 1.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: theme.colorScheme.error, size: context.scale(48)),
                          SizedBox(height: context.md),
                          Text(_errorMessage!, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error)),
                          SizedBox(height: context.lg),
                          FilledButton.icon(onPressed: _fetchSchedules, icon: const Icon(Icons.refresh), label: const Text("RETRY")),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: context.pagePadding,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: context.scale(1000)),
                        child: Card(
                          elevation: 0,
                          color: theme.colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.scale(16)),
                            side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(context.spacing),
                                child: Text(
                                  "Weekly Schedule",
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
                                ),
                              ),
                              Divider(height: 1, color: theme.colorScheme.outlineVariant),
                              if (_schedules.isEmpty)
                                Padding(
                                  padding: EdgeInsets.all(context.scale(40.0)),
                                  child: Center(
                                    child: Text(
                                      "No routines found",
                                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                  ),
                                )
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: context.scale(24),
                                    headingTextStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: context.font(13)),
                                    dataTextStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(12)),
                                    columns: const [
                                      DataColumn(label: Text("Day")),
                                      DataColumn(label: Text("Time")),
                                      DataColumn(label: Text("Class")),
                                      DataColumn(label: Text("Subject")),
                                      DataColumn(label: Text("Teacher")),
                                    ],
                                    rows: _schedules.map((schedule) {
                                      return DataRow(cells: [
                                        DataCell(Text(schedule.day ?? "-")),
                                        DataCell(Text("${schedule.startTime} - ${schedule.endTime}")),
                                        DataCell(Text("${schedule.className} (${schedule.sectionName})")),
                                        DataCell(Text(schedule.subjectName ?? "-")),
                                        DataCell(Text(schedule.teacherName ?? "-")),
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
