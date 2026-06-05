import 'package:eduphin/services/responsive_helper.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  List<dynamic> _assignments = [];
  bool _isLoading = true;
  final Map<String, bool> _subjectOpenStates = {};
  static const String _cacheKey = 'student_assignments';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchAssignments();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CacheService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      setState(() {
        _assignments = List<dynamic>.from(cachedData as List);
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAssignments() async {
    if (_assignments.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await ApiService.getStudentAssignments();
      List<dynamic> fetchedAssignments = [];
      if (data is List) {
        fetchedAssignments = data;
      } else if (data is Map && data.containsKey('assignments')) {
        fetchedAssignments = data['assignments'] as List? ?? [];
      } else if (data is Map && data.containsKey('data')) {
        var nestedData = data['data'];
        if (nestedData is List) {
          fetchedAssignments = nestedData;
        } else if (nestedData is Map && nestedData.containsKey('assignments')) {
          fetchedAssignments = nestedData['assignments'] as List? ?? [];
        } else {
          fetchedAssignments = nestedData as List? ?? [];
        }
      }

      if (mounted) {
        setState(() {
          _assignments = fetchedAssignments;
          _isLoading = false;
        });
        await CacheService.saveData(_cacheKey, fetchedAssignments);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _submitAssignment(dynamic assignment) async {
    final theme = context.theme;
    final TextEditingController textController = TextEditingController();
    File? selectedFile;
    Uint8List? selectedFileBytes;
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
                          withData: kIsWeb,
                        );
                        if (result != null) {
                          setDialogState(() {
                            if (!kIsWeb && result.files.single.path != null) {
                              selectedFile = File(result.files.single.path!);
                            }
                            selectedFileBytes = result.files.single.bytes;
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
        final String? assignmentId = (assignment['encrypted_id'] ?? assignment['id'])?.toString();
        if (assignmentId == null) throw Exception("Assignment ID missing");

        await ApiService.submitStudentAssignment(
          assignmentId,
          file: selectedFile,
          fileBytes: selectedFileBytes,
          fileName: fileName,
          text: textController.text.isNotEmpty ? textController.text : null,
          subjectId: assignment['subject_id']?.toString(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Assignment submitted successfully!")));
          _fetchAssignments();
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.showError(context, e);
        }
      }
    }
  }

  void _viewFile(String? path) async {
    if (path == null || path.isEmpty) return;
    final url = path.startsWith('http') ? path : '${ApiService.baseUrl}/storage/$path';
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open file")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error opening file: $e")));
    }
  }

  void _viewSubmission(dynamic assignment) {
    final theme = context.theme;
    final submission = assignment['submission'];
    if (submission == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainerLow,
        title: Text("Submission: ${assignment['title']}", style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (submission['submitted_text'] != null && submission['submitted_text'].toString().isNotEmpty) ...[
                Text("Your Note:", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14))),
                SizedBox(height: context.xs),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(context.sm),
                  ),
                  child: Text(submission['submitted_text'], style: TextStyle(color: theme.colorScheme.onSurface)),
                ),
                SizedBox(height: context.md),
              ],
              if (submission['submitted_file'] != null) ...[
                Text("Attachment:", style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14))),
                SizedBox(height: context.xs),
                OutlinedButton.icon(
                  onPressed: () => _viewFile(submission['submitted_file']),
                  icon: Icon(Icons.description, size: context.scale(18)),
                  label: const Text("View Submitted File"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, context.scale(45)),
                  ),
                ),
              ] else if (submission['submitted_text'] == null || submission['submitted_text'].toString().isEmpty)
                Text("No submission content found.", style: TextStyle(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    Map<String, List<dynamic>> groupedAssignments = {};
    for (var assignment in _assignments) {
      final subjectName = assignment['subject']?['name'] ?? assignment['subject_name'] ?? 'General';
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
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _assignments.isNotEmpty,
        skeleton: const _AssignmentsSkeleton(),
        onRefresh: _fetchAssignments,
        child: groupedAssignments.isEmpty
            ? Center(child: Text("No assignments available", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16))))
            : Center(
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
          if (assignment['attachment'] != null) ...[
            SizedBox(height: context.sm),
            TextButton.icon(
              onPressed: () => _viewFile(assignment['attachment']),
              icon: Icon(Icons.download, size: context.scale(16), color: theme.colorScheme.primary),
              label: Text("Assignment File", style: TextStyle(fontSize: context.font(13), color: theme.colorScheme.primary)),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
          SizedBox(height: context.md),
          SizedBox(
            width: double.infinity,
            height: context.scale(40),
            child: ElevatedButton(
              onPressed: isSubmitted ? () => _viewSubmission(assignment) : () => _submitAssignment(assignment),
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

class _AssignmentsSkeleton extends StatelessWidget {
  const _AssignmentsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView.separated(
          padding: context.pagePadding,
          itemCount: 5,
          separatorBuilder: (context, index) => SizedBox(height: context.md),
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(context.md),
              border: Border.all(color: context.theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                ListTile(
                  title: SkeletonBox(width: context.scale(150), height: context.scale(18)),
                  trailing: Icon(Icons.expand_more, color: context.theme.colorScheme.outlineVariant, size: context.scale(24)),
                ),
                if (index == 0) // Show first one expanded in skeleton
                  Padding(
                    padding: EdgeInsets.all(context.sm),
                    child: context.isDesktop
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: context.sm,
                              mainAxisSpacing: context.sm,
                              childAspectRatio: 2.2,
                            ),
                            itemCount: 2,
                            itemBuilder: (context, _) => const _AssignmentCardSkeleton(),
                          )
                        : Column(
                            children: List.generate(2, (_) => const _AssignmentCardSkeleton()),
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

class _AssignmentCardSkeleton extends StatelessWidget {
  const _AssignmentCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.md, vertical: context.xs),
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(context.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: context.scale(120), height: context.scale(16)),
                  SizedBox(height: context.xs),
                  SkeletonBox(width: context.scale(80), height: context.scale(12)),
                ],
              ),
              SkeletonBox(width: context.scale(60), height: context.scale(20)),
            ],
          ),
          SizedBox(height: context.md),
          SkeletonBox(width: double.infinity, height: context.scale(12)),
          SizedBox(height: context.xs),
          SkeletonBox(width: context.scale(200), height: context.scale(12)),
          SizedBox(height: context.md),
          SkeletonBox(width: double.infinity, height: context.scale(40)),
        ],
      ),
    );
  }
}
