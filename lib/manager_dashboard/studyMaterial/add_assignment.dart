import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
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
  PlatformFile? _selectedFile;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
      if (result != null) {
        if (!mounted) return;
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
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
    final theme = Theme.of(context);

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
        if (_selectedFile!.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'file',
            _selectedFile!.path!,
            filename: _selectedFile!.name,
          ));
        } else if (_selectedFile!.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            _selectedFile!.bytes!,
            filename: _selectedFile!.name,
          ));
        }
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Assignment added successfully!'),
              backgroundColor: theme.colorScheme.primary,
            ),
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
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: theme.colorScheme.error,
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
      appBar: AppBar(
        title: Text("Add New Assignment", style: TextStyle(fontSize: context.font(20))),
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
                        title: 'Assignment Details',
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              hintText: 'Enter assignment title',
                              prefixIcon: const Icon(Icons.assignment),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(context.sm),
                              ),
                            ),
                            validator: (value) => (value == null || value.isEmpty) ? 'Please enter a title' : null,
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
                          _buildSubjectDropdown(),
                          SizedBox(height: context.md),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              hintText: 'Enter assignment instructions...',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(context.sm),
                              ),
                            ),
                            maxLines: 4,
                            validator: (value) => (value == null || value.isEmpty) ? 'Please enter a description' : null,
                          ),
                        ],
                      ),
                      SizedBox(height: context.lg),
                      _buildFormSection(
                        title: 'Deadlines & Attachments',
                        children: [
                          LayoutBuilder(builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              return Row(
                                children: [
                                  Expanded(child: _buildDatePicker()),
                                  SizedBox(width: context.md),
                                  Expanded(child: _buildFilePicker()),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                _buildDatePicker(),
                                SizedBox(height: context.md),
                                _buildFilePicker(),
                              ],
                            );
                          }),
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
      value: _selectedClassId,
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
      key: ValueKey('section_$_selectedClassId'),
      value: _selectedSectionId,
      items: _sections.map<DropdownMenuItem<int>>((s) => DropdownMenuItem(value: s['id'], child: Text(s['name'] ?? ''))).toList(),
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

  Widget _buildSubjectDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedSubjectId,
      items: _subjects.map<DropdownMenuItem<int>>((s) => DropdownMenuItem(value: s['id'], child: Text(s['name'] ?? ''))).toList(),
      onChanged: (value) => setState(() => _selectedSubjectId = value),
      decoration: InputDecoration(
        labelText: 'Subject',
        prefixIcon: const Icon(Icons.book),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.sm),
        ),
      ),
      validator: (value) => value == null ? 'Please select a subject' : null,
    );
  }

  Widget _buildDatePicker() {
    final theme = context.theme;
    return InkWell(
      onTap: _selectDueDate,
      borderRadius: BorderRadius.circular(context.sm),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.md),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(context.sm),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: theme.colorScheme.primary),
            SizedBox(width: context.md),
            Expanded(
              child: Text(
                _dueDate == null ? 'Select Due Date' : DateFormat('yyyy-MM-dd').format(_dueDate!),
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    final theme = context.theme;
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(context.sm),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(context.sm),
        ),
        child: Row(
          children: [
            Icon(Icons.attach_file, size: 20, color: theme.colorScheme.primary),
            SizedBox(width: context.md),
            Expanded(
              child: Text(
                _selectedFile?.name ?? 'Attach File',
                style: theme.textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
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
              onPressed: _isSaving ? null : _saveAssignment,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
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
                  : const Text('Save Assignment'),
            ),
          ],
        ),
      ),
    );
  }
}
