import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'enter_marks_page.dart';

// Models for API data

class Exam {
  final int id;
  final String name;

  Exam({required this.id, required this.name});

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Exam',
    );
  }
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
      id: json['id'] ?? 0,
      examId: json['exam_id'] ?? 0,
      classId: json['class_id'] ?? 0,
      sectionId: json['section_id'] ?? 0,
      subjectId: json['subject_id'] ?? 0,
      className: json['class']?['name']?.toString() ?? 'N/A',
      sectionName: json['section']?['name']?.toString() ?? 'N/A',
      subjectName: json['subject']?['name']?.toString() ?? 'N/A',
      venue: json['venue']?.toString() ?? '-',
      date: json['paper_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
    );
  }
}

class ExamWithPapers {
  final Exam exam;
  final List<ExamPaper> papers;

  ExamWithPapers({required this.exam, required this.papers});
}

class ExamResultPage extends StatefulWidget {
  const ExamResultPage({super.key});

  @override
  State<StatefulWidget> createState() => _ExamResultPageState();
}

class _ExamResultPageState extends State<ExamResultPage> {
  late Future<List<ExamWithPapers>> _examDataFuture;

  @override
  void initState() {
    super.initState();
    _examDataFuture = _fetchExamData();
  }

  Future<List<ExamWithPapers>> _fetchExamData() async {
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

      return results.where((e) => e.papers.isNotEmpty).toList();
    } catch (e) {
      throw Exception('Failed to fetch exam data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Results"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ExamWithPapers>>(
        future: _examDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exam schedules found.'));
          }

          final examData = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: examData.map((examWithPapers) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.book, color: theme.colorScheme.onSurface, size: 18),
                        const SizedBox(width: 5),
                        Flexible(
                            child: Text(examWithPapers.exam.name, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface, fontSize: 18))),
                      ]),
                      Text(
                        "Papers assigned for this exam, grouped by class and section.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha(150), fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      ...examWithPapers.papers.map((paper) {
                        String formattedDate = "N/A";
                        String formattedStartTime = "N/A";
                        String formattedEndTime = "N/A";

                        try {
                          if (paper.date.isNotEmpty) {
                            formattedDate = DateFormat('d MMM yyyy').format(DateTime.parse(paper.date));
                          }
                        } catch (e) { /* Gracefully handle parse error */ }

                        try {
                          if (paper.startTime.isNotEmpty) {
                            formattedStartTime = DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(paper.startTime));
                          }
                        } catch (e) { /* Gracefully handle parse error */ }

                        try {
                          if (paper.endTime.isNotEmpty) {
                            formattedEndTime = DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(paper.endTime));
                          }
                        } catch (e) { /* Gracefully handle parse error */ }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: CustomExamResultContainerBox(
                            paperId: paper.id,
                            examId: paper.examId,
                            classId: paper.classId,
                            sectionId: paper.sectionId,
                            subjectId: paper.subjectId,
                            heading: "Class: ${paper.className}",
                            section: "Section: ${paper.sectionName}",
                            subject: paper.subjectName,
                            venue: paper.venue ?? 'N/A',
                            date: formattedDate,
                            time: '$formattedStartTime - $formattedEndTime',
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomExamResultContainerBox extends StatelessWidget {
  final int paperId;
  final int examId;
  final int classId;
  final int sectionId;
  final int subjectId;
  final String heading;
  final String subject;
  final String section;
  final String venue;
  final String date;
  final String time;

  const CustomExamResultContainerBox({
    super.key,
    required this.paperId,
    required this.examId,
    required this.classId,
    required this.sectionId,
    required this.subjectId,
    required this.heading,
    required this.subject,
    required this.section,
    required this.venue,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    heading,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary),
                  ),
                ),
                Text(" | ", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                Text(section, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("SUBJECT", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(150))),
                      Text(subject, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                    ],
                  ),
                ),
                const SizedBox(width: 50),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("VENUE", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(150))),
                      Text(venue, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(150))),
                      Text(date, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                    ],
                  ),
                ),
                const SizedBox(width: 50),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Time", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(150))),
                      Text(time, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(
              color: theme.colorScheme.onPrimary.withAlpha(180),
              thickness: 1,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EnterMarksPage(
                              paperId: paperId,
                              examId: examId,
                              classId: classId,
                              sectionId: sectionId,
                              subjectId: subjectId,
                              subjectName: subject,
                            )));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(
                Icons.edit,
                size: 16,
              ),
              label: const Text("Enter Marks"),
            ),
          ],
        ),
      ),
    );
  }
}
