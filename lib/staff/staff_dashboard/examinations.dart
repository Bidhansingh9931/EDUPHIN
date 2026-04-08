import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'staff_models.dart';
import 'exam_paper_schedule.dart';

class StaffExaminationsPage extends StatefulWidget {
  const StaffExaminationsPage({super.key});

  @override
  State<StaffExaminationsPage> createState() => _StaffExaminationsPageState();
}

class _StaffExaminationsPageState extends State<StaffExaminationsPage> {
  static const Color bgColor = Color(0xFF0D111F);
  static const Color cardColor = Color(0xFF2E365A);

  late Future<List<Exam>> _examsFuture;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  void _loadExams() {
    setState(() {
      _examsFuture = ApiService.getStaffExams();
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
        title: const Text("Examinations", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadExams(),
        color: Colors.white,
        backgroundColor: cardColor,
        child: FutureBuilder<List<Exam>>(
          future: _examsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
            } else if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No exams available", style: TextStyle(color: Colors.white38)));
            }

            final exams = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(20.0),
              itemCount: exams.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _buildExamCard(exams[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExamCard(Exam exam) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_outlined, color: Colors.white70, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(exam.name, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text("Status: ", style: TextStyle(color: Colors.white54, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(exam.status?.toUpperCase() ?? 'ACTIVE', 
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StaffExamPaperSchedulePage(
                      // Uses encryptedId if backend provides it, otherwise raw ID
                      examId: exam.encryptedId ?? exam.id.toString(), 
                      examName: exam.name
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E4770),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text("VIEW FULL SCHEDULE", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.1)),
            ),
          ),
        ],
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
            const Icon(Icons.error_outline_rounded, color: Colors.white12, size: 60),
            const SizedBox(height: 16),
            const Text("Oops! Failed to load exams", 
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
