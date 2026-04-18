import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _examNameController = TextEditingController();
  final _examTypeController = TextEditingController();
  final _examCodeController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _examNameController.dispose();
    _examTypeController.dispose();
    _examCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveExam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final body = {
        'exam_name': _examNameController.text,
        'exam_type': _examTypeController.text,
        'code': _examCodeController.text,
        'description': _descriptionController.text,
        'status': _isActive ? 'active' : 'inactive',
        if (_startDate != null) 'start_date': DateFormat('yyyy-MM-dd').format(_startDate!),
        if (_endDate != null) 'end_date': DateFormat('yyyy-MM-dd').format(_endDate!),
      };

      final response = await ApiService.post('manager/exams', body);

      if (!mounted) return;

      final responseData = jsonDecode(response.body);
      final theme = Theme.of(context);

      if (response.statusCode == 201 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Exam created successfully!'), backgroundColor: theme.colorScheme.primary),
        );
        Navigator.pop(context, true);
      } else {
        String errorMessage = responseData['message'] ?? 'Failed to create exam';
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          final specificErrors = errors.values
              .expand((errorList) => errorList as List)
              .join('\n');
          if (specificErrors.isNotEmpty) {
            errorMessage = specificErrors;
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Create New Exam',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: context.font(20),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface, size: context.scale(24)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: context.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Exam Details",
                    style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(18)),
                  ),
                  SizedBox(height: context.scale(4)),
                  Text(
                    "Fill in the information below to create a new exam.",
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11)),
                  ),
                  SizedBox(height: context.scale(24)),
                  buildFilterCard(
                    context,
                    children: [
                      buildLabel(context, "Exam Name"),
                      buildTextField(context, _examNameController, "Enter Exam Name"),
                      buildLabel(context, "Exam Type"),
                      buildTextField(context, _examTypeController, "Enter Exam Type"),
                      buildLabel(context, "Exam Code"),
                      buildTextField(context, _examCodeController, "Enter Exam Code"),
                      buildLabel(context, "Description"),
                      buildTextField(context, _descriptionController, "Enter Description", maxLines: 3),
                      SizedBox(height: context.scale(16)),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Is Active', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(14), fontWeight: FontWeight.bold)),
                        value: _isActive,
                        activeColor: theme.colorScheme.primary,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                      buildLabel(context, "Start Date"),
                      buildDateField(context, TextEditingController(text: _startDate == null ? "" : DateFormat('dd-MM-yyyy').format(_startDate!)), "Select Start Date"),
                      buildLabel(context, "End Date"),
                      buildDateField(context, TextEditingController(text: _endDate == null ? "" : DateFormat('dd-MM-yyyy').format(_endDate!)), "Select End Date"),
                      SizedBox(height: context.scale(16)),
                    ],
                  ),
                  SizedBox(height: context.scale(32)),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(context.scale(16), context.scale(8), context.scale(16), context.scale(24)),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: buildActionButton(
              context,
              _isSaving ? "SAVING..." : "CREATE EXAM",
              _isSaving ? () {} : _saveExam,
            ),
          ),
        ),
      ),
    );
  }
}
