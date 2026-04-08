import 'dart:typed_data';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/study_material_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'common_widgets.dart';

class StudentMaterialPage extends StatefulWidget {
  const StudentMaterialPage({super.key});

  @override
  State<StudentMaterialPage> createState() => _StudentMaterialPageState();
}

class _StudentMaterialPageState extends State<StudentMaterialPage> {
  late Future<StudyMaterialPageData> _dataFuture;
  ScheduleInfo? _selectedSchedule;
  List<StudyMaterialInfo> _filteredMaterials = [];

  @override
  void initState() {
    super.initState();
    _dataFuture = ApiService.getStudyMaterialsData();
  }

  void _filterMaterials(List<StudyMaterialInfo> allMaterials) {
    if (_selectedSchedule == null) {
      _filteredMaterials = [];
    } else {
      _filteredMaterials = allMaterials
          .where((material) =>
              material.classId == _selectedSchedule!.classId &&
              material.sectionId == _selectedSchedule!.sectionId &&
              material.subjectId == _selectedSchedule!.subjectId)
          .toList();
    }
    if (mounted) setState(() {});
  }

  void _showUploadDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    File? selectedFile;
    String? fileName;
    Uint8List? selectedFileBytes;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Upload New Material'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildTextField(context, titleController, 'Title'),
                    const SizedBox(height: 16),
                    buildTextField(context, descriptionController, 'Description'),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
                        if (result != null) {
                          setDialogState(() {
                            if (kIsWeb) {
                              selectedFileBytes = result.files.single.bytes;
                            } else {
                              selectedFile = File(result.files.single.path!);
                            }
                            fileName = result.files.single.name;
                          });
                        }
                      },
                      icon: const Icon(Icons.attach_file),
                      label: Text(fileName ?? 'Select File'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedSchedule != null &&
                        titleController.text.isNotEmpty &&
                        (selectedFile != null || selectedFileBytes != null)) {
                      try {
                        if (kIsWeb) {
                          await ApiService.uploadStudyMaterialFromBytes(
                            _selectedSchedule!.id,
                            titleController.text,
                            descriptionController.text,
                            selectedFileBytes!,
                            fileName!,
                          );
                        } else {
                          await ApiService.uploadStudyMaterial(
                            _selectedSchedule!.id,
                            titleController.text,
                            descriptionController.text,
                            selectedFile!,
                          );
                        }
                        
                        if (mounted) {
                          Navigator.of(context).pop();
                          // Use outer setState to refresh the whole page
                          this.setState(() {
                            _dataFuture = ApiService.getStudyMaterialsData();
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                    }
                  },
                  child: const Text('Upload'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Study Materials"),
      ),
      body: FutureBuilder<StudyMaterialPageData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final pageData = snapshot.data!;
            
            // Auto-refresh filtered list if a schedule is already selected
            if (_selectedSchedule != null) {
               _filteredMaterials = pageData.studyMaterials
                  .where((material) =>
                      material.classId == _selectedSchedule!.classId &&
                      material.sectionId == _selectedSchedule!.sectionId &&
                      material.subjectId == _selectedSchedule!.subjectId)
                  .toList();
            }

            return SingleChildScrollView(
              padding: context.pagePadding,
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildLabel(context, "Select Class Schedule"),
                          const SizedBox(height: 12),
                          buildDropdown(context, pageData.schedules.map((e) => e.displayText).toList(), _selectedSchedule?.displayText, (newValue) {
                             setState(() {
                              _selectedSchedule = pageData.schedules.firstWhere((element) => element.displayText == newValue);
                              _filterMaterials(pageData.studyMaterials);
                            });
                          }),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _selectedSchedule != null ? _showUploadDialog : null,
                            icon: const Icon(Icons.add),
                            label: const Text("UPLOAD NEW MATERIAL"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildMaterialSection(context),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }

  Widget _buildMaterialSection(BuildContext context) {
    final theme = Theme.of(context);
    if (_selectedSchedule == null) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.auto_stories_outlined, size: 80, color: theme.hintColor.withOpacity(0.3)),
            const SizedBox(height: 20),
            Text("Select a schedule to view materials.", textAlign: TextAlign.center, style: TextStyle(color: theme.hintColor)),
          ],
        ),
      );
    }

    if (_filteredMaterials.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('No materials found for this selection.', style: TextStyle(color: theme.hintColor))));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredMaterials.length,
      itemBuilder: (context, index) {
        final material = _filteredMaterials[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.description_outlined, color: theme.colorScheme.primary),
            ),
            title: Text(material.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(material.description ?? 'No description', maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              color: theme.colorScheme.error,
              onPressed: () => _deleteMaterial(material.id),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteMaterial(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: const Text('Are you sure you want to delete this study material?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteStudyMaterial(id);
        setState(() {
          _dataFuture = ApiService.getStudyMaterialsData();
        });
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
