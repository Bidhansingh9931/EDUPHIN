import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'enter_marks_page.dart';

// Data model for a single paper in a schedule
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
      id: json['id'],
      examId: json['exam_id'],
      classId: json['class_id'],
      sectionId: json['section_id'],
      subjectId: json['subject_id'],
      className: json['class']?['name'] ?? 'N/A',
      sectionName: json['section']?['name'] ?? 'N/A',
      subjectName: json['subject']?['name'] ?? 'N/A',
      venue: json['venue'] ?? '-',
      date: json['paper_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

class ManageSchedulePage extends StatefulWidget {
  // Pass these values when navigating to this page
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
  late Future<List<ExamPaper>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _scheduleFuture = _fetchSchedule();
  }

  Future<List<ExamPaper>> _fetchSchedule() async {
    try {
      final response = await ApiService.get('manager/exams/${widget.examId}/schedule');
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)['data'] ?? [];
        return jsonData.map((e) => ExamPaper.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load schedule. Status code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _deleteSchedule(int paperId) async {
    // Show confirmation dialog before deleting
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

    if (confirmed != true) return; // User cancelled

    try {
      final response = await ApiService.delete('manager/class-schedules/$paperId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule deleted successfully!')),
        );
        // Refresh the list
        setState(() {
          _scheduleFuture = _fetchSchedule();
        });
      } else {
        throw Exception('Failed to delete schedule. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _navigateToAddSchedule() {
    // TODO: Create and navigate to an AddScheduleScreen
    // Example:
    // Navigator.push(context, MaterialPageRoute(builder: (context) => AddScheduleScreen(examId: widget.examId)))
    //   .then((value) {
    //     if (value == true) { // If a schedule was added, refresh the list
    //       setState(() {
    //         _scheduleFuture = _fetchSchedule();
    //       });
    //     }
    // });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation to Add Schedule page not implemented yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examName), // Use dynamic exam name
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddSchedule,
        icon: const Icon(Icons.add),
        label: const Text("Add Schedule"),
      ),
      body: FutureBuilder<List<ExamPaper>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _scheduleFuture = _fetchSchedule();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No schedule found for this exam.'));
          }

          final papers = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Added padding for FAB
            itemCount: papers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final paper = papers[index];
              final formattedDate = paper.date != null ? DateFormat('d MMM yyyy').format(DateTime.parse(paper.date!)) : "N/A";
              final formattedStartTime = paper.startTime != null ? DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(paper.startTime!)) : "N/A";
              final formattedEndTime = paper.endTime != null ? DateFormat('h:mm a').format(DateFormat('HH:mm:ss').parse(paper.endTime!)) : "N/A";

              return CustomExamResultContainerBox(
                heading: "Class: ${paper.className}",
                section: "Section: ${paper.sectionName}",
                subject: paper.subjectName,
                venue: paper.venue ?? 'N/A',
                date: formattedDate,
                time: '$formattedStartTime - $formattedEndTime',
                onDelete: () => _deleteSchedule(paper.id),
                onEnterMarks: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnterMarksPage(
                        paperId: paper.id,
                        examId: paper.examId,
                        classId: paper.classId,
                        sectionId: paper.sectionId,
                        subjectId: paper.subjectId,
                        subjectName: paper.subjectName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class CustomExamResultContainerBox extends StatelessWidget {
  final String heading;
  final String subject;
  final String section;
  final String venue;
  final String date;
  final String time;
  final VoidCallback onEnterMarks;
  final VoidCallback onDelete;

  const CustomExamResultContainerBox({
    super.key,
    required this.heading,
    required this.subject,
    required this.section,
    required this.venue,
    required this.date,
    required this.time,
    required this.onEnterMarks,
    required this.onDelete,
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
                const Icon(Icons.book, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(heading, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                ),
                Text(" - ", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                Text(section, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
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
                const SizedBox(width: 16),
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
                      Text(date, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blue)),
                    ],
                  ),
                ),
                 const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Time", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(150))),
                      Text(time, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blue)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: theme.colorScheme.onPrimary.withAlpha(180), thickness: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEnterMarks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withAlpha(55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    ),
                    icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                    label: Text("Enter Marks", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withAlpha(55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    ),
                    icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                    label: Text("Delete", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
