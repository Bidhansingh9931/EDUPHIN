import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Exam {
  final int id;
  final String name;

  Exam({required this.id, required this.name});

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Exam',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

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
  final String date;
  final String startTime;
  final String endTime;

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
      sectionName: json['section']?['name']?.toString() ?? 'N/A',
      subjectName: json['subject']?['name']?.toString() ?? 'N/A',
      venue: json['venue']?.toString() ?? '-',
      date: json['paper_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exam_id': examId,
    'class_id': classId,
    'section_id': sectionId,
    'subject_id': subjectId,
    'class': {'name': className},
    'section': {'name': sectionName},
    'subject': {'name': subjectName},
    'venue': venue,
    'paper_date': date,
    'start_time': startTime,
    'end_time': endTime,
  };
}

class ExamWithPapers {
  final Exam exam;
  final List<ExamPaper> papers;

  ExamWithPapers({required this.exam, required this.papers});

  factory ExamWithPapers.fromJson(Map<String, dynamic> json) {
    return ExamWithPapers(
      exam: Exam.fromJson(json['exam']),
      papers: (json['papers'] as List).map((p) => ExamPaper.fromJson(p)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'exam': exam.toJson(),
    'papers': papers.map((p) => p.toJson()).toList(),
  };
}

class ExamResultPage extends StatefulWidget {
  const ExamResultPage({super.key});

  @override
  State<StatefulWidget> createState() => _ExamResultPageState();
}

class _ExamResultPageState extends State<ExamResultPage> {
  bool _isLoading = true;
  List<ExamWithPapers> _examData = [];
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetch();
  }

  Future<void> _loadCacheAndFetch() async {
    final cachedData = await CacheService.getCache('manager_exam_results');
    if (cachedData != null && mounted) {
      final List<dynamic> jsonList = cachedData;
      setState(() {
        _examData = jsonList.map((json) => ExamWithPapers.fromJson(json)).toList();
        _isLoading = _examData.isEmpty;
      });
    }
    _fetchExamData();
  }

  Future<void> _fetchExamData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final examsResponse = await ApiService.get('manager/exams');
      if (examsResponse.statusCode != 200) {
        throw Exception('Failed to load exams');
      }

      final List<dynamic> examsJson = json.decode(examsResponse.body)['data'];
      final List<Exam> exams = examsJson.map((e) => Exam.fromJson(e)).toList();

      final paperFutures = exams.map((exam) async {
        final scheduleResponse = await ApiService.get('manager/exams/${exam.id}/schedule');

        if (scheduleResponse.statusCode == 200) {
          final List<dynamic>? papersJson = json.decode(scheduleResponse.body)['data'];
          if (papersJson != null) {
            final papers = papersJson.map((p) => ExamPaper.fromJson(p)).toList();
            return ExamWithPapers(exam: exam, papers: papers);
          }
        }
        return ExamWithPapers(exam: exam, papers: []);
      }).toList();

      final results = await Future.wait(paperFutures);
      final filteredResults = results.where((e) => e.papers.isNotEmpty).toList();

      await CacheService.setCache('manager_exam_results', filteredResults.map((e) => e.toJson()).toList());

      if (mounted) {
        setState(() {
          _examData = filteredResults;
          _isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Exam Results", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(20))),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LoadingWrapper(
            isLoading: _isLoading,
            hasData: _examData.isNotEmpty,
            error: _error,
            onRetry: _fetchExamData,
            skeleton: _buildSkeleton(),
            child: RefreshIndicator(
              onRefresh: () async => _fetchExamData(),
              child: _examData.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in_outlined, size: context.scale(64), color: theme.colorScheme.outlineVariant),
                            SizedBox(height: context.md),
                            Text('No exam schedules found.', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: context.pagePadding,
                      itemCount: _examData.length,
                      itemBuilder: (context, index) {
                        final examWithPapers = _examData[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: context.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    examWithPapers.exam.name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.font(18),
                                    ),
                                  ),
                                  Text(
                                    "Select a paper to manage marks",
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: context.font(11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                                crossAxisSpacing: context.spacing,
                                mainAxisSpacing: context.spacing,
                                mainAxisExtent: context.scale(260),
                              ),
                              itemCount: examWithPapers.papers.length,
                              itemBuilder: (context, pIndex) => _buildPaperItem(examWithPapers.papers[pIndex]),
                            ),
                            SizedBox(height: context.lg),
                          ],
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: 2,
      itemBuilder: (context, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.md),
            child: SkeletonBox(height: context.scale(40), width: context.scale(200)),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
              crossAxisSpacing: context.spacing,
              mainAxisSpacing: context.spacing,
              mainAxisExtent: context.scale(260),
            ),
            itemCount: 3,
            itemBuilder: (context, pIndex) => SkeletonBox(height: context.scale(260), borderRadius: context.scale(16)),
          ),
          SizedBox(height: context.lg),
        ],
      ),
    );
  }


  Widget _buildPaperItem(ExamPaper paper) {
    final theme = context.theme;
    String formattedDate = "N/A";
    String formattedStartTime = "N/A";
    String formattedEndTime = "N/A";

    try {
      if (paper.date.isNotEmpty) {
        formattedDate = DateFormat('d MMM yyyy').format(DateTime.parse(paper.date));
      }
    } catch (e) {}

    try {
      if (paper.startTime.isNotEmpty) {
        formattedStartTime = DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(paper.startTime));
      }
    } catch (e) {}

    try {
      if (paper.endTime.isNotEmpty) {
        formattedEndTime = DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(paper.endTime));
      }
    } catch (e) {}

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
