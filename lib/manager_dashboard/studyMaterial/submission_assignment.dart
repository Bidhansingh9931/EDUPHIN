import 'package:flutter/material.dart';

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
    final bool isGraded = json['graded'] as bool;
    final String gradeValue = json['grade'] as String;
    // The original logic to determine if a student failed.
    final bool didFail = isGraded && gradeValue.startsWith('4');

    return AssignmentSubmission(
      name: json['name'] as String,
      fileName: json['fileName'] as String,
      hasFile: json['hasFile'] as bool,
      typedAnswer: json['typedAnswer'] as String,
      submittedOn: json['submittedOn'] as String,
      grade: gradeValue,
      remarks: json['remarks'] as String,
      graded: isGraded,
      fail: didFail,
    );
  }
}

class AssignmentSubmissionsScreen extends StatefulWidget {
  // If you need to pass assignment details, add them here.
  // For example: final String assignmentId;
  const AssignmentSubmissionsScreen({super.key});

  @override
  State<AssignmentSubmissionsScreen> createState() =>
      _AssignmentSubmissionsScreenState();
}

class _AssignmentSubmissionsScreenState
    extends State<AssignmentSubmissionsScreen> {
  bool isLoading = true;
  List<AssignmentSubmission> submissions = [];

  @override
  void initState() {
    super.initState();
    _fetchSubmissions();
  }

  // TODO: Replace this with your actual API call.
  Future<void> _fetchSubmissions() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final dummyData = [
      {
        "name": "Rahul Sharma",
        "fileName": "Uploaded PDF",
        "hasFile": true,
        "typedAnswer":
        "The answer is provided in the attached document. Please refer to it for the detailed solution...",
        "submittedOn": "18 Nov 2025, 10:30 AM",
        "grade": "85 / 100",
        "remarks": "Good effort. Some calculations need review.",
        "graded": true
      },
      {
        "name": "Priya Patel",
        "fileName": "No File",
        "hasFile": false,
        "typedAnswer":
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        "submittedOn": "19 Nov 2025, 09:15 PM",
        "grade": "Not Graded",
        "remarks": "Awaiting review.",
        "graded": false
      },
      {
        "name": "Anjali Verma",
        "fileName": "Solution.pdf",
        "hasFile": true,
        "typedAnswer": "No typed answer provided.",
        "submittedOn": "20 Nov 2025, 11:50 AM",
        "grade": "45 / 100",
        "remarks":
        "Incomplete submission. Please follow the instructions carefully next time.",
        "graded": true
      },
    ];

    if (mounted) {
      setState(() {
        submissions =
            dummyData.map((data) => AssignmentSubmission.fromJson(data)).toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
        title: Text(
          "Submissions for Assignment 1", // This can be dynamic too if passed to the widget
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
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
                  // TODO: Implement a dialog or navigation to show full text
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
    );
  }

  Widget _buildInfoField(ThemeData theme, 
      {required String label, required String value, bool isGraded = false, bool didFail = false}) {
        
    Color valueColor;
    if (isGraded) {
      valueColor = didFail ? theme.colorScheme.error : Colors.green.shade400;
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
            ),
          ),
        ],
      ),
    );
  }
}
