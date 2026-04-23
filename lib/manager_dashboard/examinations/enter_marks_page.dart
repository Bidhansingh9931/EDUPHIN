import 'dart:async';
import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';

class StudentRegistration {
  final int registrationId;
  final String studentName;
  final String rollNo;

  StudentRegistration({
    required this.registrationId,
    required this.studentName,
    required this.rollNo,
  });

  factory StudentRegistration.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>? ?? {};
    final user = student['user'] as Map<String, dynamic>? ?? {};

    String? name = user['name']?.toString() ?? student['name']?.toString();
    if (name == null || name.isEmpty) {
      name = "${student['first_name']?.toString() ?? ''} ${student['last_name']?.toString() ?? ''}".trim();
    }
    if (name.isEmpty) name = 'N/A';

    final rollNo = student['registration_no']?.toString() ??
        student['student_roll_no']?.toString() ??
        student['roll_no']?.toString() ??
        'N/A';

    return StudentRegistration(
      registrationId: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      studentName: name,
      rollNo: rollNo,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': registrationId,
    'student': {
      'name': studentName,
      'registration_no': rollNo,
    },
  };
}

class Mark {
  final TextEditingController obtainedController = TextEditingController();
  final TextEditingController maxController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  void dispose() {
    obtainedController.dispose();
    maxController.dispose();
    gradeController.dispose();
    remarkController.dispose();
  }
}

class EnterMarksPage extends StatefulWidget {
  final int paperId;
  final int examId;
  final int classId;
  final int sectionId;
  final int subjectId;
  final String subjectName;

  const EnterMarksPage({
    super.key,
    required this.paperId,
    required this.examId,
    required this.classId,
    required this.sectionId,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<EnterMarksPage> createState() => _EnterMarksPageState();
}

class _EnterMarksPageState extends State<EnterMarksPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  Object? _error;
  List<StudentRegistration> _students = [];
  final Map<int, Mark> _marks = {};

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetch();
  }

  @override
  void dispose() {
    for (var mark in _marks.values) {
      mark.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCacheAndFetch() async {
    final cacheKey = 'manager_marks_reg_${widget.examId}_${widget.classId}_${widget.sectionId}';
    final cachedData = await CachingService.getCache(cacheKey);
    if (cachedData != null && mounted) {
      final List<dynamic> jsonList = cachedData;
      setState(() {
        _students = jsonList.map((json) => StudentRegistration.fromJson(json)).toList();
        _initializeMarks();
      });
    }
    _fetchStudents();
  }

  void _initializeMarks() {
    for (var student in _students) {
      if (!_marks.containsKey(student.registrationId)) {
        _marks[student.registrationId] = Mark();
      }
    }
  }

  Future<void> _fetchStudents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get(
          'manager/registrations/${widget.examId}/${widget.classId}/${widget.sectionId}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        await CachingService.setCache('manager_marks_reg_${widget.examId}_${widget.classId}_${widget.sectionId}', data);
        if (mounted) {
          setState(() {
            _students = data.map((json) => StudentRegistration.fromJson(json)).toList();
            _initializeMarks();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load students (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e;
        });
      }
    }
  }

  Future<void> _saveMarks() async {
    if (_isSaving) return;

    final Map<String, dynamic> marksPayload = {};
    String? validationError;

    _marks.forEach((registrationId, mark) {
      final obtainedStr = mark.obtainedController.text.trim();
      final maxStr = mark.maxController.text.trim();

      if (obtainedStr.isNotEmpty && maxStr.isNotEmpty) {
        final double? obtained = double.tryParse(obtainedStr);
        final double? max = double.tryParse(maxStr);

        if (obtained != null && max != null && obtained > max) {
          final student = _students.firstWhere((s) => s.registrationId == registrationId);
          validationError = "Obtained marks cannot be greater than maximum marks for ${student.studentName}";
        }
      }

      marksPayload[registrationId.toString()] = {
        'subject_id': widget.subjectId,
        'obtained': obtainedStr,
        'max': maxStr,
        'grade': mark.gradeController.text,
        'remark': mark.remarkController.text,
      };
    });

    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await ApiService.post('manager/marks/${widget.paperId}', {
        'marks': marksPayload,
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marks saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to save marks');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget buildActionButton(BuildContext context, String label, VoidCallback onPressed) {
    final theme = context.theme;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        minimumSize: Size(double.infinity, context.scale(48)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: context.font(14),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface, size: context.scale(24)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Enter Marks",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: context.font(18),
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading && _students.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.sm, vertical: 8),
              child: TextButton(
                onPressed: _isSaving ? null : _saveMarks,
                child: _isSaving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                        ),
                      )
                    : Text(
                        'Save',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _isLoading && _students.isEmpty || _error != null || _students.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: buildActionButton(
                      context,
                      "SAVE MARKS",
                      _saveMarks,
                    ),
                  ),
                ),
              ),
            ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _students.isNotEmpty,
        error: _error,
        onRetry: _fetchStudents,
        skeleton: _buildSkeleton(),
        child: _students.isEmpty && !_isLoading
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: _fetchStudents,
                child: ListView(
                  padding: context.pagePadding,
                  children: [
                    _buildHeader(),
                    SizedBox(height: context.md),
                    _buildMarksTable(),
                    SizedBox(height: context.scale(100)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: context.pagePadding,
      children: [
        SkeletonBox(height: context.scale(40), width: context.scale(200)),
        SizedBox(height: context.md),
        SkeletonBox(height: context.scale(400), borderRadius: context.scale(16)),
      ],
    );
  }


  Widget _buildHeader() {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.subjectName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: context.font(18),
          ),
        ),
        Text(
          "Enter the marks obtained by students for this subject",
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: context.font(11),
          ),
        ),
      ],
    );
  }

  Widget _buildMarksTable() {
    final theme = context.theme;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.scale(16)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: context.scale(24),
            horizontalMargin: context.scale(16),
            headingRowHeight: context.scale(56),
            dataRowMaxHeight: context.scale(80),
            headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHigh),
            headingTextStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              fontSize: context.font(14),
            ),
            columns: const [
              DataColumn(label: Text('Student Name')),
              DataColumn(label: Text('Obtained')),
              DataColumn(label: Text('Max')),
              DataColumn(label: Text('Grade')),
              DataColumn(label: Text('Remark')),
            ],
            rows: _students.map((student) {
              final mark = _marks[student.registrationId]!;
              return DataRow(
                cells: [
                  DataCell(
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: context.scale(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            student.studentName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: context.font(13),
                            ),
                          ),
                          Text(
                            'Roll: ${student.rollNo}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: context.font(11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: context.scale(80),
                      child: _buildTableTextField(mark.obtainedController, keyboardType: TextInputType.number),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: context.scale(80),
                      child: _buildTableTextField(mark.maxController, keyboardType: TextInputType.number),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: context.scale(80),
                      child: _buildTableTextField(mark.gradeController),
                    ),
                  ),
                  DataCell(
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: context.scale(8)),
                      child: SizedBox(
                        width: context.scale(180),
                        child: _buildTableTextField(mark.remarkController),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTableTextField(TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    final theme = context.theme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: context.font(13),
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(12)),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(8)),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(8)),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(8)),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: context.scale(48)),
            SizedBox(height: context.spacing),
            Text(_error.toString(), textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error, fontSize: context.font(14))),
            SizedBox(height: context.md),
            ElevatedButton(onPressed: _fetchStudents, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = context.theme;
    return RefreshIndicator(
      onRefresh: _fetchStudents,
      child: ListView(
        children: [
          SizedBox(height: context.scale(100)),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.scale(32)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: context.scale(64), color: theme.colorScheme.outlineVariant),
                  SizedBox(height: context.scale(16)),
                  Text(
                    "No students registered",
                    style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(16), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: context.scale(8)),
                  Text(
                    "Ensure students are registered for this exam session.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(13)),
                  ),
                  SizedBox(height: context.scale(24)),
                  ElevatedButton.icon(
                    onPressed: _fetchStudents,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

