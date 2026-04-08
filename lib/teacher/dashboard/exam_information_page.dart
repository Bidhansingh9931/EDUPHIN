import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/exam_models.dart';
import 'common_widgets.dart';
import 'exam_schedule_page.dart';

class ExamInformationPage extends StatefulWidget {
  const ExamInformationPage({super.key});

  @override
  State<ExamInformationPage> createState() => _ExamInformationPageState();
}

class _ExamInformationPageState extends State<ExamInformationPage> {
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
        title: const Text("Exam Information"),
      ),
      body: FutureBuilder<ExamPageData>(
        future: _examsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.exams.isEmpty) {
            return const Center(child: Text("No exams found."));
          }

          final exams = snapshot.data!.exams;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exams.length,
            itemBuilder: (context, index) => _buildExamCard(exams[index]),
          );
        },
      ),
    );
  }

  Widget _buildExamCard(TeacherExam exam) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(exam.name, 
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: Text(exam.code, 
                    style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(exam.description ?? "General examination information and instructions.", 
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)
            ),
            const Divider(height: 32),
            Row(
              children: [
                _infoTile(Icons.calendar_today, "Starts", exam.startDate),
                const SizedBox(width: 24),
                _infoTile(Icons.event_available, "Ends", exam.endDate),
              ],
            ),
            const SizedBox(height: 24),
            buildActionButton(
              context, 
              "VIEW FULL SCHEDULE", 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExamSchedulePage(examId: exam.id))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String date) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(label, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(date, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
