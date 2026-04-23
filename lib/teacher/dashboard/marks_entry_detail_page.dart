import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/exam_models.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'common_widgets.dart';

class MarksEntryDetailPage extends StatefulWidget {
  final ExamPaper paper;

  const MarksEntryDetailPage({super.key, required this.paper});

  @override
  State<MarksEntryDetailPage> createState() => _MarksEntryDetailPageState();
}

class _MarksEntryDetailPageState extends State<MarksEntryDetailPage> {
  List<ExamStudentRegistration>? _students;
  bool _isLoading = true;
  String? _error;
  final Map<int, TextEditingController> _marksControllers = {};
  final Map<int, TextEditingController> _maxMarksControllers = {};
  final Map<int, TextEditingController> _gradeControllers = {};
  final Map<int, TextEditingController> _remarksControllers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cacheKey = 'exam_students_${widget.paper.id}';
    
    // 1. Load from cache
    final cachedData = await TeacherCacheService.load(cacheKey);
    if (cachedData != null && mounted) {
      setState(() {
        _students = (cachedData['students'] as List)
            .map((s) => ExamStudentRegistration.fromJson(s))
            .toList();
        _isLoading = false;
      });
    }

    // 2. Fetch from API
    try {
      final data = await ApiService.getExamStudents(widget.paper.id);
      final students = data['students'] as List<ExamStudentRegistration>;
      if (mounted) {
        setState(() {
          _students = students;
          _isLoading = false;
          _error = null;
        });
        // 3. Save to cache
        await TeacherCacheService.save(cacheKey, {
          'students': students.map((s) => s.toJson()).toList(),
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Marks: ${widget.paper.subjectName}'),
      ),
      body: TeacherLoadingWrapper(
        isLoading: _isLoading,
        hasData: _students != null,
        skeleton: _buildSkeleton(),
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: _error != null && _students == null
              ? Center(child: Text('Error: $_error'))
              : (_students == null || _students!.isEmpty)
                  ? Center(child: Text('No students found for this class/section.'))
                  : _buildMarksEntryForm(_students!),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: 10,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: TeacherSkeleton(height: 50),
      ),
    );
  }

  Widget _buildMarksEntryForm(List<ExamStudentRegistration> students) {
    final theme = context.theme;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.scale(1200)),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: context.pagePadding,
                child: Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.scale(16)),
                    side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                        columnSpacing: context.scale(24),
                        horizontalMargin: context.scale(16),
                        headingRowHeight: context.scale(56),
                        dataRowMinHeight: context.scale(56),
                        dataRowMaxHeight: context.scale(64),
                        columns: [
                          DataColumn(label: Text('Roll No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                          DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                          DataColumn(label: Text('Obtained', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                          DataColumn(label: Text('Max Marks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                          DataColumn(label: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                          DataColumn(label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                        ],
                        rows: students.map((student) {
                          _marksControllers.putIfAbsent(student.id, () => TextEditingController(text: student.marksObtained));
                          _maxMarksControllers.putIfAbsent(student.id, () => TextEditingController(text: student.maxMarks));
                          _gradeControllers.putIfAbsent(student.id, () => TextEditingController(text: student.gradeName));
                          _remarksControllers.putIfAbsent(student.id, () => TextEditingController(text: student.remarks));
      
                          return DataRow(cells: [
                            DataCell(Text(student.rollNo ?? 'N/A', style: TextStyle(fontSize: context.font(13), color: theme.colorScheme.onSurface))),
                            DataCell(Text(student.studentName, style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface))),
                            DataCell(SizedBox(width: context.scale(80), child: _buildEntryField(_marksControllers[student.id]!))),
                            DataCell(SizedBox(width: context.scale(80), child: _buildEntryField(_maxMarksControllers[student.id]!))),
                            DataCell(SizedBox(width: context.scale(80), child: _buildEntryField(_gradeControllers[student.id]!))),
                            DataCell(SizedBox(width: context.scale(150), child: _buildEntryField(_remarksControllers[student.id]!))),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: context.pagePadding,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
              ),
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.scale(400)),
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _submitMarks(students),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        minimumSize: Size(double.infinity, context.scale(48)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                        elevation: 0,
                      ),
                      child: _isSubmitting 
                        ? SizedBox(height: context.scale(20), width: context.scale(20), child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary))
                        : Text('SUBMIT ALL MARKS', style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEntryField(TextEditingController controller) {
    final theme = context.theme;
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: context.font(13)),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(12)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(8)),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(8)),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
        const SnackBar(content: Text('Marks submitted successfully!'), backgroundColor: Color(0xFF10B981)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit marks: $e'), backgroundColor: Color(0xFFEF4444)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
