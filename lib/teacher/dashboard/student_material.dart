import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/study_material_model.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'common_widgets.dart';
import 'app_drawer.dart';
import 'package:shimmer/shimmer.dart';

class StudentMaterialPage extends StatefulWidget {
  const StudentMaterialPage({super.key});

  @override
  State<StudentMaterialPage> createState() => _StudentMaterialPageState();
}

class _StudentMaterialPageState extends State<StudentMaterialPage> {
  bool _isLoading = true;
  StudyMaterialPageData? _data;
  String? _error;
  ScheduleInfo? _selectedSchedule;
  List<StudyMaterialInfo> _filteredMaterials = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Load from cache
    final cachedData = await TeacherCacheService.load('student_materials');
    if (cachedData != null) {
      if (mounted) {
        setState(() {
          _data = StudyMaterialPageData.fromJson(cachedData);
          _isLoading = false;
          if (_selectedSchedule != null) {
            _filterMaterials(_data!.studyMaterials);
          }
        });
      }
    }

    // 2. Fetch from API
    try {
      final freshData = await ApiService.getStudyMaterialsData();
      await TeacherCacheService.save('student_materials', freshData.toJson());
      
      if (mounted) {
        setState(() {
          _data = freshData;
          _isLoading = false;
          _error = null;
          if (_selectedSchedule != null) {
            // Find the updated version of the selected schedule if possible
            try {
              _selectedSchedule = freshData.schedules.firstWhere(
                (s) => s.classId == _selectedSchedule!.classId && 
                       s.sectionId == _selectedSchedule!.sectionId && 
                       s.subjectId == _selectedSchedule!.subjectId
              );
            } catch (_) {}
            _filterMaterials(freshData.studyMaterials);
          }
        });
      }
    } catch (e) {
      if (_data == null && mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
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
        final theme = context.theme;
        final colorScheme = theme.colorScheme;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              title: Text('Upload New Material', style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(20))),
              content: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.scale(400)),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Title *", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                      SizedBox(height: context.scale(8)),
                      buildTextField(context, titleController, 'Enter title'),
                      SizedBox(height: context.scale(16)),
                      Text("Description", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                      SizedBox(height: context.scale(8)),
                      buildTextField(context, descriptionController, 'Enter description', maxLines: 3),
                      SizedBox(height: context.scale(20)),
                      InkWell(
                        onTap: () async {
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
                        borderRadius: BorderRadius.circular(context.scale(12)),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(16)),
                          decoration: BoxDecoration(
                            border: Border.all(color: colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(context.scale(12)),
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: context.scale(20), color: colorScheme.primary),
                              SizedBox(width: context.scale(12)),
                              Expanded(
                                child: Text(
                                  fileName ?? 'Click to select file',
                                  style: TextStyle(fontSize: context.font(14), color: fileName != null ? colorScheme.onSurface : colorScheme.onSurfaceVariant),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant),
                  child: Text('Cancel', style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.w600)),
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
                          _loadData();
                        }
                      } catch (e) {
                        if (mounted) {
                          Navigator.of(context).pop();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Upload failed: $e'), backgroundColor: colorScheme.error),
                            );
                          }
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(horizontal: context.scale(24), vertical: context.scale(12)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(8))),
                  ),
                  child: Text('Upload', style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
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
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.auto_stories_outlined, size: context.scale(20), color: theme.colorScheme.primary),
            SizedBox(width: context.scale(12)),
            Text(
              "Study Materials",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.font(18),
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final theme = context.theme;
    if (_isLoading && _data == null) {
      return _buildSkeletonLoader(context);
    }

    if (_error != null && _data == null) {
      return Center(child: Text('Error: $_error', style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.error)));
    }

    if (_data == null) {
      return Center(child: Text('No data', style: TextStyle(fontSize: context.font(14))));
    }

    final pageData = _data!;
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.scale(16)),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(context.spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Class Schedule",
                        style: TextStyle(
                          fontSize: context.font(15),
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: context.scale(16)),
                      buildDropdown(context, pageData.schedules.map((e) => e.displayText).toList(), _selectedSchedule?.displayText, (newValue) {
                        setState(() {
                          _selectedSchedule = pageData.schedules.firstWhere((element) => element.displayText == newValue);
                          _filterMaterials(pageData.studyMaterials);
                        });
                      }, hint: "Select Schedule"),
                      SizedBox(height: context.scale(20)),
                      ElevatedButton.icon(
                        onPressed: _selectedSchedule != null ? _showUploadDialog : null,
                        icon: Icon(Icons.add, size: context.scale(18)),
                        label: Text("UPLOAD NEW MATERIAL", style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          minimumSize: Size(double.infinity, context.scale(48)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.spacing),
              _buildMaterialSection(context),
              SizedBox(height: context.spacing * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialSection(BuildContext context) {
    final theme = context.theme;
    if (_selectedSchedule == null) {
      return Padding(
        padding: EdgeInsets.all(context.scale(40.0)),
        child: Column(
          children: [
            Icon(Icons.auto_stories_outlined, size: context.scale(80), color: theme.colorScheme.outlineVariant),
            SizedBox(height: context.scale(20)),
            Text("Select a schedule to view materials.", textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.outline, fontSize: context.font(14))),
          ],
        ),
      );
    }

    if (_filteredMaterials.isEmpty) {
      return Center(child: Padding(padding: EdgeInsets.all(context.scale(24)), child: Text('No materials found for this selection.', style: TextStyle(color: theme.colorScheme.outline, fontSize: context.font(14)))));
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredMaterials.length,
      itemBuilder: (context, index) {
        final material = _filteredMaterials[index];
        return Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          margin: EdgeInsets.only(bottom: context.scale(12)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.scale(12)),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(8)),
            leading: Container(
              padding: EdgeInsets.all(context.scale(10)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.description_outlined, color: theme.colorScheme.primary, size: context.scale(20)),
            ),
            title: Text(
              material.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.font(14),
                color: theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: context.scale(4)),
              child: Text(
                material.description ?? 'No description',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: context.font(12),
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline_rounded, size: context.scale(20)),
              color: theme.colorScheme.error.withValues(alpha: 0.8),
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
      builder: (context) {
        final theme = context.theme;
        final colorScheme = theme.colorScheme;
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: Text('Delete Material', style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          content: Text('Are you sure you want to delete this study material?', style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurfaceVariant)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(20))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant),
              child: Text('Cancel', style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(10)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(8))),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context, true), 
              child: Text('Delete', style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold))),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteStudyMaterial(id);
        _loadData();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    final theme = context.theme;
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      highlightColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
      child: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Container(
                  height: context.scale(180),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(context.scale(16)),
                  ),
                ),
                SizedBox(height: context.spacing),
                ...List.generate(5, (index) => Padding(
                  padding: EdgeInsets.only(bottom: context.scale(12)),
                  child: Container(
                    height: context.scale(80),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(context.scale(12)),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
