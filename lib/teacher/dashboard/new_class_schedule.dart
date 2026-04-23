import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/view_schedule_model.dart';
import 'package:intl/intl.dart';
import 'common_widgets.dart' as teacher_common;

class ViewClassSchedulePage extends StatefulWidget {
  const ViewClassSchedulePage({super.key});

  @override
  State<ViewClassSchedulePage> createState() => _ViewClassSchedulePageState();
}

class _ViewClassSchedulePageState extends State<ViewClassSchedulePage> {
  ViewSchedulePageData? _pageData;
  bool _isLoading = true;
  String? _error;
  ClassDropdownItem? _selectedClass;
  SectionDropdownItem? _selectedSection;
  List<SectionDropdownItem> _filteredSections = [];
  List<ScheduleEntry> _filteredSchedules = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    const cacheKey = 'view_class_schedule_data';

    try {
      // Load from cache first
      final cachedData = await TeacherCacheService.load(cacheKey);
      if (cachedData != null && cachedData is Map<String, dynamic>) {
        setState(() {
          _pageData = ViewSchedulePageData.fromJson(cachedData);
          _isLoading = false;
        });
      }

      // Fetch fresh data
      final freshData = await ApiService.getViewSchedulePageData();
      await TeacherCacheService.save(cacheKey, freshData.toJson());

      if (mounted) {
        setState(() {
          _pageData = freshData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        if (_pageData == null) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update schedule data: $e")),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _onClassSelected(ClassDropdownItem? selectedClass, List<SectionDropdownItem> allSections) {
    setState(() {
      _selectedClass = selectedClass;
      _selectedSection = null;
      if (selectedClass != null) {
        // Filter sections by classId
        _filteredSections = allSections.where((s) => s.classId == selectedClass.id).toList();
        
        // Fallback: If no sections match the classId, it's possible they aren't linked in the API response.
        // In that case, we show all sections if they all have classId as 0 (indicating generic sections).
        if (_filteredSections.isEmpty && allSections.isNotEmpty) {
          if (allSections.every((s) => s.classId == 0)) {
            _filteredSections = allSections;
          }
        }
      } else {
        _filteredSections = [];
      }
      _filteredSchedules = [];
    });
  }

  void _showSchedule() {
    if (_selectedClass == null || _selectedSection == null || _pageData == null) return;

    setState(() {
      _filteredSchedules = _pageData!.schedules
          .where((s) => s.classId == _selectedClass!.id && s.sectionId == _selectedSection!.id)
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }

  String _formatTime(String time) {
    try {
      final DateTime dt = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("h:mm a").format(dt);
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("View Class Schedule"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: teacher_common.TeacherLoadingWrapper(
          isLoading: _isLoading,
          hasData: _pageData != null,
          skeleton: _buildSkeleton(),
          child: _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error', style: TextStyle(fontSize: context.font(14))),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _fetchData, child: const Text("Retry"))
                    ],
                  ),
                )
              : _pageData == null
                  ? const Center(child: Text("No data found"))
                  : Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: context.scale(800)),
                        child: _buildContent(_pageData!),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Column(
        children: [
          teacher_common.TeacherSkeleton(height: context.scale(250), borderRadius: BorderRadius.circular(context.scale(16))),
          SizedBox(height: context.spacing * 2),
          teacher_common.TeacherSkeleton(height: context.scale(100), borderRadius: BorderRadius.circular(context.scale(12))),
          SizedBox(height: context.spacing),
          teacher_common.TeacherSkeleton(height: context.scale(100), borderRadius: BorderRadius.circular(context.scale(12))),
        ],
      ),
    );
  }

  Widget _buildContent(ViewSchedulePageData pageData) {
    final theme = context.theme;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: context.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectionCard(pageData),
          if (_filteredSchedules.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.spacing * 1.5),
              child: Text(
                "Weekly Schedule",
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
              ),
            ),
            _buildScheduleCards(pageData),
          ] else if (_selectedSection != null)
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: context.scale(40)),
                child: Text(
                  "No classes scheduled for this selection",
                  style: TextStyle(color: theme.hintColor, fontSize: context.font(16)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard(ViewSchedulePageData pageData) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            teacher_common.buildLabel(context, "Class *"),
            teacher_common.buildDropdown(
                context,
                pageData.classes.map((e) => e.name).toList(),
                _selectedClass?.name,
                (newValue) {
                  final selectedClass = newValue == null ? null : pageData.classes.firstWhere((c) => c.name == newValue);
                  _onClassSelected(selectedClass, pageData.sections);
                },
                hint: "Select Class"),
            SizedBox(height: context.spacing),
            teacher_common.buildLabel(context, "Section *"),
            teacher_common.buildDropdown(
                context,
                _filteredSections.map((e) => e.name).toList(),
                _selectedSection?.name,
                (newValue) {
                  setState(() {
                    _selectedSection = newValue == null ? null : _filteredSections.firstWhere((s) => s.name == newValue);
                  });
                },
                hint: "Select Section"),
            SizedBox(height: context.spacing * 1.5),
            teacher_common.buildActionButton(context, "SHOW SCHEDULE", _showSchedule),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCards(ViewSchedulePageData pageData) {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    
    return Column(
      children: weekdays.map((day) {
        final daySchedules = _filteredSchedules.where((s) => s.weekday.toLowerCase() == day.toLowerCase()).toList();
        return _buildDayCard(day, daySchedules, pageData.subjects, pageData.teachers);
      }).toList(),
    );
  }

  Widget _buildDayCard(String day, List<ScheduleEntry> daySchedules, List<SubjectInfo> subjects, List<TeacherInfo> teachers) {
    final theme = context.theme;
    return Container(
      margin: EdgeInsets.only(bottom: context.spacing * 1.5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(12)),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: context.scale(12)),
            color: theme.colorScheme.primaryContainer,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: context.font(16)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.spacing),
            child: daySchedules.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: context.spacing * 2),
                    child: Text(
                      "No classes scheduled",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.hintColor, fontSize: context.font(14), fontStyle: FontStyle.italic),
                    ),
                  )
                : Column(
                    children: daySchedules.map((s) {
                      final subject = subjects.firstWhere((sub) => sub.id == s.subjectId, orElse: () => SubjectInfo(id: -1, name: 'N/A'));
                      final teacher = teachers.firstWhere((t) => t.id == s.teacherId, orElse: () => TeacherInfo(id: -1, name: 'Unknown'));
                      return Container(
                        margin: EdgeInsets.only(bottom: context.scale(12)),
                        padding: EdgeInsets.all(context.spacing),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(context.scale(10)),
                          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    subject.name,
                                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: context.font(15)),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(6)),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(context.scale(6)),
                                  ),
                                  child: Text(
                                    "${_formatTime(s.startTime)} - ${_formatTime(s.endTime)}",
                                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.scale(12)),
                            Row(
                              children: [
                                Icon(Icons.person, size: context.scale(16), color: theme.colorScheme.secondary),
                                SizedBox(width: context.scale(8)),
                                Text(
                                  teacher.name,
                                  style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.w600, fontSize: context.font(13)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
