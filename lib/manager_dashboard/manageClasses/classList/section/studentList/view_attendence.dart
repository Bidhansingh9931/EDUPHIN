import 'dart:async';
import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- Data Models ---
class StudentDetails {
  final String name;
  final String rollNo;
  final String className;

  StudentDetails({
    required this.name,
    required this.rollNo,
    required this.className,
  });

  factory StudentDetails.fromJson(Map<String, dynamic> json) {
    // Safely combine first and last names
    final firstName = json['first_name'] ?? '';
    final lastName = json['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();

    return StudentDetails(
      name: fullName.isEmpty ? 'N/A' : fullName,
      // Check for different possible roll number keys and handle null
      rollNo: json['student_roll_no']?.toString() ?? json['roll_no']?.toString() ?? 'N/A',
      // Safely access nested class name
      className: json['class']?['name'] ?? 'N/A',
    );
  }
}

class AttendanceRecord {
  final String date;
  final String day;
  final int attendedClasses;
  final int totalClasses;

  AttendanceRecord({
    required this.date,
    required this.day,
    required this.attendedClasses,
    required this.totalClasses,
  });
}

// --- Page Widget ---
class ViewAttendancePage extends StatefulWidget {
  final int studentId;
  const ViewAttendancePage({super.key, required this.studentId});

  @override
  State<StatefulWidget> createState() => ViewAttendancePageState();
}

class ViewAttendancePageState extends State<ViewAttendancePage> {
  bool _isLoading = true;
  StudentDetails? _studentDetails;
  final List<AttendanceRecord> _attendanceRecords = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await ApiService.get('manager/attendance/student/${widget.studentId}');
      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];

          final student = StudentDetails.fromJson(data['student']);
          
          final rawAttendanceList = (data['student_attendance'] as List);

          // Group attendance records by date
          final Map<String, List<dynamic>> groupedByDate = {};
          for (var record in rawAttendanceList) {
            final date = record['date'];
            if (date != null) {
              groupedByDate.putIfAbsent(date, () => []).add(record);
            }
          }

          // Process grouped data into AttendanceRecord objects
          final processedRecords = groupedByDate.entries.map((entry) {
            final date = entry.key;
            final recordsForDay = entry.value;

            final attended = recordsForDay.where((r) => r['status'] == 'present').length;
            final total = recordsForDay.length;

            final dayOfWeek = DateFormat('EEEE').format(DateTime.parse(date));

            return AttendanceRecord(
              date: DateFormat('d MMM, yyyy').format(DateTime.parse(date)),
              day: dayOfWeek,
              attendedClasses: attended,
              totalClasses: total,
            );
          }).toList();
          
          // Sort records by date (most recent first)
          processedRecords.sort((a, b) => DateFormat('d MMM, yyyy').parse(b.date).compareTo(DateFormat('d MMM, yyyy').parse(a.date)));

          if (mounted) {
            setState(() {
              _studentDetails = student;
              _attendanceRecords.clear();
              _attendanceRecords.addAll(processedRecords);
            });
          }
        } else {
          final errorMessage = responseData['message'] ?? 'API did not return successful data.';
          throw Exception(errorMessage);
        }
      } else {
        throw Exception('Failed to load attendance data. Status Code: ${response.statusCode}');
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _error = "The connection timed out. Please try again.";
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Attendance Details"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _fetchAttendanceData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchAttendanceData,
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      );
    }
    if (_studentDetails == null) {
      return const Center(child: Text("No student details found."));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      child: Column(
        children: [
          StudentInfoCard(details: _studentDetails!),
          const SizedBox(height: 16),
          Expanded(
            child: _attendanceRecords.isEmpty
                ? const Center(child: Text("No attendance records found."))
                : LayoutBuilder(builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      return GridView.builder(
                        itemCount: _attendanceRecords.length,
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 3,
                        ),
                        itemBuilder: (context, index) {
                          return AttendanceRecordCard(
                              record: _attendanceRecords[index]);
                        },
                      );
                    } else {
                      return ListView.separated(
                        itemCount: _attendanceRecords.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return AttendanceRecordCard(
                              record: _attendanceRecords[index]);
                        },
                      );
                    }
                  }),
          ),
        ],
      ),
    );
  }
}

// --- Reusable Widgets ---
class StudentInfoCard extends StatelessWidget {
  final StudentDetails details;

  const StudentInfoCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            details.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text("Roll No : ${details.rollNo}",
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurface.withAlpha(150))),
          const SizedBox(height: 5),
          Text("Class : ${details.className}",
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurface.withAlpha(150))),
        ],
      ),
    );
  }
}

class AttendanceRecordCard extends StatelessWidget {
  final AttendanceRecord record;

  const AttendanceRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double percentage = record.totalClasses > 0
        ? record.attendedClasses / record.totalClasses
        : 0.0;
    final Color progressColor;
    if (percentage >= 0.8) {
      progressColor = Colors.green.shade400;
    } else if (percentage >= 0.5) {
      progressColor = Colors.orange.shade400;
    } else {
      progressColor = Colors.red.shade400;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  record.date,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(record.day,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.hintColor)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: percentage,
                        strokeWidth: 5,
                        backgroundColor: progressColor.withAlpha(35),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                      Center(
                        child: Text(
                          "${(percentage * 100).toStringAsFixed(0)}%",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${record.attendedClasses}/${record.totalClasses}",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Classes",
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
