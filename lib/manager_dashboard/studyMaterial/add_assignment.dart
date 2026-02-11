import 'dart:convert';
import 'dart:io';

import 'package:eduphin/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddAssignmentPage extends StatefulWidget {
  const AddAssignmentPage({super.key});

  @override
  State<AddAssignmentPage> createState() => _AddAssignmentPageState();
}

class _AddAssignmentPageState extends State<AddAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;

  int? _selectedClassId;
  int? _selectedSectionId;
  int? _selectedSubjectId;
  File? _selectedFile;
  String? _selectedFileName;

  bool _isLoading = true;
  bool _isSaving = false;
  List<dynamic> _classes = [];
  List<dynamic> _sections = [];
  List<dynamic> _subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await ApiService.get('manager/class-schedules/meta');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _classes = data['classes'] ?? [];
          _subjects = data['subjects'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
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

  Future<void> _saveAssignment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final token = await ApiService.getToken();
      var request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}/manager/study/assignments'));
      request.headers['Authorization'] = 'Bearer $token';
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
        request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path));
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        if(mounted){
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assignment added successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);
        throw Exception(responseData['message'] ?? 'Failed to add assignment');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted){
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Assignment")),
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
                    validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedClassId,
                    items: _classes.map<DropdownMenuItem<int>>((c) => DropdownMenuItem(value: c['id'], child: Text(c['name'] ?? ''))).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClassId = value;
                        _selectedSectionId = null;
                        if (value == null) {
                          _sections = [];
                        } else {
                          final selectedClass = _classes.firstWhere((c) => c['id'] == value, orElse: () => null);
                          _sections = (selectedClass != null ? selectedClass['sections'] : []) ?? [];
                        }
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Class'),
                    validator: (value) => value == null ? 'Please select a class' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: ValueKey('section_$_selectedClassId'),
                    initialValue: _selectedSectionId,
                    items: _sections.map<DropdownMenuItem<int>>((s) => DropdownMenuItem(value: s['id'], child: Text(s['section_name'] ?? ''))).toList(),
                    onChanged: (value) => setState(() => _selectedSectionId = value),
                    decoration: const InputDecoration(labelText: 'Section'),
                    validator: (value) => value == null ? 'Please select a section' : null,
                  ),
                   const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedSubjectId,
                    items: _subjects.map<DropdownMenuItem<int>>((s) => DropdownMenuItem(value: s['id'], child: Text(s['subject_name'] ?? ''))).toList(),
                    onChanged: (value) => setState(() => _selectedSubjectId = value),
                    decoration: const InputDecoration(labelText: 'Subject'),
                    validator: (value) => value == null ? 'Please select a subject' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                     maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                  ),
                  const SizedBox(height: 16),
                   ListTile(
                    title: Text(_dueDate == null ? 'Select Due Date' : DateFormat('yyyy-MM-dd').format(_dueDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectDueDate,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_selectedFileName ?? 'No file selected'),
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
         onPressed: _isSaving ? null : _saveAssignment,
         child: _isSaving ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)) : const Text('Save Assignment'),
       ),
    );
  }
}
