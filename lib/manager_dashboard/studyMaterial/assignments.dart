import 'package:eduphin/manager_dashboard/studyMaterial/submission_assignment.dart';
import 'package:flutter/material.dart';

// --- Data Models ---

class Assignment {
  final String title;
  final String subject;
  final String className;
  final String section;
  final String uploadedBy;
  final String uploadedDate;
  final String dueDate;

  Assignment({
    required this.title,
    required this.subject,
    required this.className,
    required this.section,
    required this.uploadedBy,
    required this.uploadedDate,
    required this.dueDate,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      title: json['title'] as String,
      subject: json['subject'] as String,
      className: json['className'] as String,
      section: json['section'] as String,
      uploadedBy: json['uploadedBy'] as String,
      uploadedDate: json['uploadedDate'] as String,
      dueDate: json['dueDate'] as String,
    );
  }
}


class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  String? selectedClass;
  String? selectedSection;

  bool isLoading = true;
  List<String> classes = [];
  List<String> sections = [];
  List<Assignment> allAssignments = [];
  Map<String, List<Assignment>> filteredAssignments = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // TODO: Replace this with your actual API call in the future
  Future<void> _fetchData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final List<String> fetchedClasses = [
      "Class 6", "Class 7", "Class 8", "Class 9", "Class 10", "Class 11", "Class 12"
    ];
    final List<String> fetchedSections = ["Section A", "Section B", "Section C"];
    final List<Map<String, dynamic>> fetchedAssignmentsData = [
      {
        "title": "Algebraic Equations",
        "subject": "Mathematics",
        "className": "Class 10",
        "section": "Section A",
        "uploadedBy": "Mr. Sharma",
        "uploadedDate": "12 Nov 2025",
        "dueDate": "20 Nov 2025"
      },
      {
        "title": "Polynomials",
        "subject": "Mathematics",
        "className": "Class 10",
        "section": "Section A",
        "uploadedBy": "Mr. Sharma",
        "uploadedDate": "12 Nov 2025",
        "dueDate": "22 Nov 2025"
      },
      {
        "title": "Light - Reflection and Refraction",
        "subject": "Science",
        "className": "Class 10",
        "section": "Section A",
        "uploadedBy": "Mrs. Gupta",
        "uploadedDate": "10 Nov 2025",
        "dueDate": "18 Nov 2025"
      },
      {
        "title": "Federalism",
        "subject": "Social Studies",
        "className": "Class 10",
        "section": "Section B",
        "uploadedBy": "Ms. Singh",
        "uploadedDate": "05 Nov 2025",
        "dueDate": "15 Nov 2025"
      },
      {
        "title": "Sectors of the Indian Economy",
        "subject": "Social Studies",
        "className": "Class 10",
        "section": "Section B",
        "uploadedBy": "Ms. Singh",
        "uploadedDate": "05 Nov 2025",
        "dueDate": "17 Nov 2025"
      },
      {
        "title": "Number Systems",
        "subject": "Mathematics",
        "className": "Class 9",
        "section": "Section A",
        "uploadedBy": "Mr. Sharma",
        "uploadedDate": "01 Nov 2025",
        "dueDate": "10 Nov 2025"
      }
    ];

    if (mounted) {
      setState(() {
        classes = fetchedClasses;
        sections = fetchedSections;
        allAssignments = fetchedAssignmentsData.map((data) => Assignment.fromJson(data)).toList();
        selectedClass = "Class 10";
        selectedSection = "Section A";
        _filterAssignments();
        isLoading = false;
      });
    }
  }

  void _filterAssignments() {
    final filtered = allAssignments.where((assignment) {
      final matchClass = selectedClass == null || assignment.className == selectedClass;
      final matchSection = selectedSection == null || assignment.section == selectedSection;
      return matchClass && matchSection;
    }).toList();

    final Map<String, List<Assignment>> grouped = {};
    for (var assignment in filtered) {
      if (!grouped.containsKey(assignment.subject)) {
        grouped[assignment.subject] = [];
      }
      grouped[assignment.subject]!.add(assignment);
    }

    setState(() {
      filteredAssignments = grouped;
    });
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
        title: Text("Assignments", style: TextStyle(color: theme.colorScheme.onSurface)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                 _buildFilterSection(theme),
                 const SizedBox(height: 16),
                 Expanded(
                   child: filteredAssignments.isNotEmpty 
                    ? _buildAssignmentsList()
                    : const Center(
                       child: Text("No assignments found for the selected filters."),
                    ),
                 )
              ],
            ),
          ),
    );
  }
  
  Widget _buildFilterSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(theme, "Select Class *", selectedClass, classes, (v) {
              if (v != null) {
                setState(() => selectedClass = v);
                _filterAssignments();
              }
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdown(theme, "Select Section *", selectedSection, sections, (v) {
              if (v != null) {
                setState(() => selectedSection = v);
                _filterAssignments();
              }
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDropdown(ThemeData theme, String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(35))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          dropdownColor: theme.cardColor,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAssignmentsList() {
    final subjects = filteredAssignments.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 50),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final assignments = filteredAssignments[subject]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 10),
              child: Text(
                subject, // Subject Name
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            ...assignments.map((a) => _AssignmentCard(assignment: a)),
          ],
        );
      },
    );
  }
}


class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            assignment.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoColumn(theme, "Uploaded by", assignment.uploadedBy),
              ),
              Expanded(
                child: _buildInfoColumn(theme, "Uploaded Date", assignment.uploadedDate),
              ),
            ],
          ),
          _buildInfoColumn(theme, "Due Date", assignment.dueDate),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AssignmentSubmissionsScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text("View Submission"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoColumn(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
