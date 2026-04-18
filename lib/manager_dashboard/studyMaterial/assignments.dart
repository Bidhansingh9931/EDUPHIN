import 'dart:convert';
import 'package:eduphin/manager_dashboard/studyMaterial/add_assignment.dart';
import 'package:eduphin/manager_dashboard/studyMaterial/edit_assignment.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:intl/intl.dart';
import 'package:eduphin/manager_dashboard/studyMaterial/submission_assignment.dart';
import 'package:flutter/material.dart';

// --- Data Models ---

class Assignment {
  final int id;
  final String title;
  final String description;
  final String subject;
  final String className;
  final String section;
  final String uploadedBy;
  final String uploadedDate;
  final String dueDate;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.className,
    required this.section,
    required this.uploadedBy,
    required this.uploadedDate,
    required this.dueDate,
  });

  factory Assignment.fromJson(Map<String, dynamic> json, Map<int, String> classMap, Map<int, String> sectionMap, Map<int, String> subjectMap, Map<int, String> teacherMap) {
    return Assignment(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String? ?? '',
      subject: subjectMap[json['subject_id']] ?? 'N/A',
      className: classMap[json['class_id']] ?? 'N/A',
      section: sectionMap[json['section_id']] ?? 'N/A',
      uploadedBy: teacherMap[json['teacher_id']] ?? 'N/A',
      uploadedDate: json['created_at'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(json['created_at'])) : 'N/A',
      dueDate: json['due_date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(json['due_date'])) : 'N/A',
    );
  }
}

class ApiClass {
  final int id;
  final String name;
  ApiClass({required this.id, required this.name});

  factory ApiClass.fromJson(Map<String, dynamic> json) {
    return ApiClass(id: json['id'], name: json['name']);
  }
}

class ApiSection {
  final int id;
  final String name;
  ApiSection({required this.id, required this.name});

  factory ApiSection.fromJson(Map<String, dynamic> json) {
    return ApiSection(id: json['id'], name: json['section_name']);
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
  List<ApiClass> classes = [];
  List<ApiSection> sections = [];
  List<Assignment> allAssignments = [];
  Map<String, List<Assignment>> filteredAssignments = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.get('manager/study/assignments');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body)['data'];

        final List<ApiClass> fetchedClasses = (responseData['classes'] as List)
            .map((data) => ApiClass.fromJson(data))
            .toList();
        final List<ApiSection> fetchedSections = (responseData['sections'] as List)
            .map((data) => ApiSection.fromJson(data))
            .toList();

        final classMap = {for (var e in fetchedClasses) e.id: e.name};
        final sectionMap = {for (var e in fetchedSections) e.id: e.name};

        final schedules = responseData['schedules'] as List;
        final Map<int, String> subjectMap = {for (var s in schedules) s['subject_id']: s['subject']?['name'] ?? 'N/A'};
        final Map<int, String> teacherMap = {for (var s in schedules) s['teacher_id']: s['teacher']?['name'] ?? 'N/A'};

        final List<Assignment> fetchedAssignments = (responseData['assignments'] as List)
            .map((data) => Assignment.fromJson(data, classMap, sectionMap, subjectMap, teacherMap))
            .toList();

        if (mounted) {
          setState(() {
            classes = fetchedClasses;
            sections = fetchedSections;
            allAssignments = fetchedAssignments;
            if (classes.isNotEmpty) {
               selectedClass = classes.first.name;
            }
            if (sections.isNotEmpty) {
              selectedSection = sections.first.name;
            }
            _filterAssignments();
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
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

  Future<void> _deleteAssignment(int assignmentId) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text('Are you sure you want to delete this assignment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await ApiService.delete('manager/study/assignments/$assignmentId');
        if (response.statusCode == 200) {
           if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Assignment deleted successfully'),
              backgroundColor: theme.colorScheme.primary,
            ));
            _fetchData(); // Refresh list
          }
        } else {
          throw Exception('Failed to delete assignment');
        }
      } catch (e) {
        if(mounted){
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
             content: Text(e.toString()),
             backgroundColor: theme.colorScheme.error,
           ));
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Assignments"),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: context.pagePadding.copyWith(top: 0),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddAssignmentPage()),
              );
              if (result == true) {
                _fetchData(); // Refresh list
              }
            },
            label: Text('Create New', style: TextStyle(color: theme.colorScheme.onPrimary)),
            icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
            backgroundColor: theme.colorScheme.primary,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: context.pagePadding.copyWith(bottom: 0),
              child: Column(
                children: [
                  _buildFilterSection(theme),
                  SizedBox(height: context.md),
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
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(child: _buildDropdown(theme, "Select Class *", selectedClass, classes.map((c) => c.name).toList(), (v) {
            if (v != null) {
              setState(() => selectedClass = v);
              _filterAssignments();
            }
          })),
          SizedBox(width: context.md),
          Expanded(child: _buildDropdown(theme, "Select Section *", selectedSection, sections.map((s) => s.name).toList(), (v) {
            if (v != null) {
              setState(() => selectedSection = v);
              _filterAssignments();
            }
          })),
        ],
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme, String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    final uniqueItems = items.toSet().toList();
    final isValueValid = value == null || uniqueItems.contains(value);
    final String? dropdownValue = isValueValid ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(153))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: dropdownValue,
          dropdownColor: theme.colorScheme.surfaceContainerLow,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(12)),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(12)),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          items: uniqueItems.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAssignmentsList() {
    final subjects = filteredAssignments.keys.toList();
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80), // Adjusted for FAB
      itemCount: subjects.length,
      separatorBuilder: (context, index) => SizedBox(height: context.md),
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final assignments = filteredAssignments[subject]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                subject, // Subject Name
                style: context.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            context.responsive(
              Column(children: assignments.map((a) => _AssignmentCard(assignment: a, onDelete: () => _deleteAssignment(a.id), onEdit: () async {
                 final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditAssignmentPage(assignment: a)));
                 if(result == true) {
                    _fetchData();
                 }
              })).toList()),
              tablet: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 500,
                  mainAxisSpacing: context.sm,
                  crossAxisSpacing: context.sm,
                  childAspectRatio: 1.6,
                ),
                itemCount: assignments.length,
                itemBuilder: (context, index) => _AssignmentCard(assignment: assignments[index], onDelete: () => _deleteAssignment(assignments[index].id), onEdit: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditAssignmentPage(assignment: assignments[index])));
                  if(result == true) {
                      _fetchData();
                  }
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AssignmentCard({required this.assignment, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(18)),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  assignment.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
                ),
              ),
               Row(
                children: [
                  IconButton(icon: Icon(Icons.edit, size: 20, color: theme.colorScheme.secondary), onPressed: onEdit, constraints: const BoxConstraints()),
                  IconButton(icon: Icon(Icons.delete, size: 20, color: theme.colorScheme.error), onPressed: onDelete, constraints: const BoxConstraints()),
                ],
              ),
            ],
          ),
          SizedBox(height: context.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoColumn(
                    context, "Uploaded by", assignment.uploadedBy),
              ),
              Expanded(
                child: _buildInfoColumn(
                    context, "Uploaded Date", assignment.uploadedDate),
              ),
            ],
          ),
          _buildInfoColumn(context, "Due Date", assignment.dueDate),
          SizedBox(height: context.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AssignmentSubmissionsScreen(assignmentId: assignment.id)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.scale(10)),
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

  Widget _buildInfoColumn(BuildContext context, String label, String value) {
    final theme = context.theme;
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
