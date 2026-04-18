import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
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

          final List<String> fetchedClasses = classData
              .map((json) => ApiClass.fromJson(json).name)
              .whereType<String>()
              .toList();

          setState(() {
            _classList = fetchedClasses;
            _sectionList = ['A', 'B', 'C', 'D'];
            _selectedClass = fetchedClasses.isNotEmpty ? fetchedClasses.first : null;
            _selectedSection = null;
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
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Schedule Search", style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: context.font(18))),
            Text("Find daily schedules for classes", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
          ],
        ),
        centerTitle: false,
      ),
        bottomNavigationBar: _isLoading || _error.isNotEmpty
            ? null
            : SafeArea(
                child: Container(
                  padding: EdgeInsets.fromLTRB(context.spacing, context.scale(8), context.spacing, context.scale(16)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: buildActionButton(context, "SEARCH SCHEDULE", _searchSchedule),
                  ),
                ),
              ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: context.scale(48), color: theme.colorScheme.error),
              SizedBox(height: context.scale(16)),
              Text('Error: $_error', style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14)), textAlign: TextAlign.center),
              SizedBox(height: context.scale(24)),
              SizedBox(
                width: context.scale(120),
                child: buildActionButton(context, "RETRY", _fetchDropdownData),
              )
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Search Parameters",
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(18)),
                ),
                SizedBox(height: context.scale(4)),
                Text(
                  "Select details to find a specific daily schedule",
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12)),
                ),
                SizedBox(height: context.scale(24)),
                buildFilterCard(
                  context,
                  children: [
                    buildResponsiveRow(context, [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildLabel(context, "Class"),
                          buildDropdown(
                            context,
                            _classList,
                            _selectedClass,
                            (value) => setState(() => _selectedClass = value),
                            hint: "Select Class",
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildLabel(context, "Section"),
                          buildDropdown(
                            context,
                            _sectionList,
                            _selectedSection,
                            (value) => setState(() => _selectedSection = value),
                            hint: "Select Section",
                          ),
                        ],
                      ),
                    ]),
                    SizedBox(height: context.scale(16)),
                    buildLabel(context, "Date"),
                    buildDateField(context, _selectDateController, "Select Date"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
