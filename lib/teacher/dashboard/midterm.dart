import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/exam_schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/exam_models.dart';

class MidTermExamPage extends StatefulWidget {
  const MidTermExamPage({super.key});

  @override
  State<MidTermExamPage> createState() => _MidTermExamPageState();
}

class _MidTermExamPageState extends State<MidTermExamPage> {
  late Future<ExamPageData> _examsFuture;

  @override
  void initState() {
    super.initState();
    _examsFuture = ApiService.getTeacherExams();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mid-Term Examinations'),
      ),
      body: FutureBuilder<ExamPageData>(
        future: _examsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            final error = snapshot.error.toString();
            return Center(
              child: Padding(
                padding: context.pagePadding,
                child: Text('Error: $error', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14))),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.exams.isNotEmpty) {
            final midTermExams = snapshot.data!.exams.where((exam) => exam.type.toLowerCase().contains('mid')).toList();
            if (midTermExams.isEmpty) {
              return Center(child: Text('No mid-term exams found.', style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant)));
            }
            return Center(
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
            );
          } else {
            return Center(child: Text('No exams found.', style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant)));
          }
        },
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
