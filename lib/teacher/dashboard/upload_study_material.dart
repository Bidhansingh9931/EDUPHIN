import 'dart:convert';
import 'dart:io';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'common_widgets.dart';

class Uploadstudymaterial extends StatefulWidget {
  const Uploadstudymaterial({super.key});

  @override
  State<Uploadstudymaterial> createState() => _UploadAssignmentPageState();
}

class _UploadAssignmentPageState extends State<Uploadstudymaterial> {
  final _formKey = GlobalKey<FormState>();

  List<dynamic> schedules = [];
  dynamic selectedSchedule;
  final titleController = TextEditingController();
  final descController = TextEditingController();

  File? selectedFile;
  Uint8List? selectedFileBytes;
  String? fileName;
  bool isLoading = false;
  bool isFetchingSchedules = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    try {
      final data = await ApiService.get('teacher/notes');
      if (data.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(data.body);
        setState(() {
          schedules = body['schedules'] ?? [];
          isFetchingSchedules = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
      setState(() => isFetchingSchedules = false);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'jpeg', 'png', 'mp4', 'avi', 'mkv'],
    );

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
        if (kIsWeb) {
          selectedFileBytes = result.files.single.bytes;
        } else {
          selectedFile = File(result.files.single.path!);
        }
      });
    }
  }

  Future<void> _uploadMaterial() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedSchedule == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a schedule")));
      return;
    }
    if (selectedFile == null && selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please choose a file")));
      return;
    }

    setState(() => isLoading = true);
    try {
      final int scheduleId = int.parse(selectedSchedule['id'].toString());
      final String title = titleController.text.trim();
      final String? description = descController.text.trim().isEmpty ? null : descController.text.trim();

      if (kIsWeb) {
        await ApiService.uploadStudyMaterialFromBytes(
          scheduleId,
          title,
          description,
          selectedFileBytes!,
          fileName!,
        );
      } else {
        await ApiService.uploadStudyMaterial(
          scheduleId,
          title,
          description,
          selectedFile!,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Material Uploaded Successfully")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Material"),
      ),
      body: isFetchingSchedules
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: context.scale(600)),
                  child: Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(16)),
                      side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.spacing * 1.5),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel(context, "Select Schedule *"),
                            buildDropdown(
                              context,
                              schedules,
                              selectedSchedule,
                              (value) {
                                setState(() {
                                  selectedSchedule = value;
                                });
                              },
                              hint: "Select Schedule",
                              itemBuilder: (item) {
                                final className = item['class']?['name'] ?? 'N/A';
                                final sectionName = item['section']?['name'] ?? 'N/A';
                                final subjectName = item['subject']?['name'] ?? 'N/A';
                                return "$className $sectionName - $subjectName";
                              },
                            ),

                            SizedBox(height: context.spacing),

                            buildLabel(context, "Title *"),
                            buildTextField(context, titleController, "Enter title"),

                            SizedBox(height: context.spacing),

                            buildLabel(context, "Description"),
                            TextFormField(
                              controller: descController,
                              maxLines: 4,
                              style: theme.textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: "Enter description (optional)",
                                contentPadding: EdgeInsets.all(context.spacing),
                              ),
                            ),

                            SizedBox(height: context.spacing),

                            buildLabel(context, "Upload File *"),
                            InkWell(
                              onTap: _pickFile,
                              borderRadius: BorderRadius.circular(context.scale(12)),
                              child: Container(
                                height: context.scale(56),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(context.scale(12)),
                                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
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
                                      child: Text("Choose File",
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: context.font(13)
                                          )),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 12),
                                        child: Text(
                                          fileName ?? "No file chosen",
                                          style: TextStyle(
                                            color: fileName != null ? theme.colorScheme.onSurface : Colors.grey,
                                            fontSize: 13,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: context.scale(8)),
                            Text(
                              "Allowed: PDF, Word, PPT, Images. Max: 20 MB.",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.hintColor,
                                fontSize: context.font(11),
                              ),
                            ),

                            SizedBox(height: context.scale(32)),

                            if (isLoading)
                              const Center(child: CircularProgressIndicator())
                            else
                              buildActionButton(
                                context,
                                "UPLOAD",
                                _uploadMaterial,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
