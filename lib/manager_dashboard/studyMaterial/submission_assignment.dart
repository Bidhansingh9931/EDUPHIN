import 'dart:convert';
import 'dart:io';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;

// Data model for an assignment submission
class AssignmentSubmission {
  final int id;
  final String name;
  final String fileName;
  final bool hasFile;
  final String typedAnswer;
  final String submittedOn;
  final String grade;
  final String remarks;
  final bool graded;
  final bool fail;
  final int totalMarks;
  final String? filePath;

  AssignmentSubmission({
    required this.id,
    required this.name,
    required this.fileName,
    required this.hasFile,
    required this.typedAnswer,
    required this.submittedOn,
    required this.grade,
    required this.remarks,
    required this.graded,
    required this.totalMarks,
    this.filePath,
    this.fail = false,
  });

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    final bool isGraded = json['marks_obtained'] != null;
    final total = json['assignment']?['total_marks'] ?? 100;
    final gradeValue = isGraded ? "${json['marks_obtained'] ?? 0} / $total" : 'Not Graded';
    final didFail = isGraded && (json['marks_obtained'] ?? 0) < (total * 0.4); 

    return AssignmentSubmission(
      id: json['id'] ?? 0,
      name: json['student']?['name'] ?? 'N/A',
      fileName: json['file_path'] != null ? json['file_path'].split('/').last : 'No File',
      hasFile: json['file_path'] != null,
      filePath: json['file_path'],
      typedAnswer: json['content'] ?? 'No typed answer provided.',
      submittedOn: json['created_at'] != null ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(json['created_at'])) : 'N/A',
      grade: gradeValue,
      remarks: json['remarks'] ?? (isGraded ? '-' : 'Awaiting review.'),
      graded: isGraded,
      fail: didFail,
      totalMarks: total,
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
  bool _isLoading = true;
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
      _isLoading = true;
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
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load submissions');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(assignmentTitle, style: TextStyle(fontSize: context.font(20))),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSubmissions,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: context.responsive(
                    _buildListView(),
                    tablet: _buildGridView(crossAxisCount: 2),
                    desktop: _buildGridView(crossAxisCount: 3),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: context.md),
          child: _SubmissionCard(
            submission: submissions[index],
            onGraded: _fetchSubmissions,
            onViewFile: (path) => _viewFile(context, path),
          ),
        );
      },
    );
  }

  Widget _buildGridView({required int crossAxisCount}) {
    return GridView.builder(
      padding: context.pagePadding,
      itemCount: submissions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: context.md,
        crossAxisSpacing: context.md,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        return _SubmissionCard(
          submission: submissions[index],
          onGraded: _fetchSubmissions,
          onViewFile: (path) => _viewFile(context, path),
        );
      },
    );
  }

  Future<void> _viewFile(BuildContext context, String? attachment) async {
    if (attachment == null || attachment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No attachment available")),
      );
      return;
    }

    final url = ApiService.getStorageUrl(attachment);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Downloading file...")),
    );

    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final fileName = attachment.split('/').last;
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);

        await OpenFile.open(file.path);
      } else {
        throw Exception("Failed to download file (Status: ${response.statusCode})");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not open file: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

// A refactored card widget for displaying a single submission
class _SubmissionCard extends StatelessWidget {
  final AssignmentSubmission submission;
  final VoidCallback onGraded;
  final Function(String?) onViewFile;

  const _SubmissionCard({required this.submission, required this.onGraded, required this.onViewFile});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.sm),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      color: theme.colorScheme.surfaceContainerLowest,
      child: InkWell(
        onTap: () => _showGradingDialog(context),
        borderRadius: BorderRadius.circular(context.sm),
        child: Padding(
          padding: EdgeInsets.all(context.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      submission.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              SizedBox(height: context.sm),
              _buildFileTile(context),
              SizedBox(height: context.md),
              Text(
                "Typed Answer",
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.secondary),
              ),
              const SizedBox(height: 4),
              Text(
                submission.typedAnswer,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (submission.typedAnswer.length > 50)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "Click to view & grade",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      label: "Submitted On",
                      value: submission.submittedOn,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      label: "Grade",
                      value: submission.grade,
                      highlight: submission.graded,
                      error: submission.fail,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGradingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _GradingDialog(
        submission: submission,
        onGraded: onGraded,
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = context.theme;
    final bool isGraded = submission.graded;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.sm, vertical: 4),
      decoration: BoxDecoration(
        color: isGraded ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isGraded ? "Graded" : "Pending",
        style: theme.textTheme.labelSmall?.copyWith(
          color: isGraded ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFileTile(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.xs),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: submission.hasFile ? () => onViewFile(submission.filePath) : null,
        child: Row(
          children: [
            Icon(
              submission.hasFile ? Icons.insert_drive_file : Icons.block,
              size: 18,
              color: submission.hasFile ? theme.colorScheme.primary : theme.colorScheme.error,
            ),
            SizedBox(width: context.sm),
            Expanded(
              child: Text(
                submission.fileName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: submission.hasFile ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (submission.hasFile)
              Icon(Icons.download_outlined, size: 18, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, {required String label, required String value, bool highlight = false, bool error = false}) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: error ? theme.colorScheme.error : (highlight ? theme.colorScheme.primary : null),
          ),
        ),
      ],
    );
  }

  void _showFullAnswer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Typed Answer"),
        content: SingleChildScrollView(child: Text(submission.typedAnswer)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }
}

class _GradingDialog extends StatefulWidget {
  final AssignmentSubmission submission;
  final VoidCallback onGraded;

  const _GradingDialog({required this.submission, required this.onGraded});

  @override
  State<_GradingDialog> createState() => _GradingDialogState();
}

class _GradingDialogState extends State<_GradingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _marksController = TextEditingController();
  final _remarksController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _marksController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _submitGrade() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final response = await ApiService.post(
        'manager/study/assignment/submissions/${widget.submission.id}/grade',
        {
          'marks_obtained': _marksController.text,
          'remarks': _remarksController.text,
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Graded successfully')),
          );
          Navigator.pop(context);
          widget.onGraded();
        }
      } else {
        throw Exception('Failed to submit grade');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return AlertDialog(
      title: Text("Grade Submission: ${widget.submission.name}"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Typed Answer:", style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.submission.typedAnswer),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _marksController,
                decoration: InputDecoration(
                  labelText: "Marks Obtained (Max: ${widget.submission.totalMarks})",
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Required";
                  final marks = int.tryParse(value);
                  if (marks == null) return "Invalid number";
                  if (marks < 0 || marks > widget.submission.totalMarks) {
                    return "Must be between 0 and ${widget.submission.totalMarks}";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: "Remarks",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isSaving ? null : _submitGrade,
          child: _isSaving ? const CircularProgressIndicator() : const Text("Submit Grade"),
        ),
      ],
    );
  }
}
