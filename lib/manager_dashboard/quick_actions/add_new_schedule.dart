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

class AddNewSchedule extends StatefulWidget {
  const AddNewSchedule({super.key});

  @override
  State<StatefulWidget> createState() => _AddNewScheduleState();
}

class _AddNewScheduleState extends State<AddNewSchedule> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Schedule'),
        centerTitle: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: const Padding(
        padding: EdgeInsets.fromLTRB(12, 12, 12, 60),
        child: SingleChildScrollView(
          child: CustomAddNewScheduleBox(),
        ),
      ),
    );
  }
}

class CustomAddNewScheduleBox extends StatefulWidget {
  const CustomAddNewScheduleBox({super.key});

  @override
  State<CustomAddNewScheduleBox> createState() => _CustomAddNewScheduleBoxState();
}

class _CustomAddNewScheduleBoxState extends State<CustomAddNewScheduleBox> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = MockScheduleApiService();
  late Future<ScheduleFormData> _formDataFuture;

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
    // Basic validation
    if (_newSchedule.aClass == null ||
        _newSchedule.section == null ||
        _newSchedule.subject == null ||
        _newSchedule.teacher == null ||
        _newSchedule.weekday == null ||
        _newSchedule.startTime == null ||
        _newSchedule.endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields.'),
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

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
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
    return FutureBuilder<ScheduleFormData>(
      future: _formDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error loading data: ${snapshot.error}"));
        } else if (snapshot.hasData) {
          final formData = snapshot.data!;
          // Set default values from fetched data if they are not already set
          _newSchedule.aClass ??= formData.classes.first;
          _newSchedule.section ??= formData.sections.first;
          _newSchedule.subject ??= formData.subjects.first;
          _newSchedule.teacher ??= formData.teachers.first;
          _newSchedule.weekday ??= formData.weekdays.first;

          return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Class", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                    const SizedBox(height: 8),
                    DropDownBox(
                      key: ValueKey(_newSchedule.aClass),
                      value: _newSchedule.aClass,
                      items: formData.classes,
                      onChanged: (value) => setState(() => _newSchedule.aClass = value),
                      hintText: "--Select Class",
                    ),
                    const SizedBox(height: 16),
                    Text("Section", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                    const SizedBox(height: 8),
                    DropDownBox(
                      key: ValueKey(_newSchedule.section),
                      value: _newSchedule.section,
                      items: formData.sections,
                      onChanged: (value) => setState(() => _newSchedule.section = value),
                      hintText: "--Select Section",
                    ),
                    const SizedBox(height: 16),
                    Text("Subject", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                    const SizedBox(height: 8),
                    DropDownBox(
                      key: ValueKey(_newSchedule.subject),
                      value: _newSchedule.subject,
                      items: formData.subjects,
                      onChanged: (value) => setState(() => _newSchedule.subject = value),
                      hintText: "--Select Subject",
                    ),
                    const SizedBox(height: 16),
                    Text("Teacher", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                    const SizedBox(height: 8),
                    DropDownBox(
                      key: ValueKey(_newSchedule.teacher),
                      value: _newSchedule.teacher,
                      items: formData.teachers,
                      onChanged: (value) => setState(() => _newSchedule.teacher = value),
                      hintText: "--Select Teacher",
                    ),
                    const SizedBox(height: 16),
                    Text("Weekdays", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                    const SizedBox(height: 8),
                    DropDownBox(
                      key: ValueKey(_newSchedule.weekday),
                      value: _newSchedule.weekday,
                      items: formData.weekdays,
                      onChanged: (value) => setState(() => _newSchedule.weekday = value),
                      hintText: "--Select Weekday",
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Start Time", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () => _selectTime(context, isStartTime: true),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          side: BorderSide(color: theme.hintColor))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _newSchedule.startTime?.format(context) ?? "__:__:__",
                                          style: TextStyle(color: theme.hintColor, fontSize: 23),
                                        ),
                                      ),
                                      Icon(Icons.access_time, color: theme.hintColor),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("End Time", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () => _selectTime(context, isStartTime: false),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          side: BorderSide(color: theme.hintColor))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _newSchedule.endTime?.format(context) ?? "__:__:__",
                                          style: TextStyle(color: theme.hintColor, fontSize: 23),
                                        ),
                                      ),
                                      Icon(Icons.access_time, color: theme.hintColor),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Divider(
                      color: theme.colorScheme.onPrimary,
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: ElevatedButton(
                                onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.onPrimary.withAlpha(25),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                ),
                                child: Text("Cancel", style: TextStyle(fontSize: 18, color: theme.colorScheme.onPrimary))),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
                                child: _isSubmitting
                                    ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)))
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                          const SizedBox(width: 8),
                                          const Flexible(
                                            child: Text(
                                              "Add Schedule",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 18, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      )),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ));
        } else {
          return const Center(child: Text('No schedule data available'));
        }
      },
    );
  }
}

class DropDownBox extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  const DropDownBox({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ));
  }
}
