import 'package:eduphin/services/responsive_helper.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  List<dynamic> _assignments = [];
  bool _isLoading = true;
  final Map<String, bool> _subjectOpenStates = {};

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getStudentAssignments();
      setState(() {
        if (data is List) {
          _assignments = data;
        } else if (data is Map && data.containsKey('assignments')) {
          _assignments = data['assignments'] as List? ?? [];
        } else if (data is Map && data.containsKey('data')) {
           var nestedData = data['data'];
           if (nestedData is List) {
             _assignments = nestedData;
           } else if (nestedData is Map && nestedData.containsKey('assignments')) {
             _assignments = nestedData['assignments'] as List? ?? [];
           } else {
             _assignments = nestedData as List? ?? [];
           }
        } else {
          _assignments = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching assignments: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _submitAssignment(dynamic assignment) async {
    final theme = context.theme;
    final TextEditingController textController = TextEditingController();
    File? selectedFile;
    String? fileName;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.md),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          title: Text(
            "Submit: ${assignment['title']}",
            style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Submission Note", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14))),
                  SizedBox(height: context.xs),
                  TextField(
                    controller: textController,
                    maxLines: 3,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: "Enter submission text (optional)...",
                      hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: context.font(14)),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.sm), borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: context.md),
                  Text("Attachment", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14))),
                  SizedBox(height: context.xs),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
                        );
                        if (result != null) {
                          setDialogState(() {
                            selectedFile = File(result.files.single.path!);
                            fileName = result.files.single.name;
                          });
                        }
                      },
                      icon: Icon(Icons.attach_file, size: context.scale(18), color: theme.colorScheme.primary),
                      label: Text(fileName ?? "Pick File (PDF/Doc)", style: TextStyle(color: theme.colorScheme.primary)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                        padding: EdgeInsets.symmetric(vertical: context.md),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("CANCEL", style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text("SUBMIT"),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploading submission...")));
      
      try {
        final String? assignmentId = assignment['id']?.toString();
        if (assignmentId == null) throw Exception("Assignment ID missing");

        await ApiService.submitStudentAssignment(
          assignmentId,
          file: selectedFile,
          text: textController.text.isNotEmpty ? textController.text : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Assignment submitted successfully!")));
          _fetchAssignments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Submission failed: $e"),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    Map<String, List<dynamic>> groupedAssignments = {};
    for (var assignment in _assignments) {
      final subjectName = assignment['subject']?['name'] ?? 'General';
      if (!groupedAssignments.containsKey(subjectName)) {
        groupedAssignments[subjectName] = [];
      }
      groupedAssignments[subjectName]!.add(assignment);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Assignments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(20))),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : groupedAssignments.isEmpty
              ? Center(child: Text("No assignments available", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16))))
              : RefreshIndicator(
                  onRefresh: _fetchAssignments,
                  color: colorScheme.primary,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: ListView.separated(
                        padding: context.pagePadding,
                        itemCount: groupedAssignments.length,
                        separatorBuilder: (context, index) => SizedBox(height: context.md),
                        itemBuilder: (context, index) {
                          final subjectName = groupedAssignments.keys.elementAt(index);
                          final subjectAssignments = groupedAssignments[subjectName]!;
                          final bool isOpen = _subjectOpenStates[subjectName] ?? false;

                          return Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(context.md),
                              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    subjectName,
                                    style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                                  ),
                                  trailing: AnimatedRotation(
                                    duration: const Duration(milliseconds: 200),
                                    turns: isOpen ? 0.5 : 0,
                                    child: Icon(Icons.expand_more, color: theme.colorScheme.onSurfaceVariant, size: context.scale(24)),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _subjectOpenStates[subjectName] = !isOpen;
                                    });
                                  },
                                ),
                                if (isOpen)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: context.sm),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                                        if (crossAxisCount > 1) {
                                          return GridView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.symmetric(horizontal: context.sm),
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossAxisCount,
                                              crossAxisSpacing: context.sm,
                                              mainAxisSpacing: context.sm,
                                              childAspectRatio: 2.2,
                                            ),
                                            itemCount: subjectAssignments.length,
                                            itemBuilder: (context, idx) => _assignmentCard(subjectAssignments[idx]),
                                          );
                                        }
                                        return Column(
                                          children: subjectAssignments.map((a) => _assignmentCard(a)).toList(),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _assignmentCard(dynamic assignment) {
    final theme = context.theme;
    final dueDateStr = assignment['due_date'];
    String formattedDate = "N/A";
    if (dueDateStr != null) {
      try {
        DateTime dt = DateTime.parse(dueDateStr);
        formattedDate = DateFormat('dd MMM, yyyy').format(dt);
      } catch (_) {}
    }

    final bool isSubmitted = assignment['submission'] != null;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.md, vertical: context.xs),
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(context.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment['title'] ?? 'N/A',
                      style: TextStyle(fontSize: context.font(16), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.xs),
                    Row(
                      children: [
                        Icon(Icons.calendar_month, color: theme.colorScheme.onSurfaceVariant, size: context.scale(14)),
                        SizedBox(width: context.xs),
                        Text(
                          "Due: $formattedDate",
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.xs),
                decoration: BoxDecoration(
                  color: (isSubmitted ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.xs),
                  border: Border.all(color: (isSubmitted ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withValues(alpha: 0.5)),
                ),
                child: Text(
                  isSubmitted ? "SUBMITTED" : "PENDING",
                  style: TextStyle(color: isSubmitted ? const Color(0xFF10B981) : const Color(0xFFF59E0B), fontSize: context.font(10), fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          if (assignment['description'] != null && assignment['description'].toString().isNotEmpty) ...[
            SizedBox(height: context.md),
            Text(
              assignment['description'] ?? '',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(13)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const Spacer(),
          SizedBox(height: context.md),
          SizedBox(
            width: double.infinity,
            height: context.scale(40),
            child: ElevatedButton(
              onPressed: isSubmitted ? null : () => _submitAssignment(assignment),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSubmitted ? theme.colorScheme.outlineVariant.withValues(alpha: 0.2) : theme.colorScheme.primary,
                foregroundColor: isSubmitted ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onPrimary,
                minimumSize: Size(double.infinity, context.scale(40)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.sm)),
                elevation: 0,
              ),
              child: Text(isSubmitted ? "VIEW SUBMISSION" : "SUBMIT ASSIGNMENT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13))),
            ),
          )
        ],
      ),
    );
  }
}
