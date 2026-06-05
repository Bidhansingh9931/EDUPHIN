import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
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
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetch();
  }

  Future<void> _loadCacheAndFetch() async {
    final cachedData = await CacheService.getCache('manager_class_schedules_meta');
    if (cachedData != null && mounted) {
      _processData(cachedData);
    }
    _fetchDropdownData();
  }

  void _processData(dynamic data) {
    final List<dynamic> classData = data['classes'] ?? [];

    final List<String> fetchedClasses = classData
        .map((json) => ApiClass.fromJson(json).name)
        .whereType<String>()
        .toList();

    setState(() {
      _classList = fetchedClasses;
      _sectionList = ['A', 'B', 'C', 'D'];
      if (_selectedClass == null && fetchedClasses.isNotEmpty) {
        _selectedClass = fetchedClasses.first;
      }
    });
  }

  Future<void> _fetchDropdownData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = _classList.isEmpty;
      _error = null;
    });

    try {
      final response = await ApiService.get('manager/class-schedules/meta');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          await CacheService.setCache('manager_class_schedules_meta', data);
          if (mounted) {
            _processData(data);
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to load metadata');
        }
      } else {
        throw Exception('Failed to load data. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
        ErrorHandler.showError(context, e);
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
      bottomNavigationBar: _isLoading || _error != null
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
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _classList.isNotEmpty,
        error: _error,
        onRetry: _fetchDropdownData,
        skeleton: _buildSkeleton(),
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: context.scale(30), width: context.scale(200)),
          SizedBox(height: context.scale(8)),
          SkeletonBox(height: context.scale(15), width: context.scale(300)),
          SizedBox(height: context.scale(24)),
          SkeletonBox(height: context.scale(250), borderRadius: context.scale(16)),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
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
