import 'dart:convert';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/error_handler.dart';
import '../services/caching_service.dart';
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
    _loadCachedData();
    _fetchSchedules();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CachingService.getData('counselor_schedules');
    if (cachedData != null && mounted) {
      setState(() {
        _schedules = (cachedData as List).map((json) => ClassSchedule.fromJson(json)).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSchedules() async {
    if (!mounted) return;
    if (_schedules.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
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
            
            CachingService.saveData('counselor_schedules', rawList);

            _schedules = rawList.map((json) => ClassSchedule.fromJson(json)).toList();
            _isLoading = false;
            _errorMessage = null;
          });
        }
      } else {
        if (mounted) {
          if (_schedules.isEmpty) {
            setState(() {
              _errorMessage = ApiService.errorMessage(response, "Failed to load schedules");
              _isLoading = false;
            });
          }
          ErrorHandler.showError(context, "Status: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (mounted) {
        if (_schedules.isEmpty) {
          setState(() {
            _errorMessage = ErrorHandler.getMessage(e);
            _isLoading = false;
          });
        }
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            "Class Routines",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
          ),
        ),
        centerTitle: false,
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _schedules.isNotEmpty,
        error: _errorMessage,
        skeleton: _buildSkeleton(context),
        onRetry: _fetchSchedules,
        onRefresh: _fetchSchedules,
        child: SingleChildScrollView(
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

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        children: [
          Skeleton(height: context.scale(60)),
          SizedBox(height: context.spacing),
          ...List.generate(8, (index) => Column(
            children: [
              Skeleton(height: context.scale(50)),
              SizedBox(height: context.scale(2)),
            ],
          )),
        ],
      ),
    );
  }
}

