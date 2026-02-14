import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Add New Schedule'),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isLoading ? null : _buildActionButtons(theme),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: theme.primaryColor,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: LayoutBuilder(builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return _buildWideLayout(theme);
                        } else {
                          return _buildNarrowLayout(theme);
                        }
                      }),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField(theme, "Class", _selectedClassId, _classList.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), (val) {
          setState(() {
            _selectedClassId = val;
            _selectedSectionId = null; // Reset
            if (val != null) {
              _sectionList = _classList.firstWhere((c) => c.id == val).sections;
            } else {
              _sectionList = [];
            }
          });
        }),
        const SizedBox(height: 16),
        _buildDropdownField(theme, "Section", _selectedSectionId, _sectionList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(), (val) => setState(() => _selectedSectionId = val), key: ValueKey(_selectedClassId), dependentParent: "Class"),
        const SizedBox(height: 16),
        _buildDropdownField(theme, "Subject", _selectedSubjectId, _subjectList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(), (val) => setState(() => _selectedSubjectId = val)),
        const SizedBox(height: 16),
        _buildDropdownField(theme, "Teacher", _selectedTeacherId, _teacherList.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(), (val) => setState(() => _selectedTeacherId = val)),
        const SizedBox(height: 16),
        _buildDropdownField(theme, "Weekday", _selectedWeekday, _weekdayList.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(), (val) => setState(() => _selectedWeekday = val)),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTimeField(theme, "Start Time", _startTime, isStartTime: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTimeField(theme, "End Time", _endTime, isStartTime: false)),
          ],
        ),
        const SizedBox(height: 80), // For FAB
      ],
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDropdownField(theme, "Class", _selectedClassId, _classList.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), (val) {
              setState(() {
                _selectedClassId = val;
                _selectedSectionId = null; // Reset
                if (val != null) {
                  _sectionList = _classList.firstWhere((c) => c.id == val).sections;
                } else {
                  _sectionList = [];
                }
              });
            })),
            const SizedBox(width: 16),
            Expanded(child: _buildDropdownField(theme, "Section", _selectedSectionId, _sectionList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(), (val) => setState(() => _selectedSectionId = val), key: ValueKey(_selectedClassId), dependentParent: "Class")),
            const SizedBox(width: 16),
            Expanded(child: _buildDropdownField(theme, "Weekday", _selectedWeekday, _weekdayList.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(), (val) => setState(() => _selectedWeekday = val))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDropdownField(theme, "Subject", _selectedSubjectId, _subjectList.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(), (val) => setState(() => _selectedSubjectId = val))),
            const SizedBox(width: 16),
            Expanded(child: _buildDropdownField(theme, "Teacher", _selectedTeacherId, _teacherList.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(), (val) => setState(() => _selectedTeacherId = val))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTimeField(theme, "Start Time", _startTime, isStartTime: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTimeField(theme, "End Time", _endTime, isStartTime: false)),
          ],
        ),
        const SizedBox(height: 80), // For FAB
      ],
    );
  }

  /// A reusable and robust dropdown form field widget.
  Widget _buildDropdownField<T>(ThemeData theme, String label, T? currentValue, List<DropdownMenuItem<T>> items, ValueChanged<T?> onChanged, {Key? key, String? hint, String? dependentParent}) {
    final bool isDisabled = items.isEmpty;

    String getHintText() {
      if (isDisabled) {
        return dependentParent != null ? "--Select a $dependentParent first--" : "--No options available--";
      }
      return hint ?? "--Select $label--";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          key: key,
          value: currentValue,
          items: items,
          onChanged: isDisabled ? null : onChanged,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: getHintText(),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.dividerColor.withAlpha(128)),
            ),
          ),
          validator: (val) {
            if (isDisabled && dependentParent != null) return null;
            return val == null ? "Please select a $label" : null;
          },
        ),
      ],
    );
  }

  Widget _buildTimeField(ThemeData theme, String label, TimeOfDay? time, {required bool isStartTime}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
        const SizedBox(height: 8),
        FormField<TimeOfDay>(
          initialValue: time,
          validator: (val) => val == null ? "Please select a time" : null,
          builder: (field) {
            return InkWell(
              onTap: () => _selectTime(context, isStartTime: isStartTime),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: field.hasError ? Border.all(color: theme.colorScheme.error, width: 1) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time?.format(context) ?? "--:--",
                      style: theme.textTheme.bodyLarge,
                    ),
                    Icon(Icons.access_time, color: theme.hintColor),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: theme.colorScheme.onSurface,
                side: BorderSide(color: theme.dividerColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Cancel"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _addSchedule,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isSaving ? Container() : const Icon(Icons.add),
              label: _isSaving
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    )
                  : const Text("Add Schedule"),
            ),
          ),
        ],
      ),
    );
  }
}
