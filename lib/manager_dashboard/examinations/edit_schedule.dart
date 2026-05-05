import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditScheduleScreen extends StatefulWidget {
  final int paperId;
  final int examId;
  final int initialClassId;
  final int initialSectionId;
  final int initialSubjectId;
  final String? initialVenue;
  final String? initialDate;
  final String? initialStartTime;
  final String? initialEndTime;

  const EditScheduleScreen({
    super.key,
    required this.paperId,
    required this.examId,
    required this.initialClassId,
    required this.initialSectionId,
    required this.initialSubjectId,
    this.initialVenue,
    this.initialDate,
    this.initialStartTime,
    this.initialEndTime,
  });

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _venueController;
  late final TextEditingController _dateController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;

  dynamic _selectedClassId;
  dynamic _selectedSectionId;
  dynamic _selectedSubjectId;

  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  List<dynamic> _classes = [];
  List<dynamic> _sections = [];
  List<dynamic> _subjects = [];

  bool _isLoading = false;
  bool _isFetchingInitialData = true;
  bool _isSectionsLoading = false;
  bool _isSubjectsLoading = false;

  @override
  void initState() {
    super.initState();
    _venueController = TextEditingController(text: widget.initialVenue);
    _dateController = TextEditingController(text: widget.initialDate);
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();

    _selectedClassId = widget.initialClassId;
    _selectedSectionId = widget.initialSectionId;
    _selectedSubjectId = widget.initialSubjectId;

    if (widget.initialStartTime != null && widget.initialStartTime!.isNotEmpty) {
      try {
        final time = DateFormat('HH:mm:ss').parse(widget.initialStartTime!);
        _selectedStartTime = TimeOfDay.fromDateTime(time);
        _startTimeController.text = _selectedStartTime!.format(context);
      } catch (e) {}
    }

    if (widget.initialEndTime != null && widget.initialEndTime!.isNotEmpty) {
      try {
        final time = DateFormat('HH:mm:ss').parse(widget.initialEndTime!);
        _selectedEndTime = TimeOfDay.fromDateTime(time);
        _endTimeController.text = _selectedEndTime!.format(context);
      } catch (e) {}
    }

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isFetchingInitialData = true);
    await _fetchClasses();
    if (_selectedClassId != null) {
      await Future.wait([
        _fetchSections(_selectedClassId!),
        _fetchSubjects(_selectedClassId!),
      ]);
    }
    setState(() => _isFetchingInitialData = false);
  }

  Future<void> _fetchClasses() async {
    try {
      final response = await ApiService.get('manager/classes');
      if (response.statusCode == 200) {
        if (!mounted) return;
        final decoded = json.decode(response.body);
        setState(() {
          _classes = (decoded is List) ? decoded : (decoded['data'] ?? []);
        });
      }
    } catch (e) {}
  }

  Future<void> _fetchSections(dynamic classId) async {
    setState(() => _isSectionsLoading = true);
    try {
      final response = await ApiService.get('manager/classes/$classId/sections');
      bool found = false;
      if (response.statusCode == 200) {
        if (!mounted) return;
        final decoded = json.decode(response.body);
        var data = (decoded is Map) ? (decoded['data'] ?? decoded) : decoded;
        List list = [];
        if (data is Map && data.containsKey('sections')) {
          list = data['sections'] as List;
        } else if (data is List) {
          list = data;
        }
        if (list.isNotEmpty) {
          setState(() => _sections = list);
          found = true;
        }
      }
      
      if (!found) {
        // Fallback: If class-specific route fails or returns empty, try getting sections from the class object
        final selectedClass = _classes.firstWhere(
          (c) => c['id'].toString() == classId.toString(), 
          orElse: () => null
        );
        if (selectedClass != null && selectedClass['sections'] != null) {
          setState(() {
            _sections = selectedClass['sections'] is List ? selectedClass['sections'] : [];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching sections: $e');
    } finally {
      if (mounted) setState(() => _isSectionsLoading = false);
    }
  }

  Future<void> _fetchSubjects(dynamic classId) async {
    setState(() => _isSubjectsLoading = true);
    try {
      // Try class-specific subjects first
      var response = await ApiService.get('manager/classes/$classId/subjects');
      bool found = false;
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        var data = (decoded is Map) ? (decoded['data'] ?? decoded) : decoded;
        List list = [];
        if (data is Map && data.containsKey('subjects')) {
          list = data['subjects'] as List;
        } else if (data is List) {
          list = data;
        }
        if (list.isNotEmpty) {
          setState(() => _subjects = list);
          found = true;
        }
      }

      if (!found) {
        // Fallback 1: Try getting subjects from the class object if available
        final selectedClass = _classes.firstWhere(
          (c) => c['id'].toString() == classId.toString(), 
          orElse: () => null
        );
        if (selectedClass != null && selectedClass['subjects'] != null) {
          setState(() {
            _subjects = selectedClass['subjects'] is List ? selectedClass['subjects'] : [];
          });
          if (_subjects.isNotEmpty) found = true;
        }
      }

      // Fallback 2: Try the general subjects endpoint
      if (!found) {
        response = await ApiService.get('manager/subjects');
        if (response.statusCode == 200) {
          if (!mounted) return;
          final decoded = json.decode(response.body);
          setState(() {
            var data = (decoded is Map) ? (decoded['data'] ?? decoded) : decoded;
            if (data is Map && data.containsKey('subjects')) {
              _subjects = data['subjects'] as List;
            } else if (data is List) {
              _subjects = data;
            } else {
              _subjects = [];
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
    } finally {
      if (mounted) setState(() => _isSubjectsLoading = false);
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

  Future<void> _updateSchedule() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String formattedDate = _dateController.text;
        if (formattedDate.isNotEmpty) {
          try {
            // Convert from DD-MM-YYYY to YYYY-MM-DD for MySQL
            final date = DateFormat('dd-MM-yyyy').parse(formattedDate);
            formattedDate = DateFormat('yyyy-MM-dd').format(date);
          } catch (e) {
            // If already in yyyy-MM-dd or other format, keep as is or let backend handle
          }
        }

        final body = {
          'id': widget.paperId.toString(),
          'exam_id': widget.examId.toString(),
          'class_id': _selectedClassId.toString(),
          'section_id': _selectedSectionId.toString(),
          'subject_id': _selectedSubjectId.toString(),
          'date': formattedDate,
          'start_time': _selectedStartTime != null 
              ? "${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}:00" 
              : '',
          'end_time': _selectedEndTime != null 
              ? "${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}:00" 
              : '',
          'venue': _venueController.text,
        };
        
        // Changed method from PUT to POST and removed the paperId from the URL to match your working route
        final response = await ApiService.post('manager/exams/${widget.examId}/schedule', body);

        if (!mounted) return;

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule updated successfully!')),
          );
          Navigator.pop(context, true);
        } else {
          final error = json.decode(response.body)['message'] ?? 'Failed to update schedule.';
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
        title: Text('Edit Exam Schedule', style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isFetchingInitialData 
          ? const Center(child: CircularProgressIndicator())
          : Center(
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
                    "Update Schedule Details",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(18),
                    ),
                  ),
                  Text(
                    "Modify class, subject, or time for this exam paper",
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
                      buildDropdown<dynamic>(
                        context,
                        _classes.map((c) => c['id']).toList(),
                        _selectedClassId,
                        (value) {
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
                        hint: "Select Class",
                        itemBuilder: (id) {
                          final cls = _classes.firstWhere(
                            (c) => c['id'].toString() == id.toString(),
                            orElse: () => null,
                          );
                          return cls != null ? (cls['name'] ?? 'N/A').toString() : 'N/A';
                        },
                      ),

                      buildLabel(context, "Select Section"),
                      buildDropdown<dynamic>(
                        context,
                        _sections.map((s) => s['id']).toList(),
                        _selectedSectionId,
                        (value) => setState(() => _selectedSectionId = value),
                        hint: "Select Section",
                        itemBuilder: (id) {
                          final section = _sections.firstWhere(
                            (s) => s['id'].toString() == id.toString(),
                            orElse: () => null,
                          );
                          return section != null ? (section['section_name'] ?? section['name']).toString() : 'N/A';
                        },
                        isLoading: _isSectionsLoading,
                      ),

                      buildLabel(context, "Select Subject"),
                      buildDropdown<dynamic>(
                        context,
                        _subjects.map((s) => s['id']).toList(),
                        _selectedSubjectId,
                        (value) => setState(() => _selectedSubjectId = value),
                        hint: "Select Subject",
                        itemBuilder: (id) {
                          final subject = _subjects.firstWhere(
                            (s) => s['id'].toString() == id.toString(),
                            orElse: () => null,
                          );
                          return subject != null ? (subject['name'] ?? 'N/A').toString() : 'N/A';
                        },
                        isLoading: _isSubjectsLoading,
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
                      "Update Schedule",
                      _updateSchedule,
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
