import 'dart:convert';
import 'dart:io';

import 'package:eduphin/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'notes.dart';

class EditNotePage extends StatefulWidget {
  final StudyMaterial material;

  const EditNotePage({super.key, required this.material});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  int? _selectedClassId;
  int? _selectedSectionId;
  File? _selectedFile;

  bool _isLoading = true;
  bool _isSaving = false;
  List<dynamic> _classes = [];
  List<dynamic> _sections = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.material.title);
    _descriptionController = TextEditingController(text: widget.material.description);
    _fetchClassesAndSetInitialValues();
  }

  Future<void> _fetchClassesAndSetInitialValues() async {
    try {
      final response = await ApiService.get('manager/classes');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _classes = data;
          // Find class and section IDs from names
          final initialClass = _classes.firstWhere((c) => c['name'] == widget.material.className, orElse: () => null);
          if (initialClass != null) {
            _selectedClassId = initialClass['id'];
            _sections = initialClass['sections'];
            final initialSection = _sections.firstWhere((s) => s['section_name'] == widget.material.section, orElse: () => null);
            if (initialSection != null) {
              _selectedSectionId = initialSection['id'];
            }
          }
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load classes');
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
      });
    }
  }

  Future<void> _updateNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final token = await ApiService.getToken();
      var request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}/manager/study/notes/${widget.material.id}')); // Using POST for update as Laravel uses this for multipart form-data with _method
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['_method'] = 'PUT'; // Method spoofing
      request.fields['title'] = _titleController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['class_id'] = _selectedClassId.toString();
      request.fields['section_id'] = _selectedSectionId.toString();

      if (_selectedFile != null) {
        request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
         if(mounted){
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note updated successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);
        throw Exception(responseData['message'] ?? 'Failed to update note');
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
      appBar: AppBar(title: const Text("Edit Note")),
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
                    value: _selectedClassId,
                    items: _classes.map<DropdownMenuItem<int>>((c) => DropdownMenuItem(value: c['id'], child: Text(c['name']))).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedClassId = value;
                        _selectedSectionId = null;
                        _sections = _classes.firstWhere((c) => c['id'] == value)['sections'];
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Class'),
                    validator: (value) => value == null ? 'Please select a class' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedSectionId,
                    items: _sections.map<DropdownMenuItem<int>>((s) => DropdownMenuItem(value: s['id'], child: Text(s['section_name']))).toList(),
                    onChanged: (value) => setState(() => _selectedSectionId = value),
                    decoration: const InputDecoration(labelText: 'Section'),
                     validator: (value) => value == null ? 'Please select a section' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                     validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_selectedFile?.path.split('/').last ?? 'No file selected'),
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
        onPressed: _isSaving ? null : _updateNote,
        child: _isSaving ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)) : const Text('Update Note'),
      ),
    );
  }
}
