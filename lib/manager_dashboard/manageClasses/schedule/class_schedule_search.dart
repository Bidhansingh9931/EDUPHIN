import 'package:flutter/material.dart';

import 'searchSchedule/daily_class_schedule.dart';

class ClassScheduleSearchPage extends StatefulWidget {
  const ClassScheduleSearchPage({super.key});

  @override
  State<StatefulWidget> createState() => _ClassScheduleSearchPageState();
}

class _ClassScheduleSearchPageState extends State<ClassScheduleSearchPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _selectDateController = TextEditingController();

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

  @override
  void dispose() {
    _selectDateController.dispose();
    super.dispose();
  }

  Future<void> _fetchDropdownData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final List<String> fetchedClasses = ["Class 1", "Class 2", "Class 3", "Class 4"];
    final List<String> fetchedSections = ["A", "B", "C", "D"];

    if (mounted) {
      setState(() {
        _classList = fetchedClasses;
        _sectionList = fetchedSections;
        _selectedClass = fetchedClasses.isNotEmpty ? fetchedClasses.first : null;
        _selectedSection = fetchedSections.isNotEmpty ? fetchedSections.first : null;
        _isLoading = false;
      });
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

    if (pickedDate != null && mounted) {
      controller.text = "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
    }
  }

  void _searchSchedule() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DailyClassSchedulePage(
            className: _selectedClass!,
            section: _selectedSection!,
            date: _selectDateController.text,
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
        title: const Text("Class Schedule Search"),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _searchSchedule,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Search"),
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
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDropdown(
                              theme,
                              label: "Class",
                              value: _selectedClass,
                              items: _classList,
                              onChanged: (value) => setState(() => _selectedClass = value),
                              hint: "--Select Class",
                            ),
                            const SizedBox(width: 16),
                            _buildDropdown(
                              theme,
                              label: "Section",
                              value: _selectedSection,
                              items: _sectionList,
                              onChanged: (value) => setState(() => _selectedSection = value),
                              hint: "--Select Section",
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text("Date", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _selectDateController,
                          readOnly: true,
                          onTap: () => selectDate(context, _selectDateController),
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
                          validator: (value) =>
                              value!.isEmpty ? 'Please select a date' : null,
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
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
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
      ),
    );
  }
}
