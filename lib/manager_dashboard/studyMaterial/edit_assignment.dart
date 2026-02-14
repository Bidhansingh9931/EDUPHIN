import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'assignments.dart';

class EditAssignmentPage extends StatefulWidget {
  final Assignment assignment;

  const EditAssignmentPage({super.key, required this.assignment});

  @override
  State<EditAssignmentPage> createState() => _EditAssignmentPageState();
}

class _EditAssignmentPageState extends State<EditAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _dueDate;

  int? _selectedClassId;
  int? _selectedSectionId;
  int? _selectedSubjectId;

  PlatformFile? _selectedFile;

  bool _isLoading = true;
  bool _isSaving = false;
  List<dynamic> _classes = [];
  List<dynamic> _sections = [];
  List<dynamic> _subjects = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.assignment.title);
    _descriptionController =
        TextEditingController(text: widget.assignment.description);
    if (widget.assignment.dueDate != 'N/A' &&
        widget.assignment.dueDate.isNotEmpty) {
      try {
        _dueDate = DateFormat('dd MMM yyyy').parse(widget.assignment.dueDate);
      } catch (e) {
        _dueDate = null;
      }
    } else {
      _dueDate = null;
    }
    _fetchDataAndSetInitialValues();
  }

  Future<void> _fetchDataAndSetInitialValues() async {
    try {
      final response = await ApiService.get('manager/class-schedules/meta');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _classes = data['classes'] ?? [];
          _subjects = data['subjects'] ?? [];

          final initialClass = _classes.firstWhere(
              (c) => c['name'] == widget.assignment.className,
              orElse: () => null);
          if (initialClass != null) {
            _selectedClassId = initialClass['id'];
            _sections = initialClass['sections'] ?? [];
            final initialSection = _sections.firstWhere(
                (s) => s['section_name'] == widget.assignment.section,
                orElse: () => null);
            if (initialSection != null) {
              _selectedSectionId = initialSection['id'];
            }
          }

          final initialSubject = _subjects.firstWhere(
              (s) => s['subject_name'] == widget.assignment.subject,
              orElse: () => null);
          if (initialSubject != null) {
            _selectedSubjectId = initialSubject['id'];
          }

          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = result.files.single;
      });
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _updateAssignment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final token = await ApiService.getToken();
      var request = http.MultipartRequest('POST',
          Uri.parse('${ApiService.baseUrl}/manager/study/assignments/${widget.assignment.id}'));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['_method'] = 'PUT';
      request.fields['title'] = _titleController.text;
      request.fields['description'] = _descriptionController.text;
      if (_selectedClassId != null) {
        request.fields['class_id'] = _selectedClassId.toString();
      }
      if (_selectedSectionId != null) {
        request.fields['section_id'] = _selectedSectionId.toString();
      }
      if (_selectedSubjectId != null) {
        request.fields['subject_id'] = _selectedSubjectId.toString();
      }
      if (_dueDate != null) {
        request.fields['due_date'] = DateFormat('yyyy-MM-dd').format(_dueDate!);
      }

      if (_selectedFile != null) {
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            _selectedFile!.bytes!,
            filename: _selectedFile!.name,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'file',
            _selectedFile!.path!,
            filename: _selectedFile!.name,
          ));
        }
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Assignment updated successfully!'),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);
        throw Exception(
            responseData['message'] ?? 'Failed to update assignment');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
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
      appBar: AppBar(title: const Text("Edit Assignment")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedClassId,
                    items: _classes
                        .map<DropdownMenuItem<int>>((c) =>
                            DropdownMenuItem(value: c['id'], child: Text(c['name'] ?? '')))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClassId = value;
                        _selectedSectionId = null;
                        if (value == null) {
                          _sections = [];
                        } else {
                          final selectedClass = _classes.firstWhere(
                              (c) => c['id'] == value,
                              orElse: () => null);
                          _sections = (selectedClass != null
                                  ? selectedClass['sections']
                                  : []) ??
                              [];
                        }
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Class'),
                    validator: (value) =>
                        value == null ? 'Please select a class' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: ValueKey('section_$_selectedClassId'),
                    initialValue: _selectedSectionId,
                    items: _sections
                        .map<DropdownMenuItem<int>>((s) => DropdownMenuItem(
                            value: s['id'], child: Text(s['section_name'] ?? '')))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSectionId = value),
                    decoration: const InputDecoration(labelText: 'Section'),
                    validator: (value) =>
                        value == null ? 'Please select a section' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedSubjectId,
                    items: _subjects
                        .map<DropdownMenuItem<int>>((s) => DropdownMenuItem(
                            value: s['id'], child: Text(s['subject_name'] ?? '')))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedSubjectId = value),
                    decoration: const InputDecoration(labelText: 'Subject'),
                    validator: (value) =>
                        value == null ? 'Please select a subject' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a description' : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(_dueDate == null
                        ? 'Select Due Date'
                        : DateFormat('yyyy-MM-dd').format(_dueDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectDueDate,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            _selectedFile?.name ?? 'No file selected'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: _pickFile,
                      ),
                    ],
                  ),
                ],
              ),
            ),
      floatingActionButton: ElevatedButton(
        onPressed: _isSaving ? null : _updateAssignment,
        child: _isSaving
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white))
            : const Text('Update Assignment'),
      ),
    );
  }
}
