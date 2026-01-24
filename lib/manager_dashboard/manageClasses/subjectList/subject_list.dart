import 'dart:ui';
import 'package:eduphin/manager_dashboard/manageClasses/subjectList/create_new_subject.dart';
import 'package:eduphin/manager_dashboard/manageClasses/subjectList/edit_suject.dart';
import 'package:flutter/material.dart';

// Data model for a Subject
class Subject {
  final String name;
  final String description;
  final bool isActive;
  final String code;
  final String credit;
  final String type;

  Subject({
    required this.name,
    required this.description,
    required this.isActive,
    required this.code,
    required this.credit,
    required this.type,
  });
}

class SubjectListPage extends StatefulWidget {
  const SubjectListPage({super.key});

  @override
  State<SubjectListPage> createState() => _SubjectListPageState();
}

class _SubjectListPageState extends State<SubjectListPage> {
  bool _isLoading = true;
  final List<Subject> _subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    // Simulate API call to fetch subjects.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));

    final List<Subject> fetchedSubjects = [
      Subject(
        name: "Financial Accounting Basics",
        description: "An introductory course covering the fundamentals of financial accounting principles and practices.",
        isActive: true,
        code: "FAB-101",
        credit: "4",
        type: "Theory",
      ),
      Subject(
        name: "Advanced Corporate Finance",
        description: "In-depth study of financial theories and their application to corporate financial policy and strategy.",
        isActive: false,
        code: "ACF-310",
        credit: "4",
        type: "Theory",
      ),
    ];

    if (mounted) {
      setState(() {
        _subjects.addAll(fetchedSubjects);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const CreateNewSubjectPage()));
        },
        label: const Text("Create New Subject"),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text("Subject List"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth > 600;
                return isWide ? _buildGridView() : _buildListView();
              },
            ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Padding for FAB
      itemCount: _subjects.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return SubjectCard(subject: subject);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Padding for FAB
      itemCount: _subjects.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5, // Adjust aspect ratio as needed
      ),
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return SubjectCard(subject: subject);
      },
    );
  }
}

// Widget for displaying a single subject card
class SubjectCard extends StatelessWidget {
  final Subject subject;

  const SubjectCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = subject.isActive ? Colors.green.shade600 : Colors.red.shade500;
    final statusText = subject.isActive ? "Active" : "Inactive";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(subject.name,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: statusColor.withOpacity(0.1),
                ),
                child: Text(statusText,
                    style: theme.textTheme.labelMedium?.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subject.description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(theme, "Subject Code", subject.code),
              _buildInfoColumn(theme, "Credit", subject.credit, crossAxisAlignment: CrossAxisAlignment.center),
              _buildInfoColumn(theme, "Type", subject.type, crossAxisAlignment: CrossAxisAlignment.end),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: theme.dividerColor, thickness: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          // Passing data to the edit page
                            builder: (context) => UpdateSubjectPage(subject: subject)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => showDeleteDialog(context, subject.name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
                  ),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text("Delete"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(ThemeData theme, String label, String value, {CrossAxisAlignment? crossAxisAlignment}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

void showDeleteDialog(BuildContext context, String subjectName) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Delete",
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.6),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return DeleteSubjectDialog(
        subjectName: subjectName,
      );
    },
  );
}

class DeleteSubjectDialog extends StatelessWidget {
  final String subjectName;

  const DeleteSubjectDialog({
    super.key,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Delete Subject", style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to delete the subject: '$subjectName'? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Implement delete logic here
                      Navigator.pop(context);
                    },
                    child: const Text("Yes, Delete"),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: theme.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
