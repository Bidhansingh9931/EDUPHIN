import 'package:flutter/material.dart';

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
  List<String> _classList = [];
  List<String> _sectionList = [];
  List<String> _subjectList = [];
  List<String> _teacherList = [];
  final List<String> _weekdayList = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

  // Selected values
  String? selectedClass;
  String? selectedSection;
  String? selectedSubject;
  String? selectedTeacher;
  String? selectedWeekday;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    // Simulate API call to fetch dropdown data
    await Future.delayed(const Duration(seconds: 2));

    final fetchedClasses = ["Class 1", "Class 2", "Class 3", "Class 4"];
    final fetchedSections = ["A", "B", "C", "D"];
    final fetchedSubjects = ["Math", "Science", "History", "English"];
    final fetchedTeachers = ["Mr. Smith", "Mrs. Jones", "Mr. Williams", "Ms. Brown"];

    if (mounted) {
      setState(() {
        _classList = fetchedClasses;
        _sectionList = fetchedSections;
        _subjectList = fetchedSubjects;
        _teacherList = fetchedTeachers;
        _isLoading = false;
      });
    }
  }

  Future<void> _addSchedule() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields before saving.')),
      );
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final startTimeFormatted = startTime!.format(context);
    final endTimeFormatted = endTime!.format(context);

    setState(() {
      _isSaving = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final newSchedule = {
      'class': selectedClass,
      'section': selectedSection,
      'subject': selectedSubject,
      'teacher': selectedTeacher,
      'weekday': selectedWeekday,
      'start_time': startTimeFormatted,
      'end_time': endTimeFormatted,
    };

    print('Saving new schedule: $newSchedule');

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Schedule added successfully!')),
    );
    navigator.pop();
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
          startTime = picked;
        } else {
          endTime = picked;
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
        _buildDropdownField(theme, "Class", selectedClass, _classList,
            (val) => setState(() => selectedClass = val)),
        const SizedBox(height: 16),
        _buildDropdownField(theme, "Section", selectedSection, _sectionList,
            (val) => setState(() => selectedSection = val)),
        const SizedBox(height: 16),
        _buildDropdownField(theme, "Subject", selectedSubject, _subjectList,
            (val) => setState(() => selectedSubject = val)),
        const SizedBox(height: 16),
        _buildDropdownField(theme, "Teacher", selectedTeacher, _teacherList,
            (val) => setState(() => selectedTeacher = val)),
        const SizedBox(height: 16),
        _buildDropdownField(theme, "Weekday", selectedWeekday, _weekdayList,
            (val) => setState(() => selectedWeekday = val)),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTimeField(theme, "Start Time", startTime, isStartTime: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTimeField(theme, "End Time", endTime, isStartTime: false)),
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
            Expanded(child: _buildDropdownField(theme, "Class", selectedClass, _classList, (val) => setState(() => selectedClass = val))),
            const SizedBox(width: 16),
            Expanded(child: _buildDropdownField(theme, "Section", selectedSection, _sectionList, (val) => setState(() => selectedSection = val))),
            const SizedBox(width: 16),
            Expanded(child: _buildDropdownField(theme, "Weekday", selectedWeekday, _weekdayList, (val) => setState(() => selectedWeekday = val))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDropdownField(theme, "Subject", selectedSubject, _subjectList, (val) => setState(() => selectedSubject = val))),
            const SizedBox(width: 16),
            Expanded(child: _buildDropdownField(theme, "Teacher", selectedTeacher, _teacherList, (val) => setState(() => selectedTeacher = val))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTimeField(theme, "Start Time", startTime, isStartTime: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTimeField(theme, "End Time", endTime, isStartTime: false)),
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
