import 'dart:convert';
import 'dart:ui';
import 'package:eduphin/manager_dashboard/manageClasses/subjectList/create_new_subject.dart';
import 'package:eduphin/manager_dashboard/manageClasses/subjectList/edit_suject.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

// Data model for a Subject
class Subject {
  final int id;
  final String name;
  final String description;
  final bool isActive;
  final String code;
  final String credit;
  final String type;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.code,
    required this.credit,
    required this.type,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'No Name',
      description: json['description'] as String? ?? '',
      isActive: json['status'] == 'active',
      code: json['code'] as String? ?? 'N/A',
      credit: (json['credit'] ?? '0').toString(),
      type: json['type'] as String? ?? 'N/A',
    );
  }
}

class SubjectListPage extends StatefulWidget {
  const SubjectListPage({super.key});

  @override
  State<SubjectListPage> createState() => _SubjectListPageState();
}

class _SubjectListPageState extends State<SubjectListPage> {
  bool _isLoading = true;
  List<Subject> _subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.get('manager/subjects');
      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final subjectsData = (data['data'] as List)
              .map((subjectJson) => Subject.fromJson(subjectJson))
              .toList();
          setState(() {
            _subjects = subjectsData;
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load subjects');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _deleteSubject(int subjectId) async {
    try {
      final response = await ApiService.delete('manager/subjects/$subjectId');
      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subject deleted successfully')),
          );
          _fetchSubjects(); // Refresh the list
        } else {
          final responseData = jsonDecode(response.body);
          throw Exception(responseData['message'] ?? 'Failed to delete subject');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNewSubjectPage()),
          );
          if (result == true) {
            _fetchSubjects();
          }
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
          : RefreshIndicator(
              onRefresh: _fetchSubjects,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth > 600;
                  return isWide ? _buildGridView() : _buildListView();
                },
              ),
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
        return SubjectCard(subject: subject, onDelete: () => _deleteSubject(subject.id), onEdit: () => _navigateToEdit(subject));
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
        return SubjectCard(subject: subject, onDelete: () => _deleteSubject(subject.id), onEdit: () => _navigateToEdit(subject));
      },
    );
  }
  
  void _navigateToEdit(Subject subject) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpdateSubjectPage(subject: subject),
        ),
      );
      if (result == true) {
        _fetchSubjects();
      }
  }
}

// Widget for displaying a single subject card
class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const SubjectCard({super.key, required this.subject, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = subject.isActive ? theme.colorScheme.primary : theme.colorScheme.error;
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
                  color: statusColor.withAlpha(26),
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
                  onPressed: onEdit,
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
                  onPressed: () => showDeleteDialog(context, subject.name, onDelete),
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

void showDeleteDialog(BuildContext context, String subjectName, VoidCallback onConfirm) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Delete",
    barrierColor: Theme.of(context).colorScheme.scrim,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) {
      return DeleteSubjectDialog(
        subjectName: subjectName,
        onConfirm: onConfirm,
      );
    },
  );
}

class DeleteSubjectDialog extends StatelessWidget {
  final String subjectName;
  final VoidCallback onConfirm;

  const DeleteSubjectDialog({
    super.key,
    required this.subjectName,
    required this.onConfirm,
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
                      Navigator.pop(context);
                      onConfirm();
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
