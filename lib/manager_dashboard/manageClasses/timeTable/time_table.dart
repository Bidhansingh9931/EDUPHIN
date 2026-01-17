import 'package:eduphin/manager_dashboard/manageClasses/timeTable/show_schedule.dart';
import 'package:flutter/material.dart';

import 'add_new_schedule.dart';

class TimeTableClassesPage extends StatefulWidget {
  const TimeTableClassesPage({super.key});

  @override
  State<StatefulWidget> createState() => _TimeTableClassesPageState();
}

class _TimeTableClassesPageState extends State<TimeTableClassesPage> {
  bool _isLoading = true;
  String? _selectedClass;
  String? _selectedSection;
  List<String> _classList = [];
  List<String> _sectionList = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    // Simulate API call to fetch dropdown data.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));

    final List<String> fetchedClasses = [
      "Class 1",
      "Class 2",
      "Class 3",
      "Class 4",
      "Class 5",
      "Class 6",
    ];
    final List<String> fetchedSections = ["A", "B", "C", "D"];

    if (mounted) {
      setState(() {
        _classList = fetchedClasses;
        _sectionList = fetchedSections;
        _selectedClass = fetchedClasses.first;
        _selectedSection = fetchedSections.first;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Time Table"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 115),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddNewSchedulePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                  ),
                  child: const Text("Add New Schedule",
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Class",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: theme.colorScheme.onPrimary),
                              ),
                              const SizedBox(height: 8),
                              if (_selectedClass != null)
                                DropDownBox(
                                  key: ValueKey(_selectedClass),
                                  initialValue: _selectedClass!,
                                  items: _classList,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedClass = value;
                                        // Optional: You might want to fetch sections for the selected class here.
                                      });
                                    }
                                  },
                                  hintText: "--Select Class",
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Section",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: theme.colorScheme.onPrimary),
                              ),
                              const SizedBox(height: 8),
                              if (_selectedSection != null)
                                DropDownBox(
                                  key: ValueKey(_selectedSection),
                                  initialValue: _selectedSection!,
                                  items: _sectionList,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedSection = value;
                                      });
                                    }
                                  },
                                  hintText: "--Select Section",
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 60, left: 16, right: 16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ShowSchedulePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text("Show Schedule",
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
        ),
      ),
    );
  }
}

class DropDownBox extends StatelessWidget {
  final String initialValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  const DropDownBox({
    super.key,
    required this.initialValue,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
        value: initialValue,
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
