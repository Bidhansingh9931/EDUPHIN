import 'dart:io';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/teacher_dashboard_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'common_widgets.dart';

class CreateAssignmentPage extends StatefulWidget {
  const CreateAssignmentPage({super.key});

  @override
  State<CreateAssignmentPage> createState() => _CreateAssignmentPageState();
}

class _CreateAssignmentPageState extends State<CreateAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  
  late Future<AssignmentPageData> _dataFuture;
  AssignmentSchedule? _selectedSchedule;
  
  // New state variables for cross-platform support
  File? _selectedFile; // For Mobile
  Uint8List? _webFileBytes; // For Web
  String? _fileName;
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = ApiService.getAssignmentsPageData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        if (kIsWeb) {
          _webFileBytes = result.files.single.bytes;
        } else {
          _selectedFile = File(result.files.single.path!);
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null && _webFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an attachment")),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final dateParts = _dateController.text.split('-');
      final formattedDate = "${dateParts[2]}-${dateParts[1]}-${dateParts[0]}";

      if (kIsWeb) {
        await ApiService.createAssignmentFromBytes(
          _selectedSchedule!.id,
          _titleController.text,
          _descriptionController.text,
          formattedDate,
          _webFileBytes!,
          _fileName!,
        );
      } else {
        await ApiService.createAssignment(
          _selectedSchedule!.id,
          _titleController.text,
          _descriptionController.text,
          formattedDate,
          _selectedFile!,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Assignment created successfully!")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Assignment")),
      body: FutureBuilder<AssignmentPageData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data found"));
          }

          final schedules = snapshot.data!.schedules;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Select Class/Subject *"),
                  buildDropdown(
                    context,
                    schedules.map((s) => '${s.subjectName} - ${s.className} (${s.sectionName})').toList(),
                    _selectedSchedule == null ? null : '${_selectedSchedule!.subjectName} - ${_selectedSchedule!.className} (${_selectedSchedule!.sectionName})',
                    (val) {
                      setState(() {
                        _selectedSchedule = schedules.firstWhere((s) => '${s.subjectName} - ${s.className} (${s.sectionName})' == val);
                      });
                    },
                    hint: "Select Schedule",
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Assignment Title *"),
                  buildTextField(context, _titleController, "Enter title"),
                  const SizedBox(height: 20),
                  _buildLabel("Description"),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: "Enter detailed instructions"),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Due Date *"),
                  buildDateField(context, _dateController, "DD-MM-YYYY"),
                  const SizedBox(height: 20),
                  _buildLabel("Attachment *"),
                  _buildFilePicker(),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("CREATE ASSIGNMENT"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFilePicker() {
    final theme = Theme.of(context);
    return InkWell(
      onTap: _pickFile,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.upload_file, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _fileName ?? "Choose File (PDF, Images, etc.)",
                style: TextStyle(color: _fileName == null ? theme.hintColor : theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
