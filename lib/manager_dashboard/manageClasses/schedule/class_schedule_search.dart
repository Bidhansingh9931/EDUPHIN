import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

import 'searchSchedule/daily_class_schedule.dart';

// --- Data Models from API ---
class ApiClass {
  final int id;
  final String? name;
  ApiClass({required this.id, required this.name});

  factory ApiClass.fromJson(Map<String, dynamic> json) {
    return ApiClass(id: json['id'], name: json['name']);
  }
}

class ApiSection {
  final int id;
  final String? name;
  ApiSection({required this.id, required this.name});

  // Assuming the 'name' key holds the section name, e.g., "A", "B".
  factory ApiSection.fromJson(Map<String, dynamic> json) {
    return ApiSection(id: json['id'], name: json['name']);
  }
}


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
  String _error = '';

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
          final List<dynamic> classData = data['classes'] ?? [];
          final List<dynamic> sectionData = data['sections'] ?? [];

          final List<String> fetchedClasses = classData
              .map((json) => ApiClass.fromJson(json).name)
              .whereType<String>()
              .toList();
          final List<String> fetchedSections = sectionData
              .map((json) => ApiSection.fromJson(json).name)
              .whereType<String>()
              .toList();

          setState(() {
            _classList = fetchedClasses;
            _sectionList = fetchedSections;
            _selectedClass = fetchedClasses.isNotEmpty ? fetchedClasses.first : null;
            _selectedSection = fetchedSections.isNotEmpty ? fetchedSections.first : null;
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
            onPressed: _isLoading || _error.isNotEmpty ? null : _searchSchedule,
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
              ElevatedButton(onPressed: _fetchDropdownData, child: const Text("Retry"))
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
            isExpanded: true,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
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
