import 'dart:io';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
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
      // Convert DD-MM-YYYY to YYYY-MM-DD
      final formattedDate = "${dateParts[2]}-${dateParts[1]}-${dateParts[0]}";

      // Backend validation: due_date must be AFTER today.
      final selectedDate = DateTime.parse(formattedDate);
      final today = DateTime.now();
      final todayAtMidnight = DateTime(today.year, today.month, today.day);
      
      if (!selectedDate.isAfter(todayAtMidnight)) {
        throw "Due date must be at least tomorrow.";
      }

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
    final theme = context.theme;
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

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.scale(800)),
              child: SingleChildScrollView(
                padding: context.pagePadding,
                child: Form(
                  key: _formKey,
                  child: Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(16)),
                      side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.spacing * 1.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildLabel(context, "Select Class/Subject *"),
                          buildDropdown<AssignmentSchedule>(
                            context,
                            schedules,
                            _selectedSchedule,
                            (val) {
                              setState(() {
                                _selectedSchedule = val;
                              });
                            },
                            hint: "Select Schedule",
                            itemBuilder: (s) => '${s.subjectName} - ${s.className} (${s.sectionName})',
                          ),
                          SizedBox(height: context.spacing),
                          buildLabel(context, "Assignment Title *"),
                          buildTextField(context, _titleController, "Enter title", prefixIcon: Icons.title_rounded),
                          SizedBox(height: context.spacing),
                          buildLabel(context, "Description"),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)),
                            decoration: InputDecoration(
                              hintText: "Enter detailed instructions",
                              contentPadding: EdgeInsets.all(context.spacing),
                              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(context.scale(12)),
                                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(context.scale(12)),
                                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(context.scale(12)),
                                borderSide: BorderSide(color: theme.colorScheme.primary),
                              ),
                            ),
                          ),
                          SizedBox(height: context.spacing),
                          buildLabel(context, "Due Date *"),
                          buildDateField(context, _dateController, "DD-MM-YYYY"),
                          SizedBox(height: context.spacing),
                          buildLabel(context, "Attachment *"),
                          _buildFilePicker(),
                          SizedBox(height: context.scale(32)),
                          buildActionButton(
                            context,
                            _isSubmitting ? "CREATING..." : "CREATE ASSIGNMENT",
                            _isSubmitting ? () {} : _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilePicker() {
    final theme = context.theme;
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(context.scale(12)),
      child: Container(
        padding: EdgeInsets.all(context.spacing),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(context.scale(12)),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.scale(8)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(context.scale(8)),
              ),
              child: Icon(Icons.upload_file_rounded, color: theme.colorScheme.primary, size: context.scale(20)),
            ),
            SizedBox(width: context.scale(16)),
            Expanded(
              child: Text(
                _fileName ?? "Choose File (PDF, Images, etc.)",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _fileName == null ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                  fontSize: context.font(14),
                  fontWeight: _fileName == null ? FontWeight.normal : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_fileName != null)
              Icon(Icons.check_circle, color: const Color(0xFF10B981), size: context.scale(20)), // Emerald
          ],
        ),
      ),
    );
  }
}
