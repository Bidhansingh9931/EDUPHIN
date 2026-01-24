import 'package:eduphin/manager_dashboard/manageClasses/timeTable/show_schedule.dart';
import 'package:flutter/material.dart';

import 'add_new_schedule.dart';

class TimeTableClassesPage extends StatefulWidget {
  const TimeTableClassesPage({super.key});

  @override
  State<StatefulWidget> createState() => _TimeTableClassesPageState();
}

class _TimeTableClassesPageState extends State<TimeTableClassesPage> {
  final _formKey = GlobalKey<FormState>();
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
    await Future.delayed(const Duration(seconds: 1));

    final List<String> fetchedClasses = [
      "Class 1", "Class 2", "Class 3", "Class 4", "Class 5", "Class 6",
    ];
    final List<String> fetchedSections = ["A", "B", "C", "D"];

    if (mounted) {
      setState(() {
        _classList = fetchedClasses;
        _sectionList = fetchedSections;
        // Set initial value only if lists are not empty
        if (_classList.isNotEmpty) _selectedClass = _classList.first;
        if (_sectionList.isNotEmpty) _selectedSection = _sectionList.first;
        _isLoading = false;
      });
    }
  }

  void _showSchedule() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShowSchedulePage(
            className: _selectedClass!,
            section: _selectedSection!,
          ),
        ),
      );
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showSchedule,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Show Schedule"),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AddNewSchedulePage()),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Add New Schedule"),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              foregroundColor: theme.colorScheme.onSurface,
                              side: BorderSide(color: theme.dividerColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text("Select Class and Section to view Time Table", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          theme,
                          label: "Class",
                          value: _selectedClass,
                          items: _classList,
                          onChanged: (value) => setState(() => _selectedClass = value),
                          hint: "--Select Class",
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          theme,
                          label: "Section",
                          value: _selectedSection,
                          items: _sectionList,
                          onChanged: (value) => setState(() => _selectedSection = value),
                          hint: "--Select Section",
                        ),
                        const SizedBox(height: 80), // Padding for FAB
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown(
    ThemeData theme,
      {required String label,
      String? value,
      required List<String> items,
      required ValueChanged<String?> onChanged,
      required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) => value == null ? 'Please make a selection' : null,
        ),
      ],
    );
  }
}


// Kept original DropDownBox but it is no longer used. Can be removed.
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
