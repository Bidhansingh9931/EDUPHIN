import 'package:flutter/material.dart';

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
  const ViewAttendancePage({super.key});

  @override
  State<StatefulWidget> createState() => ViewAttendancePageState();
}

class ViewAttendancePageState extends State<ViewAttendancePage> {
  bool _isLoading = true;
  StudentDetails? _studentDetails;
  final List<AttendanceRecord> _attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    // Simulate API call to fetch data.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));

    final student = StudentDetails(
      name: "Aarav Sharma",
      rollNo: "1",
      className: "10th - A",
    );

    final records = [
      AttendanceRecord(date: "25 Jul 2025", day: "Thursday", attendedClasses: 7, totalClasses: 8),
      AttendanceRecord(date: "24 Jul 2025", day: "Wednesday", attendedClasses: 8, totalClasses: 8),
      AttendanceRecord(date: "23 Jul 2025", day: "Tuesday", attendedClasses: 4, totalClasses: 8),
      AttendanceRecord(date: "22 Jul 2025", day: "Monday", attendedClasses: 8, totalClasses: 8),
      AttendanceRecord(date: "21 Jul 2025", day: "Saturday", attendedClasses: 4, totalClasses: 4),
      AttendanceRecord(date: "19 Jul 2025", day: "Friday", attendedClasses: 6, totalClasses: 8),
      AttendanceRecord(date: "18 Jul 2025", day: "Thursday", attendedClasses: 8, totalClasses: 8),
    ];

    if (mounted) {
      setState(() {
        _studentDetails = student;
        _attendanceRecords.addAll(records);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Attendance Details"),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_sharp)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
              child: Column(
                children: [
                  if (_studentDetails != null)
                    StudentInfoCard(details: _studentDetails!),
                  const SizedBox(height: 16),
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
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
                  ?.copyWith(color: theme.colorScheme.onSurface.withAlpha(35))),
          const SizedBox(height: 5),
          Text("Class : ${details.className}",
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurface.withAlpha(35))),
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
