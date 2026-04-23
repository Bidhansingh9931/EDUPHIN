import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
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
  ExamScheduleData? _scheduleData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (widget.examId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final cacheKey = 'exam_schedule_${widget.examId}';
    final cachedData = await TeacherCacheService.load(cacheKey);
    if (cachedData != null && mounted) {
      setState(() {
        _scheduleData = ExamScheduleData.fromJson(cachedData);
        _isLoading = false;
      });
    }
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    if (widget.examId == null || !mounted) return;
    if (_scheduleData == null) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await ApiService.getExamSchedule(widget.examId!);
      if (mounted) {
        setState(() {
          _scheduleData = data;
          _isLoading = false;
        });
        await TeacherCacheService.save('exam_schedule_${widget.examId}', data.toJson());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.calendar_month_outlined, size: context.scale(20)),
            SizedBox(width: context.scale(12)),
            const Expanded(
              child: Text(
                "Examination Paper Schedule",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: TeacherLoadingWrapper(
        isLoading: _isLoading,
        hasData: _scheduleData != null,
        skeleton: _buildSkeleton(context),
        child: RefreshIndicator(
          onRefresh: _fetchSchedule,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.scale(1000)),
              child: widget.examId == null 
                ? _buildPlaceholderContent()
                : _scheduleData != null 
                  ? ListView(
                      padding: context.pagePadding,
                      children: [
                        _buildExamScheduleCard(_scheduleData!),
                      ],
                    )
                  : const Center(child: Text("No data found")),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView(
      padding: context.pagePadding,
      children: [
        TeacherSkeleton(height: context.scale(250), borderRadius: BorderRadius.circular(16)),
      ],
    );
  }

  Widget _buildPlaceholderContent() {
    return ListView(
      padding: context.pagePadding,
      children: [
        _buildManualScheduleCard("Class: Financial Accounting Basics - Section: A"),
        SizedBox(height: context.spacing),
        _buildManualScheduleCard("Class: Cost Analysis and Management - Section: A"),
      ],
    );
  }

  Widget _buildExamScheduleCard(ExamScheduleData data) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(context.spacing),
            child: Column(
              children: [
                Icon(Icons.layers_outlined, color: theme.colorScheme.primary, size: context.scale(32)),
                SizedBox(height: context.scale(12)),
                Text(data.exam.name, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                SizedBox(height: context.scale(12)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(6)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.scale(8)),
                  ),
                  child: Text("Total Papers: ${data.schedules.length}", style: TextStyle(fontSize: context.font(11), fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          _buildScheduleTable(data.schedules),
        ],
      ),
    );
  }

  Widget _buildManualScheduleCard(String classTitle) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(context.spacing),
            child: Column(
              children: [
                Icon(Icons.layers_outlined, color: theme.colorScheme.primary, size: context.scale(32)),
                SizedBox(height: context.scale(12)),
                Text(classTitle, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                SizedBox(height: context.scale(12)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(6)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.scale(8)),
                  ),
                  child: Text("Total Papers: 1", style: TextStyle(fontSize: context.font(11), fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          _buildManualScheduleTable(),
        ],
      ),
    );
  }

  Widget _buildScheduleTable(List<ExamSchedule> schedules) {
    final theme = context.theme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: DataTable(
          columnSpacing: context.scale(24),
          headingRowHeight: context.scale(40),
          dataRowMaxHeight: context.scale(48),
          headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
          columns: [
            DataColumn(label: Text("Subject", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
            DataColumn(label: Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
            DataColumn(label: Text("Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
            DataColumn(label: Text("Venue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
          ],
          rows: schedules.map((s) => DataRow(cells: [
              DataCell(Text(s.subjectName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13)))),
              DataCell(Text(s.date, style: TextStyle(fontSize: context.font(13)))),
              DataCell(Text("${s.startTime} - ${s.endTime}", style: TextStyle(fontSize: context.font(13)))),
              DataCell(Text(s.roomNo ?? "N/A", style: TextStyle(fontSize: context.font(13)))),
          ])).toList(),
        ),
      ),
    );
  }

  Widget _buildManualScheduleTable() {
    final theme = context.theme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: DataTable(
          columnSpacing: context.scale(24),
          headingRowHeight: context.scale(40),
          dataRowMaxHeight: context.scale(48),
          headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
          columns: [
            DataColumn(label: Text("Subject", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
            DataColumn(label: Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
            DataColumn(label: Text("Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
            DataColumn(label: Text("Venue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text("Principles of Accounting", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13)))),
              DataCell(Text("04 Oct 2025", style: TextStyle(fontSize: context.font(13)))),
              DataCell(Text("09:00 AM - 12:00 PM", style: TextStyle(fontSize: context.font(13)))),
              DataCell(Text("Room 101", style: TextStyle(fontSize: context.font(13)))),
            ]),
          ],
        ),
      ),
    );
  }
}
