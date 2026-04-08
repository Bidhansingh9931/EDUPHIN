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
          backgroundColor: const Color(0xff3c4566),
          title: Text("Submit: ${assignment['title']}", style: const TextStyle(color: Colors.white, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Enter submission text (optional)...",
                    hintStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
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
                  icon: const Icon(Icons.attach_file),
                  label: Text(fileName ?? "Attach File (PDF/Doc)"),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff46507a)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("SUBMIT", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      // Show loading
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
      backgroundColor: const Color(0xff0a1230),
      appBar: AppBar(
        backgroundColor: const Color(0xff0a1230),
        elevation: 0,
        title: const Text(
          "Assignments",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : groupedAssignments.isEmpty
              ? const Center(child: Text("No assignments available", style: TextStyle(color: Colors.white70)))
              : RefreshIndicator(
                  onRefresh: _fetchAssignments,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: groupedAssignments.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final subjectName = groupedAssignments.keys.elementAt(index);
                      final subjectAssignments = groupedAssignments[subjectName]!;
                      final bool isOpen = _subjectOpenStates[subjectName] ?? false;

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff3c4566),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                subjectName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: Icon(
                                isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                              onTap: () {
                                setState(() {
                                  _subjectOpenStates[subjectName] = !isOpen;
                                });
                              },
                            ),
                            if (isOpen)
                              ...subjectAssignments.map((a) => assignmentCard(a)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget assignmentCard(dynamic assignment) {
    final dueDateStr = assignment['due_date'];
    String formattedDate = "N/A";
    if (dueDateStr != null) {
      try {
        DateTime dt = DateTime.parse(dueDateStr);
        formattedDate = DateFormat('dd MMM, yyyy').format(dt);
      } catch (_) {}
    }

    // Backend provides submission object if student already submitted
    final bool isSubmitted = assignment['submission'] != null;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff46507a),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  assignment['title'] ?? 'N/A',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSubmitted ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isSubmitted ? "SUBMITTED" : "PENDING",
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                "Due Date: $formattedDate",
                style: const TextStyle(color: Colors.white70),
              )
            ],
          ),
          const SizedBox(height: 20),
          Text(
            assignment['description'] ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isSubmitted ? null : () => _submitAssignment(assignment),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSubmitted ? Colors.grey : const Color(0xff6b7685),
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isSubmitted ? "VIEW SUBMISSION" : "SUBMIT ASSIGNMENT"),
          )
        ],
      ),
    );
  }
}
