import 'dart:io';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/view_schedule_model.dart';
import 'common_widgets.dart';
import 'app_drawer.dart';

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
  
  File? _selectedFile; // For Mobile
  Uint8List? _webFileBytes; // For Web
  String? _fileName;
  
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

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null && _webFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a file")));
      return;
    }
    if (_selectedSchedule == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a schedule")));
      return;
    }

    setState(() => _isUploading = true);
    try {
      if (kIsWeb) {
        await ApiService.uploadStudyMaterialFromBytes(
          _selectedSchedule!.id,
          titleController.text,
          descController.text,
          _webFileBytes!,
          _fileName!,
        );
      } else {
        await ApiService.uploadStudyMaterial(
          _selectedSchedule!.id,
          titleController.text,
          descController.text,
          _selectedFile!,
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Material Uploaded Successfully")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e"), backgroundColor: const Color(0xFFEF4444)));
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
      drawer: const AppDrawer(),
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
                constraints: const BoxConstraints(maxWidth: 800),
                child: Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.scale(16)),
                    side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(context.spacing),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildLabel(context, "Select Class/Subject *"),
                          SizedBox(height: context.scale(8)),
                          buildDropdown(
                            context,
                            data.schedules.map((s) {
                              final sub = data.subjects.firstWhere((sub) => sub.id == s.subjectId).name;
                              final cls = data.classes.firstWhere((c) => c.id == s.classId).name;
                              return "$sub - $cls (${s.weekday})";
                            }).toList(),
                            _selectedSchedule == null
                                ? null
                                : (() {
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
                            hint: "Select Schedule",
                          ),
                          SizedBox(height: context.spacing),
                          buildLabel(context, "Title *"),
                          SizedBox(height: context.scale(8)),
                          buildTextField(context, titleController, "Enter title"),
                          SizedBox(height: context.spacing),
                          buildLabel(context, "Description"),
                          SizedBox(height: context.scale(8)),
                          buildTextField(context, descController, "Enter description (optional)", maxLines: 4),
                          SizedBox(height: context.spacing),
                          buildLabel(context, "Upload File *"),
                          SizedBox(height: context.scale(8)),
                          InkWell(
                            onTap: _pickFile,
                            borderRadius: BorderRadius.circular(context.scale(12)),
                            child: Container(
                              height: context.scale(56),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(context.scale(12)),
                                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: context.scale(120),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(context.scale(12)),
                                        bottomLeft: Radius.circular(context.scale(12)),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Choose File",
                                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: context.font(13)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: context.scale(12)),
                                      child: Text(
                                        _fileName ?? "No file chosen",
                                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(13)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: context.scale(8)),
                          Text(
                            "Allowed: PDF, Word, PPT, Images. Max: 20 MB.",
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11)),
                          ),
                          SizedBox(height: context.scale(32)),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isUploading ? null : _handleUpload,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                  ),
                                  child: _isUploading
                                      ? SizedBox(
                                          height: context.scale(20),
                                          width: context.scale(20),
                                          child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                                        )
                                      : Text("UPLOAD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
                                ),
                              ),
                              SizedBox(width: context.scale(12)),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                    side: BorderSide(color: colorScheme.outline),
                                  ),
                                  child: Text("CANCEL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
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
        },
      ),
    );
  }
}
