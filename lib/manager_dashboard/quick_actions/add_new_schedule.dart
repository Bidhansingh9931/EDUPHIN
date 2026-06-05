import 'dart:async';
import 'dart:convert';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class NewSchedule {
  int? classId;
  int? sectionId;
  int? subjectId;
  int? teacherId;
  String? weekday;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
}

// Models for data from the API
class ApiClass {
  final int id;
  final String name;
  ApiClass({required this.id, required this.name});
  factory ApiClass.fromJson(Map<String, dynamic> json) => ApiClass(id: json['id'], name: json['name']);
}

class ApiSection {
  final int id;
  final String name;
  ApiSection({required this.id, required this.name});
  factory ApiSection.fromJson(Map<String, dynamic> json) => ApiSection(id: json['id'], name: json['section_name']);
}

class ApiSubject {
  final int id;
  final String name;
  ApiSubject({required this.id, required this.name});
  factory ApiSubject.fromJson(Map<String, dynamic> json) => ApiSubject(id: json['id'], name: json['name']);
}

class ApiTeacher {
  final int id;
  final String name;
  ApiTeacher({required this.id, required this.name});
  factory ApiTeacher.fromJson(Map<String, dynamic> json) => ApiTeacher(id: json['id'], name: json['name']);
}

class ScheduleFormData {
  final List<ApiClass> classes;
  final List<ApiSection> sections;
  final List<ApiSubject> subjects;
  final List<ApiTeacher> teachers;
  final List<String> weekdays;

  ScheduleFormData({
    this.classes = const [],
    this.sections = const [],
    this.subjects = const [],
    this.teachers = const [],
    this.weekdays = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
  });
}

// ───────────────────────────────────────────────────────────
//                         API SERVICE
// ───────────────────────────────────────────────────────────

class ScheduleApiService {
  Future<ScheduleFormData> fetchScheduleFormData() async {
    final response = await ApiService.get('manager/class-schedules/meta');
    final body = jsonDecode(response.body);
    if (body['status'] == true) {
      return ScheduleFormData(
        classes: (body['classes'] as List).map((c) => ApiClass.fromJson(c)).toList(),
        sections: (body['sections'] as List).map((s) => ApiSection.fromJson(s)).toList(),
        subjects: (body['subjects'] as List).map((s) => ApiSubject.fromJson(s)).toList(),
        teachers: (body['teachers'] as List).map((t) => ApiTeacher.fromJson(t)).toList(),
      );
    }
    throw Exception('Failed to load form data: ${body['message']}');
  }

  Future<Map<String, dynamic>> addSchedule(NewSchedule schedule) async {
    final body = {
      'class_id': schedule.classId.toString(),
      'section_id': schedule.sectionId.toString(),
      'subject_id': schedule.subjectId.toString(),
      'teacher_id': schedule.teacherId.toString(),
      'weekday': schedule.weekday,
      'start_time': '${schedule.startTime!.hour.toString().padLeft(2, '0')}:${schedule.startTime!.minute.toString().padLeft(2, '0')}',
      'end_time': '${schedule.endTime!.hour.toString().padLeft(2, '0')}:${schedule.endTime!.minute.toString().padLeft(2, '0')}',
    };
    final response = await ApiService.post('manager/class-schedules', body);
    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 201 && responseBody['status'] == true) {
      return responseBody;
    }
    throw Exception(responseBody['message'] ?? 'Failed to add schedule. Status: ${response.statusCode}');
  }
}

// ───────────────────────────────────────────────────────────
//                      ADD NEW SCHEDULE PAGE
// ───────────────────────────────────────────────────────────

class AddNewSchedulePage extends StatefulWidget {
  const AddNewSchedulePage({super.key});

  @override
  State<StatefulWidget> createState() => _AddNewSchedulePageState();
}

class _AddNewSchedulePageState extends State<AddNewSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ScheduleApiService();
  
  ScheduleFormData? _formData;
  bool _isLoading = true;
  Object? _error;
  final String _cacheKey = 'schedule_form_data';

  final _newSchedule = NewSchedule();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadCachedData();
    await _fetchFormData();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CacheService.getCache(_cacheKey);
    if (cachedData != null) {
      if (mounted) {
        setState(() {
          _formData = ScheduleFormData(
            classes: (cachedData['classes'] as List).map((c) => ApiClass.fromJson(c)).toList(),
            sections: (cachedData['sections'] as List).map((s) => ApiSection.fromJson(s)).toList(),
            subjects: (cachedData['subjects'] as List).map((s) => ApiSubject.fromJson(s)).toList(),
            teachers: (cachedData['teachers'] as List).map((t) => ApiTeacher.fromJson(t)).toList(),
          );
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchFormData() async {
    if (_formData == null) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final response = await ApiService.get('manager/class-schedules/meta');
      final body = jsonDecode(response.body);
      if (body['status'] == true) {
        await CacheService.setCache(_cacheKey, body);
        if (mounted) {
          setState(() {
            _formData = ScheduleFormData(
              classes: (body['classes'] as List).map((c) => ApiClass.fromJson(c)).toList(),
              sections: (body['sections'] as List).map((s) => ApiSection.fromJson(s)).toList(),
              subjects: (body['subjects'] as List).map((s) => ApiSubject.fromJson(s)).toList(),
              teachers: (body['teachers'] as List).map((t) => ApiTeacher.fromJson(t)).toList(),
            );
            _isLoading = false;
            _error = null;
          });
        }
      } else {
        throw Exception('Failed to load form data: ${body['message']}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = _formData == null;
        });
      }
    }
  }

  Future<void> _selectTime(BuildContext context, {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && context.mounted) {
      setState(() {
        if (isStartTime) {
          _newSchedule.startTime = picked;
        } else {
          _newSchedule.endTime = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_newSchedule.startTime != null && _newSchedule.endTime != null) {
      final start = _newSchedule.startTime!.hour + _newSchedule.startTime!.minute / 60.0;
      final end = _newSchedule.endTime!.hour + _newSchedule.endTime!.minute / 60.0;
      if (end <= start) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time.'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final responseData = await _apiService.addSchedule(_newSchedule);
      if (!mounted) return;
      final message = responseData['message'] ?? 'Schedule added successfully!';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showError(context, e);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Schedule'), centerTitle: true),
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isLoading && _formData == null ? null : _buildActionButtons(theme),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _formData != null,
        error: _error,
        onRetry: _fetchFormData,
        skeleton: _buildSkeleton(),
        child: _formData == null ? const SizedBox.shrink() : _buildForm(theme, _formData!),
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(height: 20, width: 100),
                const SizedBox(height: 10),
                const SkeletonBox(height: 50),
                const SizedBox(height: 20),
                const SkeletonBox(height: 20, width: 100),
                const SizedBox(height: 10),
                const SkeletonBox(height: 50),
                const SizedBox(height: 20),
                const SkeletonBox(height: 20, width: 100),
                const SizedBox(height: 10),
                const SkeletonBox(height: 50),
                const SizedBox(height: 20),
                const SkeletonBox(height: 20, width: 100),
                const SizedBox(height: 10),
                const SkeletonBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildForm(ThemeData theme, ScheduleFormData formData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: theme.primaryColor),
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return _buildWideLayout(theme, formData);
                } else {
                  return _buildNarrowLayout(theme, formData);
                }
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(ThemeData theme, ScheduleFormData formData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildClassDropdown(theme, "Class", _newSchedule.classId, formData.classes, (val) => setState(() => _newSchedule.classId = val)),
        const SizedBox(height: 16),
        _buildSectionDropdown(theme, "Section", _newSchedule.sectionId, formData.sections, (val) => setState(() => _newSchedule.sectionId = val)),
        const SizedBox(height: 16),
        _buildSubjectDropdown(theme, "Subject", _newSchedule.subjectId, formData.subjects, (val) => setState(() => _newSchedule.subjectId = val)),
        const SizedBox(height: 16),
        _buildTeacherDropdown(theme, "Teacher", _newSchedule.teacherId, formData.teachers, (val) => setState(() => _newSchedule.teacherId = val)),
        const SizedBox(height: 16),
        _buildWeekdayDropdown(theme, "Weekday", _newSchedule.weekday, formData.weekdays, (val) => setState(() => _newSchedule.weekday = val)),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _buildTimeField(theme, "Start Time", _newSchedule.startTime, isStartTime: true)),
          const SizedBox(width: 16),
          Expanded(child: _buildTimeField(theme, "End Time", _newSchedule.endTime, isStartTime: false)),
        ]),
        const SizedBox(height: 80), // For FAB
      ],
    );
  }

  Widget _buildWideLayout(ThemeData theme, ScheduleFormData formData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _buildClassDropdown(theme, "Class", _newSchedule.classId, formData.classes, (val) => setState(() => _newSchedule.classId = val))),
          const SizedBox(width: 16),
          Expanded(child: _buildSectionDropdown(theme, "Section", _newSchedule.sectionId, formData.sections, (val) => setState(() => _newSchedule.sectionId = val))),
          const SizedBox(width: 16),
          Expanded(child: _buildWeekdayDropdown(theme, "Weekday", _newSchedule.weekday, formData.weekdays, (val) => setState(() => _newSchedule.weekday = val))),
        ]),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _buildSubjectDropdown(theme, "Subject", _newSchedule.subjectId, formData.subjects, (val) => setState(() => _newSchedule.subjectId = val))),
          const SizedBox(width: 16),
          Expanded(child: _buildTeacherDropdown(theme, "Teacher", _newSchedule.teacherId, formData.teachers, (val) => setState(() => _newSchedule.teacherId = val))),
        ]),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _buildTimeField(theme, "Start Time", _newSchedule.startTime, isStartTime: true)),
          const SizedBox(width: 16),
          Expanded(child: _buildTimeField(theme, "End Time", _newSchedule.endTime, isStartTime: false)),
        ]),
        const SizedBox(height: 80), // For FAB
      ],
    );
  }

  // Generic Dropdown
  Widget _buildDropdown<T>(ThemeData theme, String label, T? value, List<DropdownMenuItem<T>> items, ValueChanged<T?> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
      const SizedBox(height: 8),
      DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "--Select $label",
          filled: true,
          fillColor: theme.scaffoldBackgroundColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
        validator: (val) => val == null ? "Please select a $label" : null,
      ),
    ]);
  }
  
  // Specific Dropdown Builders
  Widget _buildClassDropdown(ThemeData theme, String label, int? value, List<ApiClass> items, ValueChanged<int?> onChanged) => 
    _buildDropdown<int>(theme, label, value, items.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), onChanged);

  Widget _buildSectionDropdown(ThemeData theme, String label, int? value, List<ApiSection> items, ValueChanged<int?> onChanged) =>
    _buildDropdown<int>(theme, label, value, items.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), onChanged);

  Widget _buildSubjectDropdown(ThemeData theme, String label, int? value, List<ApiSubject> items, ValueChanged<int?> onChanged) =>
    _buildDropdown<int>(theme, label, value, items.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), onChanged);

  Widget _buildTeacherDropdown(ThemeData theme, String label, int? value, List<ApiTeacher> items, ValueChanged<int?> onChanged) =>
    _buildDropdown<int>(theme, label, value, items.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(), onChanged);
    
  Widget _buildWeekdayDropdown(ThemeData theme, String label, String? value, List<String> items, ValueChanged<String?> onChanged) =>
    _buildDropdown<String>(theme, label, value, items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged);


  Widget _buildTimeField(ThemeData theme, String label, TimeOfDay? time, {required bool isStartTime}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                border: field.hasError ? Border.all(color: theme.colorScheme.error) : null,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(time != null ? time.format(context) : "Select Time", style: theme.textTheme.bodyLarge),
                const Icon(Icons.access_time),
              ]),
            ),
          );
        },
      ),
    ]);
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(children: [
        Expanded(
            child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: theme.dividerColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
          child: Text("Cancel", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface)),
        )),
        const SizedBox(width: 16),
        Expanded(
            child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
          icon: _isSubmitting ? const SizedBox.shrink() : const Icon(Icons.add),
          label: _isSubmitting
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(Colors.white)))
              : Text("Add Schedule", style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
        )),
      ]),
    );
  }
}

