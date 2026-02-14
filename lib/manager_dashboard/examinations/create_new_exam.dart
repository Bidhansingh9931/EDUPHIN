import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Exam')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _examNameController,
              decoration: const InputDecoration(labelText: 'Exam Name'),
              validator: (value) => value!.isEmpty ? 'Please enter an exam name' : null,
            ),
            TextFormField(
              controller: _examTypeController,
              decoration: const InputDecoration(labelText: 'Exam Type'),
            ),
            TextFormField(
              controller: _examCodeController,
              decoration: const InputDecoration(labelText: 'Exam Code'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            SwitchListTile(
              title: const Text('Is Active'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            ListTile(
              title: Text(_startDate == null ? 'Select Start Date' : DateFormat('yyyy-MM-dd').format(_startDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: Text(_endDate == null ? 'Select End Date' : DateFormat('yyyy-MM-dd').format(_endDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: _isSaving ? null : _saveExam,
        child: _isSaving ? const CircularProgressIndicator() : const Text('Save Exam'),
      ),
    );
  }
}
