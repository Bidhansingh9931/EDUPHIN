import 'dart:convert';

import 'package:eduphin/manager_dashboard/manageClasses/timeTable/show_schedule.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

import 'add_new_schedule.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class Class {
  final int id;
  final String name;
  final List<Section> sections;

  Class({required this.id, required this.name, required this.sections});

  factory Class.fromJson(Map<String, dynamic> json) {
    var sectionsList = json['sections'] as List? ?? [];
    List<Section> sections = sectionsList.map((i) => Section.fromJson(i)).toList();
    return Class(id: json['id'], name: json['name'], sections: sections);
  }
}

class Section {
  final int id;
  final String sectionName;

  Section({required this.id, required this.sectionName});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(id: json['id'], sectionName: json['section_name']);
  }
}

// ───────────────────────────────────────────────────────────
//                       TIME TABLE PAGE
// ───────────────────────────────────────────────────────────

class TimeTableClassesPage extends StatefulWidget {
  const TimeTableClassesPage({super.key});

  @override
  State<StatefulWidget> createState() => _TimeTableClassesPageState();
}

class _TimeTableClassesPageState extends State<TimeTableClassesPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  int? _selectedClassId;
  int? _selectedSectionId;
  List<Class> _classList = [];
  List<Section> _sectionsForSelectedClass = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final response = await ApiService.get('manager/classes');
      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> classData = data['data'];
          final List<Class> fetchedClasses = classData.map((json) => Class.fromJson(json)).toList();

          setState(() {
            _classList = fetchedClasses;
            if (_classList.isNotEmpty) {
              _selectedClassId = _classList.first.id;
              _sectionsForSelectedClass = _classList.first.sections;
              if (_sectionsForSelectedClass.isNotEmpty) {
                _selectedSectionId = _sectionsForSelectedClass.first.id;
              }
            }
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load class data');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSchedule() {
    if (_formKey.currentState!.validate()) {
      final className = _classList.firstWhere((c) => c.id == _selectedClassId).name;
      final sectionName = _sectionsForSelectedClass.firstWhere((s) => s.id == _selectedSectionId).sectionName;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShowSchedulePage(
            className: className,
            section: sectionName,
            classId: _selectedClassId!,
            sectionId: _selectedSectionId!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Time Table"),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showSchedule,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Show Schedule"),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddNewSchedulePage()),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Add New Schedule"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              foregroundColor: theme.colorScheme.onSurface,
                              side: BorderSide(color: theme.dividerColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text("Select Class and Section to view Time Table", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          theme,
                          label: "Class",
                          value: _selectedClassId,
                          items: _classList.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedClassId = value;
                              _sectionsForSelectedClass = _classList.firstWhere((c) => c.id == value).sections;
                              _selectedSectionId = _sectionsForSelectedClass.isNotEmpty ? _sectionsForSelectedClass.first.id : null;
                            });
                          },
                          hint: "--Select Class",
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          theme,
                          label: "Section",
                          value: _selectedSectionId,
                          items: _sectionsForSelectedClass.map((s) => DropdownMenuItem(value: s.id, child: Text(s.sectionName))).toList(),
                          onChanged: (value) => setState(() => _selectedSectionId = value),
                          hint: "--Select Section",
                        ),
                        const SizedBox(height: 80), // Padding for FAB
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown<T>(
    ThemeData theme,
      {required String label,
      T? value,
      required List<DropdownMenuItem<T>> items,
      required ValueChanged<T?> onChanged,
      required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) => value == null ? 'Please make a selection' : null,
        ),
      ],
    );
  }
}
