import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/view_schedule_model.dart';
import 'package:intl/intl.dart';
import 'common_widgets.dart';

class ViewClassSchedulePage extends StatefulWidget {
  const ViewClassSchedulePage({super.key});

  @override
  State<ViewClassSchedulePage> createState() => _ViewClassSchedulePageState();
}

class _ViewClassSchedulePageState extends State<ViewClassSchedulePage> {
  late Future<ViewSchedulePageData> _dataFuture;
  ClassDropdownItem? _selectedClass;
  SectionDropdownItem? _selectedSection;
  List<SectionDropdownItem> _filteredSections = [];
  List<ScheduleEntry> _filteredSchedules = [];

  @override
  void initState() {
    super.initState();
    _dataFuture = ApiService.getViewSchedulePageData();
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
    if (_selectedClass == null || _selectedSection == null) return;

    _dataFuture.then((data) {
      setState(() {
        _filteredSchedules = data.schedules
            .where((s) => s.classId == _selectedClass!.id && s.sectionId == _selectedSection!.id)
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
      });
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("View Class Schedule"),
      ),
      body: FutureBuilder<ViewSchedulePageData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final pageData = snapshot.data!;
            return _buildContent(pageData);
          } else {
            return const Center(child: Text("No data found"));
          }
        },
      ),
    );
  }

  Widget _buildContent(ViewSchedulePageData pageData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSelectionCard(pageData),
            if (_filteredSchedules.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  "Weekly Schedule",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              _buildScheduleCards(pageData),
            ] else if (_selectedSection != null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "No classes scheduled for this selection",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(ViewSchedulePageData pageData) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Class", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                Text(" *", style: TextStyle(color: Colors.red.shade700, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            buildDropdown(
                context,
                pageData.classes.map((e) => e.name).toList(),
                _selectedClass?.name,
                (newValue) {
                  final selectedClass = newValue == null ? null : pageData.classes.firstWhere((c) => c.name == newValue);
                  _onClassSelected(selectedClass, pageData.sections);
                }),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Section", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                Text(" *", style: TextStyle(color: Colors.red.shade700, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            buildDropdown(
                context,
                _filteredSections.map((e) => e.name).toList(),
                _selectedSection?.name,
                (newValue) {
                  setState(() {
                    _selectedSection = newValue == null ? null : _filteredSections.firstWhere((s) => s.name == newValue);
                  });
                }),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _showSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3b66cf),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.search, size: 20),
                label: const Text("SHOW", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
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
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: const Color(0xFF4a69bd),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: daySchedules.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      "No classes scheduled",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15, fontStyle: FontStyle.italic),
                    ),
                  )
                : Column(
                    children: daySchedules.map((s) {
                      final subject = subjects.firstWhere((sub) => sub.id == s.subjectId, orElse: () => SubjectInfo(id: -1, name: 'N/A'));
                      final teacher = teachers.firstWhere((t) => t.id == s.teacherId, orElse: () => TeacherInfo(id: -1, name: 'Unknown'));
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.light ? Colors.grey.shade50 : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                                    style: const TextStyle(color: Color(0xFF3b66cf), fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "${_formatTime(s.startTime)} - ${_formatTime(s.endTime)}",
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 18, color: Color(0xFF27ae60)),
                                const SizedBox(width: 8),
                                Text(
                                  teacher.name,
                                  style: const TextStyle(color: Color(0xFF27ae60), fontWeight: FontWeight.w600, fontSize: 15),
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
