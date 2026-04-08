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
    final theme = Theme.of(context);

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
                padding: const EdgeInsets.all(24.0),
                child: Text('Error: $error', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.exams.isNotEmpty) {
            final midTermExams = snapshot.data!.exams.where((exam) => exam.type.toLowerCase().contains('mid')).toList();
            if (midTermExams.isEmpty) {
              return const Center(child: Text('No mid-term exams found.'));
            }
            return ListView.builder(
              padding: context.pagePadding,
              itemCount: midTermExams.length,
              itemBuilder: (context, index) {
                final exam = midTermExams[index];
                return _buildExamCard(context, exam);
              },
            );
          } else {
            return const Center(child: Text('No exams found.'));
          }
        },
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, TeacherExam exam) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exam.name,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (exam.description != null)
              Text(
                exam.description!,
                style: TextStyle(color: theme.hintColor),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExamSchedulePage(examId: exam.id),
                  ),
                );
              },
              child: const Text('VIEW SCHEDULE'),
            ),
          ],
        ),
      ),
    );
  }
}
