import 'dart:convert';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/manager_dashboard/examinations/edit_schedule.dart';
import 'package:eduphin/manager_dashboard/examinations/add_schedule.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExamPaper {
  final int id;
  final int examId;
  final int classId;
  final int sectionId;
  final int subjectId;
  final String className;
  final String sectionName;
  final String subjectName;
  final String? venue;
  final String? date;
  final String? startTime;
  final String? endTime;

  ExamPaper({
    required this.id,
    required this.examId,
    required this.classId,
    required this.sectionId,
    required this.subjectId,
    required this.className,
    required this.sectionName,
    required this.subjectName,
    this.venue,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory ExamPaper.fromJson(Map<String, dynamic> json) {
    return ExamPaper(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      examId: int.tryParse(json['exam_id']?.toString() ?? '') ?? 0,
      classId: int.tryParse(json['class_id']?.toString() ?? '') ?? 0,
      sectionId: int.tryParse(json['section_id']?.toString() ?? '') ?? 0,
      subjectId: int.tryParse(json['subject_id']?.toString() ?? '') ?? 0,
      className: json['class']?['name']?.toString() ?? 'N/A',
      sectionName: (json['section']?['section_name'] ?? json['section']?['name'])?.toString() ?? 'N/A',
      subjectName: json['subject']?['name']?.toString() ?? 'N/A',
      venue: json['venue']?.toString() ?? '-',
      date: json['paper_date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
    );
  }
}

class ManageSchedulePage extends StatefulWidget {
  final int examId;
  final String examName;

  const ManageSchedulePage({
    super.key,
    required this.examId,
    required this.examName,
  });

  @override
  State<StatefulWidget> createState() => _ManageSchedulePageState();
}

class _ManageSchedulePageState extends State<ManageSchedulePage> {
  bool _isLoading = true;
  List<ExamPaper> _papers = [];
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetch();
  }

  Future<void> _loadCacheAndFetch() async {
    final cacheKey = 'manager_exam_schedule_${widget.examId}';
    final cachedData = await CacheService.getCache(cacheKey);
    if (cachedData != null && mounted) {
      final List<dynamic> paperJson = cachedData;
      setState(() {
        _papers = paperJson.map((json) => ExamPaper.fromJson(json)).toList();
      });
    }
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    if (!mounted) return;
    setState(() {
      _isLoading = _papers.isEmpty;
      _error = null;
    });

    try {
      final response = await ApiService.get('manager/exams/${widget.examId}/schedule');
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> paperJson = body['data'] ?? [];
        await CacheService.setCache('manager_exam_schedule_${widget.examId}', paperJson);
        if (mounted) {
          setState(() {
            _papers = paperJson.map((json) => ExamPaper.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load schedule. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
        ErrorHandler.showError(context, e);
      }
    }
  }

  void _refreshSchedule() {
    _fetchSchedule();
  }

  Future<void> _deleteSchedule(int paperId) async {
    final bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this schedule entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await ApiService.post('manager/exams/${widget.examId}/schedule/$paperId', {
        '_method': 'DELETE',
      });
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule deleted successfully!')),
        );
        _refreshSchedule();
      } else {
        throw Exception('Failed to delete schedule. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showError(context, e);
    }
  }

  void _navigateToAddSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddScheduleScreen(examId: widget.examId),
      ),
    ).then((value) {
      if (value == true) {
        _refreshSchedule();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.examName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(20))),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddSchedule,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: Icon(Icons.add, size: context.scale(24)),
        label: Text("Add Schedule", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LoadingWrapper(
            isLoading: _isLoading,
            hasData: _papers.isNotEmpty,
            error: _error,
            onRetry: _refreshSchedule,
            skeleton: _buildSkeleton(),
            child: RefreshIndicator(
              onRefresh: () async => _refreshSchedule(),
              child: _papers.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: context.scale(64), color: theme.colorScheme.outlineVariant),
                            SizedBox(height: context.md),
                            Text('No schedule found for this exam.', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.fromLTRB(context.spacing, context.spacing, context.spacing, context.scale(80)),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                        crossAxisSpacing: context.spacing,
                        mainAxisSpacing: context.spacing,
                        mainAxisExtent: context.scale(230),
                      ),
                      itemCount: _papers.length,
                      itemBuilder: (context, index) => _buildPaperItem(_papers[index]),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return GridView.builder(
      padding: EdgeInsets.all(context.spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
        crossAxisSpacing: context.spacing,
        mainAxisSpacing: context.spacing,
        mainAxisExtent: context.scale(230),
      ),
      itemCount: 6,
      itemBuilder: (context, index) => SkeletonBox(height: context.scale(230), borderRadius: context.scale(16)),
    );
  }


  Widget _buildPaperItem(ExamPaper paper) {
    final theme = context.theme;
    final formattedDate = paper.date != null ? DateFormat('d MMM yyyy').format(DateTime.parse(paper.date!)) : "N/A";
    final formattedStartTime = paper.startTime != null ? DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(paper.startTime!)) : "N/A";
    final formattedEndTime = paper.endTime != null ? DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(paper.endTime!)) : "N/A";

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.class_outlined, size: context.scale(20), color: theme.colorScheme.primary),
                SizedBox(width: context.sm),
                Expanded(
                  child: Text(
                    "Class ${paper.className} - ${paper.sectionName}",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.md),
            _buildInfoRow(context, "Subject", paper.subjectName, Icons.book_outlined),
            SizedBox(height: context.sm),
            _buildInfoRow(context, "Venue", paper.venue ?? 'N/A', Icons.location_on_outlined),
            SizedBox(height: context.sm),
            _buildInfoRow(context, "Schedule", "$formattedDate • $formattedStartTime - $formattedEndTime", Icons.schedule_outlined),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteSchedule(paper.id),
                    icon: Icon(Icons.delete_outline, size: context.scale(18)),
                    label: const Text("Delete"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                  ),
                ),
                SizedBox(width: context.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditScheduleScreen(
                            paperId: paper.id,
                            examId: paper.examId,
                            initialClassId: paper.classId,
                            initialSectionId: paper.sectionId,
                            initialSubjectId: paper.subjectId,
                            initialVenue: paper.venue,
                            initialDate: paper.date,
                            initialStartTime: paper.startTime,
                            initialEndTime: paper.endTime,
                          ),
                        ),
                      );
                      if (result == true) {
                        _refreshSchedule();
                      }
                    },
                    icon: Icon(Icons.edit_outlined, size: context.scale(18)),
                    label: const Text("Edit"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, size: context.scale(16), color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: context.sm),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

