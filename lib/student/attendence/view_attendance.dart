import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _attendanceData;
  final Map<int, bool> _subjectOpenStates = {};

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getStudentAttendance();
      setState(() {
        _attendanceData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xff0a1230),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_attendanceData == null) {
      return const Scaffold(
        backgroundColor: Color(0xff0a1230),
        body: Center(child: Text("No data found", style: TextStyle(color: Colors.white))),
      );
    }

    final student = _attendanceData!['student'];
    final percentage = _attendanceData!['attendance_percentage'];
    final presentCount = _attendanceData!['present_count'];
    final totalCount = _attendanceData!['total_count'];
    final subjectWise = _attendanceData!['subject_wise_attendance'] as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xff0a1230),
      appBar: AppBar(
        backgroundColor: const Color(0xff0a1230),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Attendance Report",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAttendance,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIXED: Added null-safe access ?. and ??
              Text(student['user']?['name'] ?? "Student",
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 4),
              Text("Roll No. ${student['roll_no'] ?? 'N/A'}",
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text("Class ID: ${student['class_id'] ?? 'N/A'}",
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),

              /// TOTAL CLASS DAYS
              statsCard(
                Icons.calendar_month,
                totalCount.toString(),
                "Total Class Days",
              ),
              const SizedBox(height: 15),

              /// DAYS PRESENT
              statsCard(
                Icons.person,
                presentCount.toString(),
                "Days Present",
              ),
              const SizedBox(height: 15),

              /// PERCENTAGE
              statsCard(
                Icons.show_chart,
                "$percentage%",
                "Attendance Percentage",
              ),

              const SizedBox(height: 25),
              const Text(
                "Attendance Records",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Detailed attendance log, grouped by subject.",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),

              /// SUBJECT WISE CARDS
              ...subjectWise.entries.map((entry) {
                final subjectId = int.tryParse(entry.key) ?? 0;
                final List<dynamic> records = entry.value;
                final subjectName = records.isNotEmpty ? (records.first['subject']?['name'] ?? 'Subject $subjectId') : 'Subject $subjectId';
                
                final int sPresent = records.where((r) => r['status'] == 'present').length;
                final int sTotal = records.length;
                final double sPercent = sTotal > 0 ? (sPresent / sTotal) * 100 : 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: subjectCard(
                    subjectName,
                    "${sPercent.toStringAsFixed(2)}% Attendance ($sPresent/$sTotal)",
                    _subjectOpenStates[subjectId] ?? false,
                    () {
                      setState(() {
                        _subjectOpenStates[subjectId] = !(_subjectOpenStates[subjectId] ?? false);
                      });
                    },
                    records.asMap().entries.map((e) {
                      final idx = e.key + 1;
                      final r = e.value;
                      return attendanceRow(
                        idx.toString(),
                        _formatDate(r['date']),
                        r['time_slot'] ?? "N/A",
                        r['status'] ?? "N/A",
                        r['remarks'] ?? "-",
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  /// STATS CARD
  Widget statsCard(IconData icon, String value, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xff3c4566),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          )
        ],
      ),
    );
  }

  /// SUBJECT CARD
  Widget subjectCard(
      String subject,
      String percent,
      bool open,
      VoidCallback onTap,
      List<DataRow> rows) {

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff3c4566),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// HEADER
          ListTile(
            title: Text(subject,
                style: const TextStyle(color: Colors.white)),
            subtitle: Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(percent,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            trailing: Icon(
              open ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
            ),
            onTap: onTap,
          ),

          /// TABLE
          if (open)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text("#", style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text("Date", style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text("Timing", style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text("Status", style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text("Remarks", style: TextStyle(color: Colors.white))),
                ],
                rows: rows,
              ),
            )
        ],
      ),
    );
  }

  /// ATTENDANCE ROW
  DataRow attendanceRow(
      String no, String date, String time, String status, String remarks) {

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'present': statusColor = Colors.green; break;
      case 'leave': statusColor = Colors.orange; break;
      default: statusColor = Colors.red;
    }

    return DataRow(cells: [
      DataCell(Text(no, style: const TextStyle(color: Colors.white))),
      DataCell(Text(date, style: const TextStyle(color: Colors.white))),
      DataCell(Text(time, style: const TextStyle(color: Colors.white))),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
      DataCell(Text(remarks, style: const TextStyle(color: Colors.white))),
    ]);
  }
}
