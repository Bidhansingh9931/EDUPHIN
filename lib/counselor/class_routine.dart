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
            _errorMessage = "Failed to load schedules";
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
        title: const Text("Class Routines"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSchedules,
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
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text("Weekly Schedule", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              ),
                              const Divider(height: 1),
                              if (_schedules.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(40.0),
                                  child: Center(child: Text("No routines found")),
                                )
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: 24,
                                    columns: const [
                                      DataColumn(label: Text("Day", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Time", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Class", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Subject", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Teacher", style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                    rows: _schedules.map((schedule) {
                                      return DataRow(cells: [
                                        DataCell(Text(schedule.day ?? "-")),
                                        DataCell(Text("${schedule.startTime} - ${schedule.endTime}", style: const TextStyle(fontSize: 12))),
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
