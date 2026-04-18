import 'package:eduphin/services/responsive_helper.dart';
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
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Information"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.responsive(800.0, tablet: 1000.0, desktop: 1200.0)),
          child: FutureBuilder<ExamPageData>(
            future: _examsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(fontSize: context.font(14))));
              } else if (!snapshot.hasData || snapshot.data!.exams.isEmpty) {
                return Center(child: Text("No exams found.", style: TextStyle(fontSize: context.font(14))));
              }

              final exams = snapshot.data!.exams;
              return ListView.builder(
                padding: context.pagePadding,
                itemCount: exams.length,
                itemBuilder: (context, index) => _buildExamCard(exams[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExamCard(TeacherExam exam) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: context.scale(20)),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(20.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(exam.name, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(16),
                      color: colorScheme.onSurface,
                    )
                  )
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(context.scale(8))
                  ),
                  child: Text(exam.code, 
                    style: TextStyle(
                      color: colorScheme.primary, 
                      fontSize: context.font(10), 
                      fontWeight: FontWeight.bold
                    )
                  ),
                )
              ],
            ),
            SizedBox(height: context.scale(12)),
            Text(exam.description ?? "General examination information and instructions.", 
              style: TextStyle(
                fontSize: context.font(12),
                color: colorScheme.onSurfaceVariant,
              )
            ),
            Divider(height: context.scale(32), color: colorScheme.outlineVariant),
            Row(
              children: [
                _infoTile(Icons.calendar_today, "Starts", exam.startDate),
                SizedBox(width: context.scale(24)),
                _infoTile(Icons.event_available, "Ends", exam.endDate),
              ],
            ),
            SizedBox(height: context.scale(24)),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: context.scale(14), color: colorScheme.primary),
            SizedBox(width: context.scale(6)),
            Text(label, style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: context.font(11),
              color: colorScheme.onSurfaceVariant,
            )),
          ],
        ),
        SizedBox(height: context.scale(4)),
        Text(date, style: TextStyle(
          fontSize: context.font(12),
          color: colorScheme.onSurface,
        )),
      ],
    );
  }
}

