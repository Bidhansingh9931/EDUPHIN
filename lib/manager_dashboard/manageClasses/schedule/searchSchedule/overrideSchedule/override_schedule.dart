import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- Data Models ---
class OriginalScheduleDetails {
  final String className;
  final String subject;
  final String teacher;
  final String time;

  const OriginalScheduleDetails({
    required this.className,
    required this.subject,
    required this.teacher,
    required this.time,
  });
}

class ApiSubject {
  final int id;
  final String name;
  ApiSubject({required this.id, required this.name});

  factory ApiSubject.fromJson(Map<String, dynamic> json) {
    return ApiSubject(id: json['id'], name: json['name']);
  }
}

class ApiTeacher {
  final int id;
  final String name;
  ApiTeacher({required this.id, required this.name});

  factory ApiTeacher.fromJson(Map<String, dynamic> json) {
    return ApiTeacher(id: json['id'], name: json['name']);
  }
}

class OverrideSchedulePage extends StatefulWidget{
  final int scheduleId;
  final OriginalScheduleDetails scheduleDetails;

  const OverrideSchedulePage({
    super.key,
    required this.scheduleId,
    required this.scheduleDetails,
  });

  @override
  State<StatefulWidget> createState() => _OverrideSchedulePageState();
}

class _OverrideSchedulePageState extends State<OverrideSchedulePage>{
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _selectedDateController = TextEditingController();
  
  bool _isSaving = false;
  bool _isLoading = true;
  String _error = '';

  String _overrideType = 'cancelled'; // Default value
  int? _newSubjectId;
  int? _newTeacherId;
  TimeOfDay? _newStartTime;
  TimeOfDay? _newEndTime;

  List<ApiSubject> _subjects = [];
  List<ApiTeacher> _teachers = [];


  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _selectedDateController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await ApiService.get('manager/class-schedules/meta');
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final List<dynamic> subjectData = data['subjects'] ?? [];
          final List<dynamic> teacherData = data['teachers'] ?? [];

          setState(() {
            _subjects = subjectData.map((json) => ApiSubject.fromJson(json)).toList();
            _teachers = teacherData.map((json) => ApiTeacher.fromJson(json)).toList();
          });
        } else {
          throw Exception('API returned an error: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst("Exception: ", "");
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _overrideSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
       final DateFormat inputFormat = DateFormat('dd-MM-yyyy');
       final DateTime dateTime = inputFormat.parse(_selectedDateController.text);
       final String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

      final Map<String, dynamic> body = {
        'date': formattedDate,
        'override_type': _overrideType,
        'note': _noteController.text,
        // Add rescheduled fields only if applicable
        if (_overrideType == 'rescheduled') ...{
          'new_subject_id': _newSubjectId.toString(),
          'new_teacher_id': _newTeacherId.toString(),
          'new_start_time': _newStartTime!.format(context),
          'new_end_time': _newEndTime!.format(context),
        }
      };

      final response = await ApiService.post('manager/class-schedules/${widget.scheduleId}/override', body);

      if (!mounted) return;

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule overridden successfully!')),
        );
        Navigator.of(context).pop();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to override schedule');
      }
    } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }


  Future<void> selectDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (!context.mounted) return;
      controller.text =
      "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _newStartTime = picked;
        } else {
          _newEndTime = picked;
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
        title: const Text("Override Schedule"),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
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
              child: ElevatedButton(
                onPressed: _isSaving || _isLoading ? null : _overrideSchedule,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text("Override"),
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
     if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center,),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _fetchData, child: const Text("Retry"))
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Form(
              key: _formKey,
              child: constraints.maxWidth > 700
                  ? _buildWideLayout(theme)
                  : _buildNarrowLayout(theme),
            ),
          );
        },
      );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomContainer(
          title: "Original Schedule Details",
          className: widget.scheduleDetails.className,
          subject: widget.scheduleDetails.subject,
          teacher: widget.scheduleDetails.teacher,
          time: widget.scheduleDetails.time,
        ),
        const SizedBox(height: 16),
        _buildFormFields(theme),
        const SizedBox(height: 80), // Padding for FAB
      ],
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: CustomContainer(
            title: "Original Schedule Details",
            className: widget.scheduleDetails.className,
            subject: widget.scheduleDetails.subject,
            teacher: widget.scheduleDetails.teacher,
            time: widget.scheduleDetails.time,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _buildFormFields(theme),
        ),
      ],
    );
  }

  Widget _buildFormFields(ThemeData theme) {

    String? selectedSubjectName;
    if (_newSubjectId != null) {
      try {
        selectedSubjectName = _subjects.firstWhere((s) => s.id == _newSubjectId).name;
      } catch (e) { selectedSubjectName = null; }
    }

    String? selectedTeacherName;
    if (_newTeacherId != null) {
      try {
        selectedTeacherName = _teachers.firstWhere((t) => t.id == _newTeacherId).name;
      } catch (e) { selectedTeacherName = null; }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(theme, "Override Type", _overrideType, ['cancelled', 'rescheduled'], (val) => setState(() => _overrideType = val!)),
        const SizedBox(height: 16),

        if (_overrideType == 'rescheduled') ...[
            _buildDropdown(theme, "New Subject", selectedSubjectName, _subjects.map((s) => s.name).toList(), (val) => setState(() => _newSubjectId = _subjects.firstWhere((s) => s.name == val).id)),
            const SizedBox(height: 16),
            _buildDropdown(theme, "New Teacher", selectedTeacherName, _teachers.map((t) => t.name).toList(), (val) => setState(() => _newTeacherId = _teachers.firstWhere((t) => t.name == val).id)),
            const SizedBox(height: 16),
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildTimeField(theme, "New Start Time", _newStartTime, true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimeField(theme, "New End Time", _newEndTime, false)),
                ],
              ),
            const SizedBox(height: 16),
        ],

        Text("Date of Override", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _selectedDateController,
          readOnly: true,
          onTap: () => selectDate(context, _selectedDateController),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_month),
            filled: true,
            fillColor: theme.colorScheme.surface,
            hintText: "Select Date",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Please select a date' : null,
        ),
        const SizedBox(height: 16),
        Text("Note (optional)", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            hintText: "Enter optional note...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(ThemeData theme, String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : null,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (val) => val == null ? 'Please make a selection' : null,
        ),
    ]);
  }

  Widget _buildTimeField(ThemeData theme, String label, TimeOfDay? time, bool isStart) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: theme.textTheme.titleMedium),
      const SizedBox(height: 8),
      FormField<TimeOfDay>(
        validator: (val) => val == null ? "Required" : null,
        builder: (field) {
          return InkWell(
            onTap: () => _selectTime(context, isStart),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
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
}

class CustomContainer extends StatelessWidget{
  final String title;
  final String className;
  final String subject;
  final String teacher;
  final String time;

  const CustomContainer({
    super.key,
    required this.title,
    required this.className,
    required this.subject,
    required this.teacher,
    required this.time,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDetailRow(theme, "Class Name", className),
          const SizedBox(height: 16),
          _buildDetailRow(theme, "Subject", subject),
          const SizedBox(height: 16),
          _buildDetailRow(theme, "Teacher", teacher),
          const SizedBox(height: 16),
          _buildDetailRow(theme, "Time (From - To)", time),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
