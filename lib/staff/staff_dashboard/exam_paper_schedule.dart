import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'staff_models.dart';

class StaffExamPaperSchedulePage extends StatefulWidget {
  final String examId;
  final String examName;
  const StaffExamPaperSchedulePage({super.key, required this.examId, required this.examName});

  @override
  State<StaffExamPaperSchedulePage> createState() => _StaffExamPaperSchedulePageState();
}

class _StaffExamPaperSchedulePageState extends State<StaffExamPaperSchedulePage> {
  static const Color bgColor = Color(0xFF0D111F);
  static const Color cardColor = Color(0xFF2E365A);
  static const Color accentColor = Color(0xFF5A6482);

  late Future<Map<String, dynamic>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  void _loadSchedule() {
    setState(() {
      _scheduleFuture = ApiService.getStaffExamSchedule(widget.examId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Examination Schedule",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No schedule found", style: TextStyle(color: Colors.white38)));
          }

          final data = snapshot.data!;
          final schedules = (data['schedules'] as List).map((s) => ExamPaperSchedule.fromJson(s)).toList();

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 32),
                const Text(
                  "Examination Papers",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                if (schedules.isEmpty)
                  _buildEmptyState()
                else
                  ...schedules.map((paper) => _buildPaperCard(paper)).toList(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          const Icon(Icons.event_note_rounded, color: Colors.white70, size: 48),
          const SizedBox(height: 16),
          Text(
            widget.examName,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          const Text(
            "Full Schedule Overview",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperCard(ExamPaperSchedule paper) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paper.subject,
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today_outlined, paper.date),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.access_time_rounded, "${paper.startTime} - ${paper.endTime}"),
          if (paper.venue != null && paper.venue!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(Icons.location_on_outlined, paper.venue!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(Icons.info_outline, color: Colors.white24, size: 50),
            SizedBox(height: 16),
            Text("No papers scheduled for this exam yet.", style: TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 60),
            const SizedBox(height: 24),
            const Text(
              "Failed to load schedule",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Likely a Backend Decryption error. Ensure your Laravel index() method is encrypting the Exam ID.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E4770),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("RETRY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
