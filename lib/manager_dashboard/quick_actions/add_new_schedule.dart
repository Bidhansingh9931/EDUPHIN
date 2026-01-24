import 'dart:async';
import 'package:flutter/material.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class NewSchedule {
  String? aClass;
  String? section;
  String? subject;
  String? teacher;
  String? weekday;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
}

class ScheduleFormData {
  final List<String> classes;
  final List<String> sections;
  final List<String> subjects;
  final List<String> teachers;
  final List<String> weekdays;

  ScheduleFormData({
    required this.classes,
    required this.sections,
    required this.subjects,
    required this.teachers,
    required this.weekdays,
  });
}

// ───────────────────────────────────────────────────────────
//                         MOCK API SERVICE
// ───────────────────────────────────────────────────────────

class MockScheduleApiService {
  Future<ScheduleFormData> fetchScheduleFormData() async {
    // Simulate fetching data for dropdowns from an API
    await Future.delayed(const Duration(milliseconds: 500));
    return ScheduleFormData(
      classes: ['Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'],
      sections: ['A', 'B', 'C'],
      subjects: ['Mathematics', 'Science', 'History', 'English', 'Art'],
      teachers: ['Mr. Smith', 'Mrs. Jones', 'Mr. Williams', 'Ms. Brown', 'Dr. Davis'],
      weekdays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    );
  }

  Future<bool> addSchedule(NewSchedule schedule) async {
    // Simulate sending data to an API
    await Future.delayed(const Duration(seconds: 1));
    debugPrint("Submitting to API:");
    debugPrint(
        'Class: ${schedule.aClass}, Section: ${schedule.section}, Subject: ${schedule.subject}, Teacher: ${schedule.teacher}, Weekday: ${schedule.weekday}, Start: ${schedule.startTime}, End: ${schedule.endTime}');
    // Simulate a successful API call
    return true;
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
  final _apiService = MockScheduleApiService();
  late Future<ScheduleFormData> _formDataFuture;

  // Model to hold all form data
  final _newSchedule = NewSchedule();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _formDataFuture = _apiService.fetchScheduleFormData();
  }

  Future<void> _selectTime(BuildContext context, {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
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
        const SnackBar(
          content: Text('Please fill all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if end time is after start time
    if (_newSchedule.startTime != null && _newSchedule.endTime != null) {
      final start = _newSchedule.startTime!.hour + _newSchedule.startTime!.minute / 60.0;
      final end = _newSchedule.endTime!.hour + _newSchedule.endTime!.minute / 60.0;
      if (end <= start) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await _apiService.addSchedule(_newSchedule);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Schedule added successfully!' : 'Failed to add schedule.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Schedule'),
        centerTitle: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FutureBuilder<ScheduleFormData>(
        future: _formDataFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildActionButtons(theme);
          }
          return const SizedBox.shrink();
        },
      ),
      body: FutureBuilder<ScheduleFormData>(
        future: _formDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading data: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final formData = snapshot.data!;
            return _buildForm(theme, formData);
          } else {
            return const Center(child: Text('No schedule data available'));
          }
        },
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.primaryColor,
              ),
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
        _buildDropdownField(theme, "Class", _newSchedule.aClass, formData.classes,
            (val) => setState(() => _newSchedule.aClass = val)),
        const SizedBox(height: 16),
        _buildDropdownField(theme, "Section", _newSchedule.section, formData.sections,
            (val) => setState(() => _newSchedule.section = val)),
        const SizedBox(height: 16),
        _buildDropdownField(theme, "Subject", _newSchedule.subject, formData.subjects,
            (val) => setState(() => _newSchedule.subject = val)),
        const SizedBox(height: 16),
        _buildDropdownField(theme, "Teacher", _newSchedule.teacher, formData.teachers,
            (val) => setState(() => _newSchedule.teacher = val)),
        const SizedBox(height: 16),
        _buildDropdownField(theme, "Weekday", _newSchedule.weekday, formData.weekdays,
            (val) => setState(() => _newSchedule.weekday = val)),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTimeField(theme, "Start Time", _newSchedule.startTime, isStartTime: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTimeField(theme, "End Time", _newSchedule.endTime, isStartTime: false)),
          ],
        ),
        const SizedBox(height: 80), // For FAB
      ],
    );
  }

  Widget _buildWideLayout(ThemeData theme, ScheduleFormData formData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDropdownField(theme, "Class", _newSchedule.aClass, formData.classes, (val) => setState(() => _newSchedule.aClass = val))),
            const SizedBox(width: 16),
            Expanded(child: _buildDropdownField(theme, "Section", _newSchedule.section, formData.sections, (val) => setState(() => _newSchedule.section = val))),
            const SizedBox(width: 16),
            Expanded(child: _buildDropdownField(theme, "Weekday", _newSchedule.weekday, formData.weekdays, (val) => setState(() => _newSchedule.weekday = val))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDropdownField(theme, "Subject", _newSchedule.subject, formData.subjects, (val) => setState(() => _newSchedule.subject = val))),
            const SizedBox(width: 16),
            Expanded(child: _buildDropdownField(theme, "Teacher", _newSchedule.teacher, formData.teachers, (val) => setState(() => _newSchedule.teacher = val))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTimeField(theme, "Start Time", _newSchedule.startTime, isStartTime: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTimeField(theme, "End Time", _newSchedule.endTime, isStartTime: false)),
          ],
        ),
        const SizedBox(height: 80), // For FAB
      ],
    );
  }

  Widget _buildDropdownField(ThemeData theme, String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: "--Select $label",
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
          validator: (val) => val == null ? "Please select a $label" : null,
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
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isSubmitting ? Container() : const Icon(Icons.add),
              label: _isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
