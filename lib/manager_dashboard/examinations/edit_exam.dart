import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditExamPage extends StatefulWidget {
  final int examId;
  final String examName;
  final String examType;
  final String examCode;
  final bool isActive;
  final String startEndDate;
  final String? description;

  const EditExamPage({
    super.key,
    required this.examId,
    required this.examName,
    required this.examType,
    required this.examCode,
    required this.isActive,
    required this.startEndDate,
    this.description,
  });

  @override
  State<EditExamPage> createState() => _EditExamPageState();
}

class _EditExamPageState extends State<EditExamPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _examNameController;
  late final TextEditingController _examTypeController;
  late final TextEditingController _examCodeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  DateTime? _startDate;
  DateTime? _endDate;
  late bool _isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _examNameController = TextEditingController(text: widget.examName);
    _examTypeController = TextEditingController(text: widget.examType);
    _examCodeController = TextEditingController(text: widget.examCode);
    _descriptionController = TextEditingController(text: widget.description);
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _isActive = widget.isActive;

    final dates = widget.startEndDate.split(' - ');
    if (dates.length == 2) {
      try {
        _startDate = DateFormat('dd MMM yyyy').parse(dates[0]);
        _endDate = DateFormat('dd MMM yyyy').parse(dates[1]);
        _startDateController.text = DateFormat('dd-MM-yyyy').format(_startDate!);
        _endDateController.text = DateFormat('dd-MM-yyyy').format(_endDate!);
      } catch (e) {
        // Handle format exception if parsing fails
      }
    }
  }

  @override
  void dispose() {
    _examNameController.dispose();
    _examTypeController.dispose();
    _examCodeController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _updateExam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final fields = <String, String>{
        '_method': 'PUT',
        'exam_name': _examNameController.text,
        'exam_type': _examTypeController.text,
        'exam_code': _examCodeController.text,
        'description': _descriptionController.text,
        'status': _isActive ? 'active' : 'inactive',
      };
      
      if (_startDateController.text.isNotEmpty) {
        final date = DateFormat('dd-MM-yyyy').parse(_startDateController.text);
        fields['start_date'] = DateFormat('yyyy-MM-dd').format(date);
      }
      if (_endDateController.text.isNotEmpty) {
        final date = DateFormat('dd-MM-yyyy').parse(_endDateController.text);
        fields['end_date'] = DateFormat('yyyy-MM-dd').format(date);
      }

      final response = await ApiService.postMultipart('manager/exams/${widget.examId}', fields);
      final responseBody = await response.stream.bytesToString();

      if (!mounted) return;

      final responseData = jsonDecode(responseBody);
      if (response.statusCode == 200 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Exam updated successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update exam');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Edit Exam', style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: context.pagePadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Exam Information",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(18),
                    ),
                  ),
                  Text(
                    "Update the exam details and configuration",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: context.font(11),
                    ),
                  ),
                  SizedBox(height: context.md),
                  buildFilterCard(
                    context,
                    children: [
                      buildLabel(context, "Exam Name"),
                      buildTextField(context, _examNameController, "e.g., Final Examination"),
                      
                      buildLabel(context, "Exam Type"),
                      buildTextField(context, _examTypeController, "e.g., Written"),

                      buildLabel(context, "Exam Code"),
                      buildTextField(context, _examCodeController, "e.g., EXAM001"),

                      buildLabel(context, "Description"),
                      buildTextField(context, _descriptionController, "Enter description", maxLines: 3),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel(context, "Start Date"),
                                buildDateField(context, _startDateController, "Select Date"),
                              ],
                            ),
                          ),
                          SizedBox(width: context.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel(context, "End Date"),
                                buildDateField(context, _endDateController, "Select Date"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: context.md),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Is Active', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: context.font(14))),
                        value: _isActive,
                        activeColor: theme.colorScheme.primary,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                      SizedBox(height: context.md),
                    ],
                  ),
                  SizedBox(height: context.lg),
                  if (_isSaving)
                    const Center(child: CircularProgressIndicator())
                  else
                    buildActionButton(
                      context,
                      "Update Exam",
                      _updateExam,
                    ),
                  SizedBox(height: context.md),
                  buildActionButton(
                    context,
                    "Cancel",
                    () => Navigator.pop(context),
                    isPrimary: false,
                  ),
                  SizedBox(height: context.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
