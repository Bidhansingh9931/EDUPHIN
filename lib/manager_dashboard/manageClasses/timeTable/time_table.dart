import 'dart:convert';

import 'package:eduphin/manager_dashboard/manageClasses/timeTable/show_schedule.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/caching_service.dart';
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
  Object? _error;
  static const String _cacheKey = 'manager_classes_dropdown';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchDropdownData();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CacheService.getCache(_cacheKey);
    if (cachedData != null && mounted) {
      _processClassData(cachedData);
    }
  }

  void _processClassData(dynamic data) {
    final List<dynamic> classData = data;
    final List<Class> fetchedClasses = classData.map((json) => Class.fromJson(json)).toList();

    setState(() {
      _classList = fetchedClasses;
      if (_classList.isNotEmpty) {
        if (_selectedClassId == null || !_classList.any((c) => c.id == _selectedClassId)) {
          _selectedClassId = _classList.first.id;
          _sectionsForSelectedClass = _classList.first.sections;
          _selectedSectionId = _sectionsForSelectedClass.isNotEmpty ? _sectionsForSelectedClass.first.id : null;
        } else {
          _sectionsForSelectedClass = _classList.firstWhere((c) => c.id == _selectedClassId).sections;
          if (_selectedSectionId == null || !_sectionsForSelectedClass.any((s) => s.id == _selectedSectionId)) {
             _selectedSectionId = _sectionsForSelectedClass.isNotEmpty ? _sectionsForSelectedClass.first.id : null;
          }
        }
      }
    });
  }

  Future<void> _fetchDropdownData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await ApiService.get('manager/classes');
      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          await CacheService.setCache(_cacheKey, data['data']);
          _processClassData(data['data']);
          setState(() {
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load class data');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
        ErrorHandler.showError(context, e);
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
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _classList.isNotEmpty,
        error: _error,
        onRetry: _fetchDropdownData,
        skeleton: _buildSkeleton(),
        child: SingleChildScrollView(
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
      ),
    );
  }

  Widget buildLabel(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(8)),
      child: Text(text, style: TextStyle(color: context.theme.colorScheme.onSurfaceVariant, fontSize: context.font(12), fontWeight: FontWeight.bold)),
    );
  }

  Widget buildDropdown(BuildContext context, List<String> items, String? value, ValueChanged<String?> onChanged, {String? hint}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(12)),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(context.scale(12)),
        border: Border.all(color: context.theme.colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: hint != null ? Text(hint, style: TextStyle(color: context.theme.hintColor, fontSize: context.font(14))) : null,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(fontSize: context.font(14))),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget buildFilterCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scale(20)),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: context.theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget buildActionButton(BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: context.scale(54),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(14))),
          elevation: 0,
        ),
        child: Text(label, style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(height: context.scale(48), width: double.infinity, borderRadius: context.scale(12)),
              SizedBox(height: context.scale(32)),
              SkeletonBox(height: context.scale(24), width: context.scale(150)),
              SizedBox(height: context.scale(8)),
              SkeletonBox(height: context.scale(14), width: context.scale(250)),
              SizedBox(height: context.scale(24)),
              Container(
                padding: EdgeInsets.all(context.scale(20)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.scale(16)),
                  border: Border.all(color: context.theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(height: context.scale(14), width: context.scale(40)),
                    SizedBox(height: context.scale(8)),
                    SkeletonBox(height: context.scale(48), width: double.infinity, borderRadius: context.scale(8)),
                    SizedBox(height: context.scale(16)),
                    SkeletonBox(height: context.scale(14), width: context.scale(50)),
                    SizedBox(height: context.scale(8)),
                    SkeletonBox(height: context.scale(48), width: double.infinity, borderRadius: context.scale(8)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

