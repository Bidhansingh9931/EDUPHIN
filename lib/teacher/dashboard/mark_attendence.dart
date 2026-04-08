import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/attendance_model.dart';
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
  Future<void>? _attendanceDataFuture;
  List<StudentForAttendance> _students = [];
  Map<int, AttendanceRecord> _attendanceRecords = {};
  final String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? _error;

  @override
  void initState() {
    super.initState();
    _attendanceDataFuture = _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    try {
      final data = await ApiService.getAttendanceData(widget.schedule.id, _date);
      if (mounted && data['status'] == true) {
        setState(() {
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
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load attendance: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
        appBar: AppBar(
          title: const Text("Mark Attendance"),
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: _attendanceDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _students.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (_error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: context.pagePadding,
                      itemCount: _students.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) return _buildHeaderCard(context);
                        return _buildStudentCard(index - 1);
                      },
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _submitAttendance,
                child: const Text("SUBMIT ATTENDANCE"),
              ),
            )
          ],
        ));
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.schedule.subject?['name'] ?? 'Class'} - ${widget.schedule.section?['name'] ?? 'Section'}",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7), size: 16),
                const SizedBox(width: 8),
                Text(
                  "Date: ${DateFormat.yMMMMd().format(DateTime.parse(_date))}",
                  style: TextStyle(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7), fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(int index) {
    final theme = Theme.of(context);
    final student = _students[index];
    final record = _attendanceRecords[student.id]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text("${index + 1}", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Roll No: ${student.rollNo}", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ["Present", "Absent", "Leave"].map((status) {
                bool isSelected = record.status == status;
                Color statusColor = status == "Present" ? Colors.green : status == "Absent" ? Colors.red : Colors.orange;
                
                return InkWell(
                  onTap: () => setState(() => record.status = status),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? statusColor.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? statusColor : theme.dividerColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) Icon(Icons.check_circle, size: 14, color: statusColor),
                        if (isSelected) const SizedBox(width: 4),
                        Text(status, style: TextStyle(
                          color: isSelected ? statusColor : theme.hintColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: record.remarks,
              decoration: const InputDecoration(
                hintText: "Add remarks...",
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: const TextStyle(fontSize: 13),
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
          const SnackBar(content: Text('Attendance submitted successfully!'), backgroundColor: Colors.green)
        );
        Navigator.pop(context);
      }
    } catch (e) {
       if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit attendance: $e'), backgroundColor: Colors.red)
        );
       }
    }
  }
}
