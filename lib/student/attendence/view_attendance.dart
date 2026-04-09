import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class AttendanceReportPage extends StatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  // Theme Colors
  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);

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
          SnackBar(content: Text("Error fetching attendance: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Attendance Report",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _fetchAttendance,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAttendance,
        color: _primary,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: _primary))
            : _attendanceData == null
                ? const Center(child: Text("No data found", style: TextStyle(color: Colors.white70)))
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStudentHeader(),
                        const SizedBox(height: 24),
                        _buildStatsGrid(),
                        const SizedBox(height: 32),
                        const Row(
                          children: [
                            Icon(Icons.list_alt, color: Colors.white70, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Subject-wise Records",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Detailed attendance log, grouped by subject.",
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        _buildSubjectWiseList(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildStudentHeader() {
    final student = _attendanceData!['student'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: _primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['user']?['name'] ?? "Student",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Roll No: ${student['roll_no'] ?? 'N/A'} • Class: ${student['class_id'] ?? 'N/A'}",
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final percentage = _attendanceData!['attendance_percentage'];
    final presentCount = _attendanceData!['present_count'];
    final totalCount = _attendanceData!['total_count'];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statsCard("Total Days", totalCount.toString(), Icons.calendar_month, Colors.blueAccent)),
            const SizedBox(width: 16),
            Expanded(child: _statsCard("Present", presentCount.toString(), Icons.check_circle_outline, Colors.greenAccent)),
          ],
        ),
        const SizedBox(height: 16),
        _statsCard(
          "Overall Percentage",
          "$percentage%",
          Icons.analytics_outlined,
          _primary,
          isWide: true,
          progress: (double.tryParse(percentage.toString()) ?? 0) / 100,
        ),
      ],
    );
  }

  Widget _statsCard(String label, String value, IconData icon, Color color, {bool isWide = false, double? progress}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color.withValues(alpha: 0.8), size: 18),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
          ),
          if (progress != null) ...[
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: _secondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSubjectWiseList() {
    final subjectWiseData = _attendanceData!['subject_wise_attendance'];
    if (subjectWiseData == null) return const SizedBox();
    
    final Map<String, dynamic> subjectWise = Map<String, dynamic>.from(subjectWiseData);
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subjectWise.length,
      itemBuilder: (context, index) {
        final entry = subjectWise.entries.elementAt(index);
        final subjectId = int.tryParse(entry.key) ?? 0;
        final List<dynamic> records = entry.value;
        final subjectName = records.isNotEmpty ? (records.first['subject']?['name'] ?? 'Subject $subjectId') : 'Subject $subjectId';

        final int sPresent = records.where((r) => r['status'].toString().toLowerCase() == 'present').length;
        final int sTotal = records.length;
        final double sPercent = sTotal > 0 ? (sPresent / sTotal) * 100 : 0;
        final bool isOpen = _subjectOpenStates[subjectId] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isOpen ? _primary.withValues(alpha: 0.3) : Colors.white12),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _subjectOpenStates[subjectId] = !isOpen),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "${sPercent.toInt()}%",
                            style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(subjectName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text("$sPresent / $sTotal sessions attended", style: const TextStyle(color: Colors.white38, fontSize: 13)),
                          ],
                        ),
                      ),
                      Icon(isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white38),
                    ],
                  ),
                ),
              ),
              if (isOpen) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                if (records.isEmpty)
                   const Padding(
                     padding: EdgeInsets.all(20),
                     child: Text("No records available", style: TextStyle(color: Colors.white24, fontSize: 13)),
                   )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    padding: const EdgeInsets.all(20),
                    separatorBuilder: (context, i) => const SizedBox(height: 16),
                    itemBuilder: (context, rIndex) {
                      final r = records[rIndex];
                      return _buildAttendanceRecordRow(r, rIndex + 1);
                    },
                  ),
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceRecordRow(dynamic r, int index) {
    final status = (r['status'] ?? "N/A").toString().toLowerCase();
    Color statusColor = Colors.redAccent;
    if (status == 'present') statusColor = Colors.greenAccent;
    if (status == 'leave') statusColor = Colors.orangeAccent;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _secondary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(index.toString(), style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatDate(r['date']), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(r['time_slot'] ?? "N/A", style: const TextStyle(color: Colors.white38, fontSize: 12)),
              if (r['remarks'] != null && r['remarks'].toString().isNotEmpty && r['remarks'] != "-")
                 Padding(
                   padding: const EdgeInsets.only(top: 4),
                   child: Text(r['remarks'], style: const TextStyle(color: Colors.white24, fontSize: 11, fontStyle: FontStyle.italic)),
                 ),
            ],
          ),
        ),
        _statusBadge(status.toUpperCase(), statusColor),
      ],
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
}
