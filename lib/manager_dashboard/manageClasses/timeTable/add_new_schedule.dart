import 'package:flutter/material.dart';

class AddNewSchedulePage extends StatefulWidget {
  const AddNewSchedulePage({super.key});

  @override
  State<StatefulWidget> createState() => _AddNewSchedulePageState();
}

class _AddNewSchedulePageState extends State<AddNewSchedulePage> {
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
        padding: EdgeInsets.fromLTRB(16, 16, 16, 60),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAddNewScheduleBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAddNewScheduleBox extends StatefulWidget {
  const CustomAddNewScheduleBox({super.key});

  @override
  State<CustomAddNewScheduleBox> createState() =>
      _CustomAddNewScheduleBoxState();
}

class _CustomAddNewScheduleBoxState extends State<CustomAddNewScheduleBox> {
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

    // Mock data
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

        // Set initial values
        selectedClass = _classList.first;
        selectedSection = _sectionList.first;
        selectedSubject = _subjectList.first;
        selectedTeacher = _teacherList.first;
        selectedWeekday = _weekdayList.first;

        _isLoading = false;
      });
    }
  }

  Future<void> _addSchedule() async {
    // Validate that all fields are selected
    if (selectedClass == null ||
        selectedSection == null ||
        selectedSubject == null ||
        selectedTeacher == null ||
        selectedWeekday == null ||
        startTime == null ||
        endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields before saving.')),
      );
      return;
    }

    // Store the context-dependent data before the async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final startTimeFormatted = startTime!.format(context);
    final endTimeFormatted = endTime!.format(context);

    setState(() {
      _isSaving = true;
    });

    // Simulate API call to save the schedule
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
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Class", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                const SizedBox(height: 8),
                DropDownBox(
                  value: selectedClass,
                  items: _classList,
                  onChanged: (value) {
                    setState(() {
                      selectedClass = value;
                    });
                  },
                  hintText: "--Select Class",
                ),
                const SizedBox(height: 16),
                Text("Section", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                const SizedBox(height: 8),
                DropDownBox(
                  value: selectedSection,
                  items: _sectionList,
                  onChanged: (value) {
                    setState(() {
                      selectedSection = value;
                    });
                  },
                  hintText: "--Select Section",
                ),
                const SizedBox(height: 16),
                Text("Subject", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                const SizedBox(height: 8),
                DropDownBox(
                  value: selectedSubject,
                  items: _subjectList,
                  onChanged: (value) {
                    setState(() {
                      selectedSubject = value;
                    });
                  },
                  hintText: "--Select Subject",
                ),
                const SizedBox(height: 16),
                Text("Teacher", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                const SizedBox(height: 8),
                DropDownBox(
                  value: selectedTeacher,
                  items: _teacherList,
                  onChanged: (value) {
                    setState(() {
                      selectedTeacher = value;
                    });
                  },
                  hintText: "--Select Teacher",
                ),
                const SizedBox(height: 16),
                Text("Weekdays", style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
                const SizedBox(height: 8),
                DropDownBox(
                  value: selectedWeekday,
                  items: _weekdayList,
                  onChanged: (value) {
                    setState(() {
                      selectedWeekday = value;
                    });
                  },
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
                              onPressed: () =>
                                  _selectTime(context, isStartTime: true),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(color: theme.hintColor))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    startTime?.format(context) ?? "__:__:__",
                                    style: TextStyle(
                                        color: theme.hintColor, fontSize: 23),
                                  ),
                                  Icon(Icons.access_time,
                                      color: theme.hintColor),
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
                              onPressed: () =>
                                  _selectTime(context, isStartTime: false),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(color: theme.hintColor))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    endTime?.format(context) ?? "__:__:__",
                                    style: TextStyle(
                                        color: theme.hintColor, fontSize: 23),
                                  ),
                                  Icon(Icons.access_time,
                                      color: theme.hintColor),
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
                        height: 40,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    theme.colorScheme.onPrimary.withAlpha(25),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                            child: Text("Cancel",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: theme.colorScheme.onPrimary))),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                            onPressed: _isSaving ? null : _addSchedule,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                            child: _isSaving
                                ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),)
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        "Add Schedule",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: theme.colorScheme.onPrimary),
                                      ),
                                    ),
                                  ],
                                )),
                      ),
                    ),
                  ],
                ),
              ],
            ));
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
        items:
            items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ));
  }
}
