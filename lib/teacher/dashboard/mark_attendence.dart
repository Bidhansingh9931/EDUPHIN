import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/attendance_model.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/teacher_dashboard_model.dart';
import 'package:intl/intl.dart';

class MarkAttendancePage extends StatefulWidget {
  final ClassSchedule schedule;
  const MarkAttendancePage({super.key, required this.schedule});

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  List<StudentForAttendance> _students = [];
  Map<int, AttendanceRecord> _attendanceRecords = {};
  final String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final cacheKey = 'attendance_${widget.schedule.id}_$_date';

    try {
      // Load from cache first
      final cachedData = await TeacherCacheService.load(cacheKey);
      if (cachedData != null) {
        _processAttendanceData(cachedData);
        setState(() {
          _isLoading = false;
        });
      }

      // Fetch fresh data
      final freshData = await ApiService.getAttendanceData(widget.schedule.id, _date);
      if (freshData['status'] == true) {
        await TeacherCacheService.save(cacheKey, freshData);
        if (mounted) {
          setState(() {
            _processAttendanceData(freshData);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        if (_students.isEmpty) {
          setState(() {
            _error = "Failed to load attendance: $e";
            _isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update attendance data: $e")),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _processAttendanceData(Map<String, dynamic> data) {
    _students = (data['students'] as List)
        .map((s) => StudentForAttendance.fromJson(s))
        .toList();
    final existing = data['existingAttendance'] as Map<String, dynamic>;
    _attendanceRecords = {
      for (var student in _students)
        student.id: existing.containsKey(student.id.toString())
            ? AttendanceRecord.fromJson(existing[student.id.toString()]!)
            : AttendanceRecord(status: 'Present'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Attendance"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(1200)),
          child: Column(
            children: [
              Expanded(
                child: TeacherLoadingWrapper(
                  isLoading: _isLoading,
                  hasData: _students.isNotEmpty,
                  skeleton: _buildSkeleton(),
                  child: _error != null
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(context.spacing * 1.5),
                            child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14))),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchAttendanceData,
                          child: context.responsive(
                            ListView.builder(
                              padding: context.pagePadding,
                              itemCount: _students.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) return _buildHeaderCard(context);
                                return _buildStudentCard(index - 1);
                              },
                            ),
                            tablet: ListView(
                              padding: context.pagePadding,
                              children: [
                                _buildHeaderCard(context),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: context.spacing,
                                    mainAxisSpacing: context.spacing,
                                    childAspectRatio: 1.5,
                                  ),
                                  itemCount: _students.length,
                                  itemBuilder: (context, index) => _buildStudentCard(index),
                                ),
                              ],
                            ),
                            desktop: ListView(
                              padding: context.pagePadding,
                              children: [
                                _buildHeaderCard(context),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: context.spacing,
                                    mainAxisSpacing: context.spacing,
                                    childAspectRatio: 1.6,
                                  ),
                                  itemCount: _students.length,
                                  itemBuilder: (context, index) => _buildStudentCard(index),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(context.spacing),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
                ),
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: context.scale(400)),
                      child: ElevatedButton(
                        onPressed: _submitAttendance,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, context.scale(48)),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                        ),
                        child: Text("SUBMIT ATTENDANCE", style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: 6,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: context.spacing * 1.5),
            child: TeacherSkeleton(height: context.scale(100), borderRadius: BorderRadius.circular(context.scale(16))),
          );
        }
        return Padding(
          padding: EdgeInsets.only(bottom: context.spacing),
          child: TeacherSkeleton(height: context.scale(150), borderRadius: BorderRadius.circular(context.scale(16))),
        );
      },
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: context.spacing * 1.5),
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing * 1.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.scale(8)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(context.scale(10)),
                  ),
                  child: Icon(Icons.people_alt_outlined, color: theme.colorScheme.onPrimary, size: context.scale(22)),
                ),
                SizedBox(width: context.scale(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.schedule.subject?['name'] ?? 'Class'} - ${widget.schedule.section?['name'] ?? 'Section'}",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: context.font(18),
                        ),
                      ),
                      SizedBox(height: context.scale(4)),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: theme.colorScheme.primary.withValues(alpha: 0.7), size: context.scale(14)),
                          SizedBox(width: context.scale(8)),
                          Text(
                            DateFormat.yMMMMd().format(DateTime.parse(_date)),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary.withValues(alpha: 0.7),
                              fontSize: context.font(14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(int index) {
    final theme = context.theme;
    final student = _students[index];
    final record = _attendanceRecords[student.id]!;

    return Card(
      elevation: 0,
      margin: context.isMobile ? EdgeInsets.only(bottom: context.spacing) : EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: context.scale(44),
                  height: context.scale(44),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "${index + 1}",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(14),
                    ),
                  ),
                ),
                SizedBox(width: context.scale(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: context.font(15),
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: context.scale(2)),
                      Text(
                        "Roll No: ${student.rollNo}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: context.font(13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: context.scale(32), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["Present", "Absent", "Leave"].map((status) {
                bool isSelected = record.status == status;
                Color statusColor = status == "Present" ? const Color(0xFF10B981) : status == "Absent" ? const Color(0xFFEF4444) : const Color(0xFFF59E0B); // Emerald, Red, Amber

                return InkWell(
                  onTap: () => setState(() => record.status = status),
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: context.scale(14), vertical: context.scale(10)),
                    decoration: BoxDecoration(
                      color: isSelected ? statusColor.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(context.scale(12)),
                      border: Border.all(color: isSelected ? statusColor : theme.colorScheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) Icon(Icons.check_circle, size: context.scale(16), color: statusColor),
                        if (isSelected) SizedBox(width: context.scale(6)),
                        Text(
                          status,
                          style: TextStyle(
                            color: isSelected ? statusColor : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: context.font(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: context.scale(16)),
            TextFormField(
              initialValue: record.remarks,
              decoration: InputDecoration(
                hintText: "Add remarks...",
                contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
              style: theme.textTheme.bodySmall?.copyWith(fontSize: context.font(13), color: theme.colorScheme.onSurface),
              onChanged: (value) => record.remarks = value,
            ),
          ],
        ),
      ),
    );
  }

  void _submitAttendance() async {
    try {
      final attendanceMap = { for (var e in _attendanceRecords.entries) e.key.toString() : e.value.status };
      final remarksMap = { for (var e in _attendanceRecords.entries) e.key.toString() : e.value.remarks ?? '' };
      
      await ApiService.markAttendance(widget.schedule.id, _date, attendanceMap, remarksMap);

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance submitted successfully!'),
            backgroundColor: Color(0xFF10B981), // Emerald
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
       if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit attendance: $e'),
            backgroundColor: const Color(0xFFEF4444), // Red
          ),
        );
       }
    }
  }
}
