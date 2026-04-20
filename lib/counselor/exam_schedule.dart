import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/caching_service.dart';
import '../services/common_widgets.dart';
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
  String get _cacheKey => 'counselor_exam_schedule_${widget.exam.id}';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchSchedule();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CachingService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      final List scheduleData = cachedData['data']?['schedules'] ?? [];
      setState(() {
        _schedules = scheduleData.map((e) => ExamPaperSchedule.fromJson(e)).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSchedule() async {
    if (_schedules.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final response = await ApiService.get('counselor/exams/${widget.exam.id}/schedule');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await CachingService.saveData(_cacheKey, data);
        if (mounted) {
          final List scheduleData = data['data']?['schedules'] ?? [];
          setState(() {
            _schedules = scheduleData.map((e) => ExamPaperSchedule.fromJson(e)).toList();
            _isLoading = false;
            _errorMessage = null;
          });
        }
      } else {
        if (mounted && _schedules.isEmpty) {
          setState(() {
            _errorMessage = ApiService.errorMessage(response, "Failed to load schedule");
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted && _schedules.isEmpty) {
        setState(() {
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(1000)),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.scale(16)),
              side: BorderSide(color: context.theme.colorScheme.outlineVariant, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(context.spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Skeleton(width: 120, height: 20),
                      SizedBox(height: context.scale(8)),
                      const Skeleton(width: 180, height: 14),
                      SizedBox(height: context.scale(4)),
                      const Skeleton(width: 150, height: 14),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: EdgeInsets.all(context.spacing),
                  child: Column(
                    children: List.generate(
                      5,
                      (index) => Padding(
                        padding: EdgeInsets.symmetric(vertical: context.scale(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (i) => Skeleton(width: context.scale(50), height: 12)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "${widget.exam.name} Schedule",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSchedule,
        child: LoadingWrapper(
          isLoading: _isLoading,
          hasData: _schedules.isNotEmpty,
          skeleton: _buildSkeleton(),
          child: _errorMessage != null && _schedules.isEmpty
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
                        FilledButton.icon(onPressed: _fetchSchedule, icon: const Icon(Icons.refresh), label: const Text("RETRY")),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Exam Details",
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
                                  ),
                                  SizedBox(height: context.scale(8)),
                                  Text(
                                    "Type: ${widget.exam.type ?? 'N/A'}",
                                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(13)),
                                  ),
                                  Text(
                                    "Code: ${widget.exam.code ?? 'N/A'}",
                                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(13)),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: theme.colorScheme.outlineVariant),
                            if (_schedules.isEmpty)
                              Padding(
                                padding: EdgeInsets.all(context.scale(40.0)),
                                child: Center(
                                  child: Text(
                                    "No schedule found for this exam",
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
                                    DataColumn(label: Text("Date")),
                                    DataColumn(label: Text("Time")),
                                    DataColumn(label: Text("Subject")),
                                    DataColumn(label: Text("Class")),
                                    DataColumn(label: Text("Room")),
                                  ],
                                  rows: _schedules.map((s) {
                                    return DataRow(cells: [
                                      DataCell(Text(s.date ?? "-")),
                                      DataCell(Text("${s.startTime} - ${s.endTime}")),
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
      ),
    );
  }
}



