
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/exam_models.dart';

class MarksEntryDetailPage extends StatefulWidget {
  final ExamPaper paper;

  const MarksEntryDetailPage({super.key, required this.paper});

  @override
  State<MarksEntryDetailPage> createState() => _MarksEntryDetailPageState();
}

class _MarksEntryDetailPageState extends State<MarksEntryDetailPage> {
  late Future<Map<String, dynamic>> _studentsFuture;
  final Map<int, TextEditingController> _marksControllers = {};
  final Map<int, TextEditingController> _maxMarksControllers = {};
  final Map<int, TextEditingController> _gradeControllers = {};
  final Map<int, TextEditingController> _remarksControllers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _studentsFuture = ApiService.getExamStudents(widget.paper.id);
  }

  @override
  void dispose() {
    for (var controller in _marksControllers.values) {
      controller.dispose();
    }
    for (var controller in _maxMarksControllers.values) {
      controller.dispose();
    }
    for (var controller in _gradeControllers.values) {
      controller.dispose();
    }
    for (var controller in _remarksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF0B1230) : Colors.grey.shade100;
    final cardColor = isDarkMode ? const Color(0xFF1E2A5A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF3E446A) : Colors.blue,
        title: Text('Enter Marks: ${widget.paper.subjectName}', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
          } else if (!snapshot.hasData || (snapshot.data!['students'] as List).isEmpty) {
            return Center(child: Text('No students found for this class/section.', style: TextStyle(color: textColor)));
          } else {
            final students = snapshot.data!['students'] as List<ExamStudentRegistration>;
            return _buildMarksEntryForm(students, isDarkMode, textColor, cardColor);
          }
        },
      ),
    );
  }

  Widget _buildMarksEntryForm(List<ExamStudentRegistration> students, bool isDarkMode, Color textColor, Color cardColor) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(isDarkMode ? Colors.white10 : Colors.grey.shade200),
                columns: [
                  DataColumn(label: Text('Roll No', style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Student Name', style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Obtained', style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Max Marks', style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Grade', style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Remarks', style: TextStyle(color: textColor, fontWeight: FontWeight.bold))),
                ],
                rows: students.map((student) {
                  _marksControllers.putIfAbsent(student.id, () => TextEditingController(text: student.marksObtained));
                  _maxMarksControllers.putIfAbsent(student.id, () => TextEditingController(text: student.maxMarks));
                  _gradeControllers.putIfAbsent(student.id, () => TextEditingController(text: student.gradeName));
                  _remarksControllers.putIfAbsent(student.id, () => TextEditingController(text: student.remarks));

                  return DataRow(cells: [
                    DataCell(Text(student.rollNo ?? 'N/A', style: TextStyle(color: textColor))),
                    DataCell(Text(student.studentName, style: TextStyle(color: textColor))),
                    DataCell(SizedBox(width: 80, child: _buildEntryField(_marksControllers[student.id]!, isDarkMode))),
                    DataCell(SizedBox(width: 80, child: _buildEntryField(_maxMarksControllers[student.id]!, isDarkMode))),
                    DataCell(SizedBox(width: 80, child: _buildEntryField(_gradeControllers[student.id]!, isDarkMode))),
                    DataCell(SizedBox(width: 150, child: _buildEntryField(_remarksControllers[student.id]!, isDarkMode))),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: cardColor,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : () => _submitMarks(students),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('SUBMIT ALL MARKS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        )
      ],
    );
  }

  Widget _buildEntryField(TextEditingController controller, bool isDarkMode) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: isDarkMode ? Colors.white10 : Colors.grey.shade50,
      ),
    );
  }

  void _submitMarks(List<ExamStudentRegistration> students) async {
    setState(() => _isSubmitting = true);

    final marksObtained = <String, String>{};
    final maxMarks = <String, String>{};
    final gradeNames = <String, String>{};
    final remarks = <String, String>{};

    for (var student in students) {
      marksObtained[student.id.toString()] = _marksControllers[student.id]!.text;
      maxMarks[student.id.toString()] = _maxMarksControllers[student.id]!.text;
      gradeNames[student.id.toString()] = _gradeControllers[student.id]!.text;
      remarks[student.id.toString()] = _remarksControllers[student.id]!.text;
    }

    final payload = {
      'marks_obtained': marksObtained,
      'max_marks': maxMarks,
      'grade_name': gradeNames,
      'remarks': remarks,
    };

    try {
      await ApiService.submitExamMarks(widget.paper.id, payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marks submitted successfully!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit marks: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
