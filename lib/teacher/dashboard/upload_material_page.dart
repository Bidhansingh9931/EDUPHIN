import 'dart:io';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/view_schedule_model.dart';
import 'common_widgets.dart';

class UploadAssignmentPage extends StatefulWidget {
  const UploadAssignmentPage({super.key});

  @override
  State<UploadAssignmentPage> createState() => _UploadAssignmentPageState();
}

class _UploadAssignmentPageState extends State<UploadAssignmentPage> {
  final _formKey = GlobalKey<FormState>();

  late Future<ViewSchedulePageData> _dataFuture;
  ScheduleEntry? _selectedSchedule;
  final titleController = TextEditingController();
  final descController = TextEditingController();
  File? _selectedFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = ApiService.getViewSchedulePageData();
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a file")));
      return;
    }
    if (_selectedSchedule == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a schedule")));
      return;
    }

    setState(() => _isUploading = true);
    try {
      await ApiService.uploadStudyMaterial(
        _selectedSchedule!.id,
        titleController.text,
        descController.text,
        _selectedFile!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Material Uploaded Successfully")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Material"),
      ),
      body: FutureBuilder<ViewSchedulePageData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No schedules found"));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Select Class/Subject *"),
                          const SizedBox(height: 10),
                          buildDropdown(
                            context, 
                            data.schedules.map((s) {
                              final sub = data.subjects.firstWhere((sub) => sub.id == s.subjectId).name;
                              final cls = data.classes.firstWhere((c) => c.id == s.classId).name;
                              return "$sub - $cls (${s.weekday})";
                            }).toList(), 
                            _selectedSchedule == null ? null : (() {
                              final s = _selectedSchedule!;
                              final sub = data.subjects.firstWhere((sub) => sub.id == s.subjectId).name;
                              final cls = data.classes.firstWhere((c) => c.id == s.classId).name;
                              return "$sub - $cls (${s.weekday})";
                            })(), 
                            (val) {
                              setState(() {
                                _selectedSchedule = data.schedules.firstWhere((s) {
                                  final sub = data.subjects.firstWhere((sub) => sub.id == s.subjectId).name;
                                  final cls = data.classes.firstWhere((c) => c.id == s.classId).name;
                                  return "$sub - $cls (${s.weekday})" == val;
                                });
                              });
                            },
                            hint: "Select Schedule"
                          ),

                          const SizedBox(height: 24),
                          _buildLabel("Title *"),
                          const SizedBox(height: 10),
                          buildTextField(context, titleController, "Enter title"),

                          const SizedBox(height: 24),
                          _buildLabel("Description"),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: descController,
                            maxLines: 4,
                            decoration: const InputDecoration(hintText: "Enter description (optional)"),
                          ),

                          const SizedBox(height: 24),
                          _buildLabel("Upload File *"),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: _pickFile,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text("Choose File",
                                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 12, right: 12),
                                      child: Text(
                                        _selectedFile == null ? "No file chosen" : _selectedFile!.path.split('/').last,
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Allowed: PDF, Word, PPT, Images. Max: 20 MB.",
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
                          ),

                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isUploading ? null : _handleUpload,
                                  child: _isUploading 
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text("UPLOAD"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("CANCEL"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold));
  }
}
