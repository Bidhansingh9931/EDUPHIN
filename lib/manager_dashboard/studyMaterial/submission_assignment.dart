import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Data model for an assignment submission
class AssignmentSubmission {
  final String name;
  final String fileName;
  final bool hasFile;
  final String typedAnswer;
  final String submittedOn;
  final String grade;
  final String remarks;
  final bool graded;
  final bool fail;

  AssignmentSubmission({
    required this.name,
    required this.fileName,
    required this.hasFile,
    required this.typedAnswer,
    required this.submittedOn,
    required this.grade,
    required this.remarks,
    required this.graded,
    this.fail = false,
  });

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    final bool isGraded = json['marks_obtained'] != null;
    final gradeValue = isGraded ? "${json['marks_obtained'] ?? 0} / ${json['assignment']?['total_marks'] ?? 100}" : 'Not Graded';
    final didFail = isGraded && (json['marks_obtained'] ?? 0) < 40; // Example fail condition

    return AssignmentSubmission(
      name: json['student']?['name'] ?? 'N/A',
      fileName: json['file_path'] != null ? json['file_path'].split('/').last : 'No File',
      hasFile: json['file_path'] != null,
      typedAnswer: json['content'] ?? 'No typed answer provided.',
      submittedOn: json['created_at'] != null ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(json['created_at'])) : 'N/A',
      grade: gradeValue,
      remarks: json['remarks'] ?? (isGraded ? '-' : 'Awaiting review.'),
      graded: isGraded,
      fail: didFail,
    );
  }
}

class AssignmentSubmissionsScreen extends StatefulWidget {
  final int assignmentId;
  const AssignmentSubmissionsScreen({super.key, required this.assignmentId});

  @override
  State<AssignmentSubmissionsScreen> createState() =>
      _AssignmentSubmissionsScreenState();
}

class _AssignmentSubmissionsScreenState
    extends State<AssignmentSubmissionsScreen> {
  bool isLoading = true;
  List<AssignmentSubmission> submissions = [];
  String assignmentTitle = '';

  @override
  void initState() {
    super.initState();
    _fetchSubmissions();
  }

  Future<void> _fetchSubmissions() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.get('manager/study/assignment/${widget.assignmentId}/submissions');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body)['data'];

        final assignment = responseData['assignment'];
        final submissionsData = responseData['submissions'] as List;

        final fetchedSubmissions = submissionsData
            .map((data) => AssignmentSubmission.fromJson(data))
            .toList();

        if (mounted) {
          setState(() {
            submissions = fetchedSubmissions;
            assignmentTitle = assignment['title'] ?? 'Submissions';
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load submissions');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(assignmentTitle),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return _buildGridView();
              } else {
                return _buildListView();
              }
            }),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        return _SubmissionCard(submission: submissions[index]);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      itemCount: submissions.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 600, // Max width of each item
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2, // Adjust aspect ratio for content
      ),
      itemBuilder: (context, index) {
        return _SubmissionCard(submission: submissions[index]);
      },
    );
  }
}

// A refactored card widget for displaying a single submission
class _SubmissionCard extends StatelessWidget {
  final AssignmentSubmission submission;

  const _SubmissionCard({required this.submission});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Name
            Text(
              submission.name,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 14),

            // FILE TILE
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  Icon(
                    submission.hasFile ? Icons.insert_drive_file : Icons.close,
                    color: submission.hasFile
                        ? theme.colorScheme.primary
                        : theme.hintColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      submission.fileName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: submission.hasFile
                            ? theme.colorScheme.onSurface
                            : theme.hintColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.download_outlined,
                    color: submission.hasFile
                        ? theme.colorScheme.onSurface
                        : Colors.transparent,
                  )
                ],
              ),
            ),

            const SizedBox(height: 14),

            Text("Typed Answer",
                style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),

            const SizedBox(height: 6),

            Text(
              submission.typedAnswer,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (submission.typedAnswer.length > 50)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        final dialogTheme = Theme.of(dialogContext);
                        return AlertDialog(
                          backgroundColor: dialogTheme.cardColor,
                          title: Text("Full Typed Answer", style: dialogTheme.textTheme.titleLarge),
                          content: SingleChildScrollView(
                            child: Text(submission.typedAnswer, style: dialogTheme.textTheme.bodyMedium),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              child: Text("Close", style: TextStyle(color: dialogTheme.colorScheme.primary)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    "Read more",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 14),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildInfoField(
                    theme,
                    label: "Submitted On",
                    value: submission.submittedOn,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoField(
                    theme,
                    label: "Grade",
                    value: submission.grade,
                    isGraded: submission.graded,
                    didFail: submission.fail,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            _buildInfoField(theme, label: "Remarks", value: submission.remarks),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(ThemeData theme, 
      {required String label, required String value, bool isGraded = false, bool didFail = false}) {
        
    Color valueColor;
    if (isGraded) {
      valueColor = didFail ? theme.colorScheme.error : theme.colorScheme.primary;
    } else {
      valueColor = theme.hintColor;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: isGraded ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
