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
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
              child: Column(
                children: [
                  if (_studentDetails != null)
                    StudentInfoCard(details: _studentDetails!),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _attendanceRecords.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return AttendanceRecordCard(record: _attendanceRecords[index]);
                    },
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
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 5),
          Text("Roll No : ${details.rollNo}", style: theme.textTheme.bodyMedium),
          const SizedBox(height: 5),
          Text("Class : ${details.className}", style: theme.textTheme.bodyMedium),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${record.date},",
                  style: theme.textTheme.bodyLarge,
                ),
                Text(record.day, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
          Column(
            children: [
              Text("Attended: ${record.attendedClasses}/${record.totalClasses}", style: theme.textTheme.bodyLarge),
              Text("Total Classes", style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
