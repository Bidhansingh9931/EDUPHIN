import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedClassId;
  int? _selectedSectionId;
  PlatformFile? _selectedFile;

  bool _isLoading = true;
  bool _isSaving = false;
  List<dynamic> _classes = [];
  List<dynamic> _sections = [];

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchClasses() async {
    try {
      final response = await ApiService.get('manager/classes');
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _classes = data;
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
        _selectedFile = result.files.single;
      });
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    bool success = false;

    try {
      final token = await ApiService.getToken();
      var request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}/api/manager/study/notes'));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['title'] = _titleController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['class_id'] = _selectedClassId.toString();
      request.fields['section_id'] = _selectedSectionId.toString();

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
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);
      final theme = Theme.of(context);

      if (response.statusCode == 201 && responseData['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Note added successfully!'), backgroundColor: theme.colorScheme.primary),
          );
          success = true;
        }
      } else {
        throw Exception(responseData['message'] ?? 'Failed to add note');
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: theme.colorScheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Note", style: TextStyle(fontSize: context.font(20))),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: context.pagePadding,
                    children: [
                      _buildFormSection(
                        title: 'Note Information',
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              hintText: 'Enter note title',
                              prefixIcon: const Icon(Icons.title),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(context.sm),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                          ),
                          SizedBox(height: context.md),
                          LayoutBuilder(builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildClassDropdown()),
                                  SizedBox(width: context.md),
                                  Expanded(child: _buildSectionDropdown()),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                _buildClassDropdown(),
                                SizedBox(height: context.md),
                                _buildSectionDropdown(),
                              ],
                            );
                          }),
                          SizedBox(height: context.md),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              hintText: 'Enter note description',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(context.sm),
                              ),
                            ),
                            maxLines: 4,
                            validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                          ),
                        ],
                      ),
                      SizedBox(height: context.lg),
                      _buildFormSection(
                        title: 'Attachment',
                        children: [
                          InkWell(
                            onTap: _pickFile,
                            borderRadius: BorderRadius.circular(context.sm),
                            child: Container(
                              padding: EdgeInsets.all(context.md),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerLow,
                                border: Border.all(color: theme.colorScheme.outlineVariant),
                                borderRadius: BorderRadius.circular(context.sm),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.attach_file, color: theme.colorScheme.primary),
                                  SizedBox(width: context.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedFile?.name ?? 'Select File',
                                          style: theme.textTheme.titleSmall,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (_selectedFile == null)
                                          Text(
                                            'PDF, JPG, PNG or DOC (Max 10MB)',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (_selectedFile != null)
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => setState(() => _selectedFile = null),
                                    )
                                  else
                                    Text(
                                      'Browse',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.xl),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildFormSection({required String title, required List<Widget> children}) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: context.sm),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildClassDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedClassId,
      items: _classes.map<DropdownMenuItem<int>>((c) => DropdownMenuItem(value: c['id'], child: Text(c['name']))).toList(),
      onChanged: (value) {
        setState(() {
          _selectedClassId = value;
          _selectedSectionId = null;
          _sections = _classes.firstWhere((c) => c['id'] == value)['sections'] ?? [];
        });
      },
      decoration: InputDecoration(
        labelText: 'Class',
        prefixIcon: const Icon(Icons.class_),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.sm),
        ),
      ),
      validator: (value) => value == null ? 'Please select a class' : null,
    );
  }

  Widget _buildSectionDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedSectionId,
      items: _sections.map<DropdownMenuItem<int>>((s) => DropdownMenuItem(value: s['id'], child: Text(s['section_name']))).toList(),
      onChanged: (value) => setState(() => _selectedSectionId = value),
      decoration: InputDecoration(
        labelText: 'Section',
        prefixIcon: const Icon(Icons.group),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.sm),
        ),
      ),
      validator: (value) => value == null ? 'Please select a section' : null,
    );
  }

  Widget _buildBottomActions() {
    final theme = context.theme;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: context.lg, vertical: context.md),
                ),
                child: const Text('Cancel'),
              ),
              SizedBox(width: context.md),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size(0, 54),
                  padding: EdgeInsets.symmetric(horizontal: context.xl, vertical: context.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.sm)),
                ),
                child: _isSaving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(theme.colorScheme.onPrimary),
                        ),
                      )
                    : const Text('Save Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
