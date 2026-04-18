import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddScheduleScreen extends StatefulWidget {
  final int examId;

  const AddScheduleScreen({super.key, required this.examId});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _venueController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  int? _selectedClassId;
  int? _selectedSectionId;
  int? _selectedSubjectId;

  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  List<dynamic> _classes = [];
  List<dynamic> _sections = [];
  List<dynamic> _subjects = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    try {
      final response = await ApiService.get('manager/classes');
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _classes = json.decode(response.body)['data'];
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load classes: $e')),
      );
    }
  }

  Future<void> _fetchSections(int classId) async {
    try {
      final response = await ApiService.get('manager/classes/$classId/sections');
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _sections = json.decode(response.body)['data'];
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load sections: $e')),
      );
    }
  }

  Future<void> _fetchSubjects(int classId) async {
    try {
      final response = await ApiService.get('manager/classes/$classId/subjects');
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _subjects = json.decode(response.body)['data'];
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load subjects: $e')),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? _selectedStartTime ?? TimeOfDay.now()
          : _selectedEndTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = picked;
          _startTimeController.text = picked.format(context);
        } else {
          _selectedEndTime = picked;
          _endTimeController.text = picked.format(context);
        }
      });
    }
  }

  Future<void> _addSchedule() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final body = {
          'exam_id': widget.examId.toString(),
          'class_id': _selectedClassId.toString(),
          'section_id': _selectedSectionId.toString(),
          'subject_id': _selectedSubjectId.toString(),
          'paper_date': _dateController.text,
          'start_time': _selectedStartTime != null ? "${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}:00" : '',
          'end_time': _selectedEndTime != null ? "${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}:00" : '',
          'venue': _venueController.text,
        };
        final response = await ApiService.post('manager/exam-papers', body);

        if (response.statusCode == 201 || response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule added successfully!')),
          );
          Navigator.pop(context, true);
        } else {
           if (!mounted) return;
          final error = json.decode(response.body)['message'] ?? 'Failed to add schedule.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      } catch (e) {
         if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Add Exam Schedule', style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: context.pagePadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Schedule Details",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(18),
                    ),
                  ),
                  Text(
                    "Assign a class, subject, and time for this exam",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: context.font(11),
                    ),
                  ),
                  SizedBox(height: context.md),
                  buildFilterCard(
                    context,
                    children: [
                      buildLabel(context, "Select Class"),
                      DropdownButtonFormField<int>(
                        value: _selectedClassId,
                        decoration: _dropdownDecoration(theme, context),
                        items: _classes.map((c) => DropdownMenuItem<int>(
                          value: c['id'],
                          child: Text(c['name'] ?? 'N/A', style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14))),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClassId = value;
                            _selectedSectionId = null;
                            _selectedSubjectId = null;
                            _sections.clear();
                            _subjects.clear();
                            if (value != null) {
                              _fetchSections(value);
                              _fetchSubjects(value);
                            }
                          });
                        },
                        validator: (value) => value == null ? 'Please select a class' : null,
                      ),

                      buildLabel(context, "Select Section"),
                      DropdownButtonFormField<int>(
                        value: _selectedSectionId,
                        decoration: _dropdownDecoration(theme, context),
                        items: _sections.map((s) => DropdownMenuItem<int>(
                          value: s['id'],
                          child: Text(s['name'] ?? 'N/A', style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14))),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedSectionId = value),
                        validator: (value) => value == null ? 'Please select a section' : null,
                      ),

                      buildLabel(context, "Select Subject"),
                      DropdownButtonFormField<int>(
                        value: _selectedSubjectId,
                        decoration: _dropdownDecoration(theme, context),
                        items: _subjects.map((s) => DropdownMenuItem<int>(
                          value: s['id'],
                          child: Text(s['name'] ?? 'N/A', style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14))),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedSubjectId = value),
                        validator: (value) => value == null ? 'Please select a subject' : null,
                      ),

                      buildLabel(context, "Venue"),
                      buildTextField(context, _venueController, "e.g., Room 101"),

                      buildLabel(context, "Date"),
                      buildDateField(context, _dateController, "Select Date"),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel(context, "Start Time"),
                                TextFormField(
                                  controller: _startTimeController,
                                  readOnly: true,
                                  onTap: () => _selectTime(context, true),
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)),
                                  decoration: _inputDecoration(theme, context, Icons.access_time),
                                  validator: (value) => value!.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: context.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel(context, "End Time"),
                                TextFormField(
                                  controller: _endTimeController,
                                  readOnly: true,
                                  onTap: () => _selectTime(context, false),
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)),
                                  decoration: _inputDecoration(theme, context, Icons.access_time_filled),
                                  validator: (value) => value!.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.md),
                    ],
                  ),
                  SizedBox(height: context.lg),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    buildActionButton(
                      context,
                      "Add Schedule",
                      _addSchedule,
                    ),
                  SizedBox(height: context.md),
                  buildActionButton(
                    context,
                    "Cancel",
                    () => Navigator.pop(context),
                    isPrimary: false,
                  ),
                  SizedBox(height: context.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(ThemeData theme, BuildContext context) {
    return InputDecoration(
      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.spacing / 1.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
    );
  }

  InputDecoration _inputDecoration(ThemeData theme, BuildContext context, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: context.scale(18), color: theme.colorScheme.primary),
      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.spacing / 1.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
    );
  }
}
