import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
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
    _isActive = widget.isActive;

    final dates = widget.startEndDate.split(' - ');
    if (dates.length == 2) {
      try {
        _startDate = DateFormat('dd MMM yyyy').parse(dates[0]);
        _endDate = DateFormat('dd MMM yyyy').parse(dates[1]);
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
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
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

  Future<void> _updateExam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Workaround: Only send fields supported by the backend's update method.
      // Code, description, and dates are excluded to prevent a validation error.
      final fields = {
        '_method': 'PUT',
        'exam_name': _examNameController.text,
        'exam_type': _examTypeController.text,
        'status': _isActive ? 'active' : 'inactive',
      };

      final response = await ApiService.postMultipart('manager/exams/${widget.examId}', fields);
      final responseBody = await response.stream.bytesToString();

      if (!mounted) return;

      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData['message'] ?? 'Exam updated successfully!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          final errorMessages =
              errors.values.map((e) => (e as List).first).join('\n');
          throw Exception(errorMessages);
        }
        throw Exception(responseData['message'] ?? 'Failed to update exam');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceFirst("Exception: ", "")),
              backgroundColor: Colors.red),
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
      appBar: AppBar(title: const Text('Edit Exam')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _examNameController,
              decoration: const InputDecoration(labelText: 'Exam Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter an exam name' : null,
            ),
            TextFormField(
              controller: _examTypeController,
              decoration: const InputDecoration(labelText: 'Exam Type'),
               validator: (value) =>
                  value!.isEmpty ? 'Please enter an exam type' : null,
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
              title: Text(_startDate == null
                  ? 'Select Start Date'
                  : DateFormat('yyyy-MM-dd').format(_startDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: Text(_endDate == null
                  ? 'Select End Date'
                  : DateFormat('yyyy-MM-dd').format(_endDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: _isSaving ? null : _updateExam,
        child: _isSaving
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white))
            : const Text('Update Exam'),
      ),
    );
  }
}
