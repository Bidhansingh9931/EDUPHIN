import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:eduphin/teacher/dashboard/exam_schedule_page.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/exam_models.dart';

class MidTermExamPage extends StatefulWidget {
  const MidTermExamPage({super.key});

  @override
  State<MidTermExamPage> createState() => _MidTermExamPageState();
}

class _MidTermExamPageState extends State<MidTermExamPage> {
  bool _isLoading = true;
  List<TeacherExam>? _exams;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Load from cache first
    final cachedData = await TeacherCacheService.load('midterm_exams');
    if (cachedData != null && mounted) {
      setState(() {
        _exams = ExamPageData.fromJson(cachedData).exams;
        _isLoading = _exams == null; // Keep loading if cache was somehow null
      });
    }

    // 2. Fetch from API
    try {
      final data = await ApiService.getTeacherExams();
      await TeacherCacheService.save('midterm_exams', data.toJson());

      if (mounted) {
        setState(() {
          _exams = data.exams;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final midTermExams = _exams?.where((exam) => exam.type.toLowerCase().contains('mid')).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mid-Term Examinations'),
      ),
      body: TeacherLoadingWrapper(
        isLoading: _isLoading,
        hasData: midTermExams != null,
        skeleton: _buildSkeleton(context),
        child: _error != null && (midTermExams == null || midTermExams.isEmpty)
            ? Center(
                child: Padding(
                  padding: context.pagePadding,
                  child: Text('Error: $_error', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14))),
                ),
              )
            : midTermExams == null || midTermExams.isEmpty
                ? Center(child: Text('No mid-term exams found.', style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant)))
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: ListView.builder(
                        padding: context.pagePadding,
                        itemCount: midTermExams.length,
                        itemBuilder: (context, index) {
                          final exam = midTermExams[index];
                          return _buildExamCard(context, exam);
                        },
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        margin: EdgeInsets.only(bottom: context.spacing),
        elevation: 0,
        color: context.theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.scale(20)),
          side: BorderSide(color: context.theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TeacherSkeleton(width: context.scale(38), height: context.scale(38), borderRadius: BorderRadius.circular(context.scale(10))),
                  SizedBox(width: context.scale(12)),
                  Expanded(child: TeacherSkeleton(height: context.font(20), width: context.scale(150))),
                ],
              ),
              SizedBox(height: context.scale(12)),
              TeacherSkeleton(height: context.font(14), width: double.infinity),
              SizedBox(height: context.scale(4)),
              TeacherSkeleton(height: context.font(14), width: context.scale(200)),
              SizedBox(height: context.spacing),
              TeacherSkeleton(height: context.scale(48), borderRadius: BorderRadius.circular(context.scale(12))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, TeacherExam exam) {
    final theme = context.theme;
    return Card(
      margin: EdgeInsets.only(bottom: context.spacing),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.scale(8)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.scale(10)),
                  ),
                  child: Icon(Icons.assignment_outlined, color: theme.colorScheme.primary, size: context.scale(22)),
                ),
                SizedBox(width: context.scale(12)),
                Expanded(
                  child: Text(
                    exam.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(16),
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            if (exam.description != null) ...[
              SizedBox(height: context.scale(12)),
              Text(
                exam.description!,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: context.font(14),
                  height: 1.4,
                ),
              ),
            ],
            SizedBox(height: context.spacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExamSchedulePage(examId: exam.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                  elevation: 0,
                ),
                child: Text('VIEW SCHEDULE', style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
