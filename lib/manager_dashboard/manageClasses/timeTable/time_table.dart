import 'dart:convert';

import 'package:eduphin/manager_dashboard/manageClasses/timeTable/show_schedule.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
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
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Time Table", style: theme.textTheme.titleLarge?.copyWith(fontSize: context.font(18), fontWeight: FontWeight.bold)),
            Text("Manage and view class schedules", style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11))),
          ],
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: _isLoading
          ? null
          : SafeArea(
              child: Container(
                padding: EdgeInsets.fromLTRB(context.spacing, context.scale(8), context.spacing, context.scale(16)),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: buildActionButton(context, "SHOW SCHEDULE", _showSchedule),
                ),
              ),
            ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : SingleChildScrollView(
              padding: context.pagePadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddNewSchedulePage()),
                              );
                              if (result == true) {
                                _fetchDropdownData();
                              }
                            },
                            icon: Icon(Icons.add, size: context.scale(20)),
                            label: Text("ADD NEW SCHEDULE", style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                              foregroundColor: theme.colorScheme.primary,
                              side: BorderSide(color: theme.colorScheme.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                            ),
                          ),
                        ),
                        SizedBox(height: context.scale(32)),
                        Text(
                          "View Schedule",
                          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(18)),
                        ),
                        SizedBox(height: context.scale(4)),
                        Text(
                          "Select Class and Section to view Time Table",
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11)),
                        ),
                        SizedBox(height: context.scale(24)),
                        buildFilterCard(
                          context,
                          children: [
                            buildLabel(context, "Class"),
                            buildDropdown(
                              context,
                              _classList.map((c) => c.name).toList(),
                              _classList.any((c) => c.id == _selectedClassId) ? _classList.firstWhere((c) => c.id == _selectedClassId).name : null,
                              (value) {
                                if (value == null) return;
                                setState(() {
                                  final selectedClass = _classList.firstWhere((c) => c.name == value);
                                  _selectedClassId = selectedClass.id;
                                  _sectionsForSelectedClass = selectedClass.sections;
                                  _selectedSectionId = _sectionsForSelectedClass.isNotEmpty ? _sectionsForSelectedClass.first.id : null;
                                });
                              },
                              hint: "Select Class",
                            ),
                            SizedBox(height: context.scale(16)),
                            buildLabel(context, "Section"),
                            buildDropdown(
                              context,
                              _sectionsForSelectedClass.map((s) => s.sectionName).toList(),
                              _sectionsForSelectedClass.any((s) => s.id == _selectedSectionId) ? _sectionsForSelectedClass.firstWhere((s) => s.id == _selectedSectionId).sectionName : null,
                              (value) {
                                if (value == null) return;
                                setState(() {
                                  _selectedSectionId = _sectionsForSelectedClass.firstWhere((s) => s.sectionName == value).id;
                                });
                              },
                              hint: "Select Section",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }


}
