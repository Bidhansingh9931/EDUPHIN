import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:flutter/material.dart';

// ───────────────────────────────────────────────────────────
//                        DATA MODELS
// ───────────────────────────────────────────────────────────

class Class {
  final int id;
  final String name;
  final List<Section> sections;

  Class({required this.id, required this.name, required this.sections});

  factory Class.fromJson(Map<String, dynamic> json) {
    // Safely handle null 'sections' by providing an empty list as a fallback.
    var sectionsList = json['sections'] as List? ?? [];
    List<Section> sections = sectionsList.map((i) => Section.fromJson(i)).toList();
    return Class(id: json['id'], name: json['name'], sections: sections);
  }
}

class Section {
  final int id;
  final String name;

  Section({required this.id, required this.name});

  factory Section.fromJson(Map<String, dynamic> json) {
    // Corrected to use 'name' to be consistent with other data models.
    return Section(id: json['id'], name: json['name']);
  }
}

class Subject {
  final int id;
  final String name;
  Subject({required this.id, required this.name});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(id: json['id'], name: json['name']);
  }
}

class Teacher {
  final int id;
  final String name;
  Teacher({required this.id, required this.name});

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(id: json['id'], name: json['name']);
  }
}


// ───────────────────────────────────────────────────────────
//                       ADD SCHEDULE PAGE
// ───────────────────────────────────────────────────────────

class AddNewSchedulePage extends StatefulWidget {
  const AddNewSchedulePage({super.key});

  @override
  State<StatefulWidget> createState() => _AddNewSchedulePageState();
}

class _AddNewSchedulePageState extends State<AddNewSchedulePage> {
  final _formKey = GlobalKey<FormState>();

  // Loading states
  bool _isLoading = true;
  bool _isSaving = false;

  // Dropdown list data
  List<Class> _classList = [];
  List<Section> _sectionList = [];
  List<Subject> _subjectList = [];
  List<Teacher> _teacherList = [];
  final List<String> _weekdayList = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

  // Selected values
  int? _selectedClassId;
  int? _selectedSectionId;
  int? _selectedSubjectId;
  int? _selectedTeacherId;
  String? _selectedWeekday;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final response = await ApiService.get('manager/class-schedules/meta');
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _classList = (data['classes'] as List).map((i) => Class.fromJson(i)).toList();
          _subjectList = (data['subjects'] as List).map((i) => Subject.fromJson(i)).toList();
          _teacherList = (data['teachers'] as List).map((i) => Teacher.fromJson(i)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load dropdown data');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSchedule() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields before saving.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final body = {
        'class_id': _selectedClassId,
        'section_id': _selectedSectionId,
        'subject_id': _selectedSubjectId,
        'teacher_id': _selectedTeacherId,
        'day': _selectedWeekday,
        'start_time': '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
        'end_time': '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
      };

      final response = await ApiService.post('manager/class-schedules', body);
      if (!mounted) return;

      final responseData = jsonDecode(response.body);
      final theme = Theme.of(context);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Schedule added successfully!'), backgroundColor: theme.colorScheme.primary),
        );
        Navigator.of(context).pop();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to add schedule');
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst("Exception: ", "")), backgroundColor: theme.colorScheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectTime(BuildContext context, {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
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
            Text("Add New Schedule", style: theme.textTheme.titleLarge?.copyWith(fontSize: context.font(18), fontWeight: FontWeight.bold)),
            Text("Fill in the information below to add a new class schedule.", style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11))),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: buildActionButton(
                          context,
                          "Cancel",
                          () => Navigator.pop(context),
                          isPrimary: false,
                        ),
                      ),
                      SizedBox(width: context.spacing),
                      Expanded(
                        child: _isSaving
                            ? const Center(child: CircularProgressIndicator())
                            : buildActionButton(
                                context,
                                "Add Schedule",
                                _addSchedule,
                              ),
                      ),
                    ],
                  ),
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
                        Text(
                          "Schedule Details",
                          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(18)),
                        ),
                        SizedBox(height: context.scale(4)),
                        Text(
                          "Assign teacher and subject to class",
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
                                  _selectedSectionId = null;
                                  _sectionList = selectedClass.sections;
                                });
                              },
                              hint: "Select Class",
                            ),
                            buildLabel(context, "Section"),
                            buildDropdown(
                              context,
                              _sectionList.map((s) => s.name).toList(),
                              _sectionList.any((s) => s.id == _selectedSectionId) ? _sectionList.firstWhere((s) => s.id == _selectedSectionId).name : null,
                              (value) {
                                if (value == null) return;
                                setState(() {
                                  _selectedSectionId = _sectionList.firstWhere((s) => s.name == value).id;
                                });
                              },
                              hint: "Select Section",
                            ),
                            buildLabel(context, "Subject"),
                            buildDropdown(
                              context,
                              _subjectList.map((s) => s.name).toList(),
                              _subjectList.any((s) => s.id == _selectedSubjectId) ? _subjectList.firstWhere((s) => s.id == _selectedSubjectId).name : null,
                              (value) {
                                if (value == null) return;
                                setState(() {
                                  _selectedSubjectId = _subjectList.firstWhere((s) => s.name == value).id;
                                });
                              },
                              hint: "Select Subject",
                            ),
                            buildLabel(context, "Teacher"),
                            buildDropdown(
                              context,
                              _teacherList.map((t) => t.name).toList(),
                              _teacherList.any((t) => t.id == _selectedTeacherId) ? _teacherList.firstWhere((t) => t.id == _selectedTeacherId).name : null,
                              (value) {
                                if (value == null) return;
                                setState(() {
                                  _selectedTeacherId = _teacherList.firstWhere((t) => t.name == value).id;
                                });
                              },
                              hint: "Select Teacher",
                            ),
                            buildLabel(context, "Weekday"),
                            buildDropdown(
                              context,
                              _weekdayList,
                              _selectedWeekday,
                              (value) => setState(() => _selectedWeekday = value),
                              hint: "Select Weekday",
                            ),
                            SizedBox(height: context.scale(16)),
                            buildResponsiveRow(context, [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildLabel(context, "Start Time"),
                                  _buildTimeSelector(context, _startTime, true),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildLabel(context, "End Time"),
                                  _buildTimeSelector(context, _endTime, false),
                                ],
                              ),
                            ]),
                            SizedBox(height: context.scale(16)),
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

  Widget _buildTimeSelector(BuildContext context, TimeOfDay? time, bool isStartTime) {
    final theme = context.theme;
    return InkWell(
      onTap: () => _selectTime(context, isStartTime: isStartTime),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.spacing / 1.5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(context.scale(12)),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time?.format(context) ?? "Select",
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)),
            ),
            Icon(Icons.access_time_rounded, size: context.scale(18), color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

}
