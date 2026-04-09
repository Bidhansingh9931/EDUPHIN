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

  // Theme Colors
  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);
  final Color _surface = const Color(0xff2A3450);

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
          SnackBar(content: Text("Error fetching assignments: $e")),
        );
      }
    }
  }

  Future<void> _submitAssignment(dynamic assignment) async {
    final TextEditingController textController = TextEditingController();
    File? selectedFile;
    String? fileName;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Submit: ${assignment['title']}",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Submission Note", style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: textController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter submission text (optional)...",
                    hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                    filled: true,
                    fillColor: _secondary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Attachment", style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
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
                    icon: const Icon(Icons.attach_file, size: 18),
                    label: Text(fileName ?? "Pick File (PDF/Doc)"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: _primary.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
              child: const Text("SUBMIT"),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploading submission...")));
      
      try {
        final String? idHash = assignment['id_hash']?.toString();
        if (idHash == null) throw Exception("Assignment ID missing");

        await ApiService.submitStudentAssignment(
          idHash,
          file: selectedFile,
          text: textController.text.isNotEmpty ? textController.text : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Assignment submitted successfully!")));
          _fetchAssignments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Submission failed: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> groupedAssignments = {};
    for (var assignment in _assignments) {
      final subjectName = assignment['subject']?['name'] ?? 'General';
      if (!groupedAssignments.containsKey(subjectName)) {
        groupedAssignments[subjectName] = [];
      }
      groupedAssignments[subjectName]!.add(assignment);
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Assignments",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primary))
          : groupedAssignments.isEmpty
              ? const Center(child: Text("No assignments available", style: TextStyle(color: Colors.white70)))
              : RefreshIndicator(
                  onRefresh: _fetchAssignments,
                  color: _primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: groupedAssignments.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final subjectName = groupedAssignments.keys.elementAt(index);
                      final subjectAssignments = groupedAssignments[subjectName]!;
                      final bool isOpen = _subjectOpenStates[subjectName] ?? false;

                      return Container(
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                subjectName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: AnimatedRotation(
                                duration: const Duration(milliseconds: 200),
                                turns: isOpen ? 0.5 : 0,
                                child: const Icon(Icons.expand_more, color: Colors.white70),
                              ),
                              onTap: () {
                                setState(() {
                                  _subjectOpenStates[subjectName] = !isOpen;
                                });
                              },
                            ),
                            if (isOpen)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  children: subjectAssignments.map((a) => _assignmentCard(a)).toList(),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _assignmentCard(dynamic assignment) {
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
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
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.white54, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Due: $formattedDate",
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isSubmitted ? Colors.greenAccent : Colors.orangeAccent).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: (isSubmitted ? Colors.greenAccent : Colors.orangeAccent).withValues(alpha: 0.5)),
                ),
                child: Text(
                  isSubmitted ? "SUBMITTED" : "PENDING",
                  style: TextStyle(color: isSubmitted ? Colors.greenAccent : Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          if (assignment['description'] != null && assignment['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              assignment['description'] ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: isSubmitted ? null : () => _submitAssignment(assignment),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSubmitted ? _secondary : _primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _secondary.withValues(alpha: 0.5),
                disabledForegroundColor: Colors.white38,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(isSubmitted ? "VIEW SUBMISSION" : "SUBMIT ASSIGNMENT", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          )
        ],
      ),
    );
  }
}
