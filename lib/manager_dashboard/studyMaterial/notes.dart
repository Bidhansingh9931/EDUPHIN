import 'dart:convert';
import 'package:eduphin/manager_dashboard/studyMaterial/add_note.dart';
import 'package:eduphin/manager_dashboard/studyMaterial/edit_note.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Data model for Study Material
class StudyMaterial {
  final int id;
  final String title;
  final String description;
  final String className; // "class" is a reserved keyword in Dart
  final String section;
  final String uploadedBy;
  final String date;

  StudyMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.className,
    required this.section,
    required this.uploadedBy,
    required this.date,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json, Map<int, String> classMap, Map<int, String> sectionMap, Map<int, String> teacherMap) {
    return StudyMaterial(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'N/A',
      description: json['description'] ?? '',
      className: classMap[json['class_id']] ?? 'N/A',
      section: sectionMap[json['section_id']] ?? 'N/A',
      uploadedBy: teacherMap[json['user_id']] ?? 'N/A',
      date: json['created_at'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(json['created_at'])) : 'N/A',
    );
  }
}

class ApiClass {
  final int id;
  final String name;
  ApiClass({required this.id, required this.name});

  factory ApiClass.fromJson(Map<String, dynamic> json) {
    return ApiClass(id: json['id'], name: json['name']);
  }
}

class ApiSection {
  final int id;
  final String name;
  ApiSection({required this.id, required this.name});

  factory ApiSection.fromJson(Map<String, dynamic> json) {
    return ApiSection(id: json['id'], name: json['section_name']);
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String? selectedClass;
  String? selectedSection;

  List<ApiClass> classes = [];
  List<ApiSection> sections = [];
  List<StudyMaterial> allMaterials = [];
  List<StudyMaterial> filteredMaterials = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.get('manager/study/notes');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body)['data'];

        final List<ApiClass> fetchedClasses = (responseData['classes'] as List)
            .map((data) => ApiClass.fromJson(data))
            .toList();
        final List<ApiSection> fetchedSections = (responseData['sections'] as List)
            .map((data) => ApiSection.fromJson(data))
            .toList();

        final classMap = {for (var e in fetchedClasses) e.id: e.name};
        final sectionMap = {for (var e in fetchedSections) e.id: e.name};

        final teachers = responseData['teachers'] as List;
        final Map<int, String> teacherMap = {for (var t in teachers) t['id']: t['name'] ?? 'N/A'};

        final List<StudyMaterial> fetchedMaterials = (responseData['study_materials'] as List)
            .map((data) => StudyMaterial.fromJson(data, classMap, sectionMap, teacherMap))
            .toList();

        if (mounted) {
          setState(() {
            classes = fetchedClasses;
            sections = fetchedSections;
            allMaterials = fetchedMaterials;
            if (classes.isNotEmpty) {
              selectedClass = classes.first.name;
            }
            if (sections.isNotEmpty) {
              selectedSection = sections.first.name;
            }
            _filterMaterials();
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching data: $e')),
        );
      }
    }
  }

  void _filterMaterials() {
    setState(() {
      filteredMaterials = allMaterials.where((material) {
        final matchClass = selectedClass == null || material.className == selectedClass;
        final matchSection = selectedSection == null || material.section == selectedSection;
        return matchClass && matchSection;
      }).toList();
    });
  }

  Future<void> _deleteNote(int noteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await ApiService.delete('manager/study/notes/$noteId');
        if (response.statusCode == 200) {
          if(mounted){
            final theme = Theme.of(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Note deleted successfully'), backgroundColor: theme.colorScheme.primary));
            _fetchData(); // Refresh list
          }
        } else {
          throw Exception('Failed to delete note');
        }
      } catch (e) {
        if(mounted){
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
        title: Text(
          "Study Material List",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNotePage()));
          if (result == true) {
            _fetchData(); // Refresh list
          }
        },
        label: const Text('Create New'),
        icon: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildFilterSection(theme),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return _buildGridView();
                      } else {
                        return _buildListView();
                      }
                    }),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(theme, "Select Class *", selectedClass, classes.map((c) => c.name).toSet().toList(), (v) {
              if (v != null) {
                setState(() {
                  selectedClass = v;
                  // Fix: Reset section when class changes to prevent state inconsistency
                  selectedSection = null;
                  _filterMaterials();
                });
              }
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdown(theme, "Select Section *", selectedSection, sections.map((s) => s.name).toSet().toList(), (v) {
              if (v != null) {
                setState(() {
                  selectedSection = v;
                  _filterMaterials();
                });
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme, String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    // Defensive guard to prevent crash if value is not in items
    final uniqueItems = items.toSet().toList();
    final isValueValid = value == null || uniqueItems.contains(value);
    final String? dropdownValue = isValueValid ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          isExpanded: true, // Fix for overflow
          value: dropdownValue, // Use the validated value
          dropdownColor: theme.cardColor,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          items: uniqueItems.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildListView() {
    return filteredMaterials.isNotEmpty
        ? ListView.separated(
            padding: const EdgeInsets.only(bottom: 80), // Adjusted for FAB
            itemCount: filteredMaterials.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _StudyMaterialCard(material: filteredMaterials[index], onDelete: () => _deleteNote(filteredMaterials[index].id), onEdit: () async {
                 final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditNotePage(material: filteredMaterials[index])));
                 if(result == true) {
                    _fetchData();
                 }
            }),
          )
        : const Center(
            child: Text("No study material found for the selected filters."),
          );
  }

  Widget _buildGridView() {
    return filteredMaterials.isNotEmpty
        ? GridView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Adjusted for FAB
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.8, // Adjust this for card height
            ),
            itemCount: filteredMaterials.length,
            itemBuilder: (context, index) => _StudyMaterialCard(material: filteredMaterials[index], onDelete: () => _deleteNote(filteredMaterials[index].id), onEdit: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditNotePage(material: filteredMaterials[index])));
                 if(result == true) {
                    _fetchData();
                 }
            }),
          )
        : const Center(
            child: Text("No study material found for the selected filters."),
          );
  }
}

class _StudyMaterialCard extends StatelessWidget {
  final StudyMaterial material;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StudyMaterialCard({required this.material, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${material.className} - ${material.section}",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(icon: Icon(Icons.edit, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)), onPressed: onEdit, constraints: const BoxConstraints()),
                  IconButton(icon: Icon(Icons.delete, size: 20, color: theme.colorScheme.error), onPressed: onDelete, constraints: const BoxConstraints()),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            material.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Uploaded by: ${material.uploadedBy} on ${material.date}",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
