import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class ExamSchedulePage extends StatefulWidget {
  const ExamSchedulePage({super.key});

  @override
  State<ExamSchedulePage> createState() => _ExamSchedulePageState();
}

class _ExamSchedulePageState extends State<ExamSchedulePage> {
  List<dynamic> _exams = [];
  List<dynamic> _registeredExamIds = [];
  Map<int, String> _registrationHashes = {};
  bool _isLoading = true;
  final Map<int, bool> _expandedExams = {};

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getStudentExams();
      
      List<dynamic> admitCards = [];
      try {
        admitCards = await ApiService.getAdmitCards();
      } catch (e) {
        debugPrint("Error fetching admit cards: $e");
      }

      setState(() {
        _exams = data['availableExams'] ?? [];
        
        // Ensure registered IDs are integers for comparison
        final rawIds = data['registeredExamIds'] as List?;
        _registeredExamIds = rawIds?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? [];
        
        // Map exam_id to registration id_hash for admit card access
        _registrationHashes = {
          for (var reg in admitCards)
            if (reg['exam_id'] != null)
              reg['exam_id'] as int: reg['id_hash']?.toString() ?? reg['id'].toString()
        };

        _isLoading = false;
        
        // Default first exam to open if it exists and nothing is expanded yet
        if (_exams.isNotEmpty && _expandedExams.isEmpty) {
          _expandedExams[_exams[0]['id']] = true;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching exams: $e")),
        );
      }
    }
  }

  Future<void> _registerExam(dynamic exam) async {
    try {
      // Use id_hash if available, otherwise fallback to id
      final String examIdToUse = exam['id_hash']?.toString() ?? exam['id'].toString();
      
      await ApiService.registerForExam(examIdToUse);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully registered for exam!")),
        );
        _fetchExams(); // Refresh to update registration status and UI
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: $e")),
        );
      }
    }
  }

  void _viewAdmitCard(int examId) {
    final hash = _registrationHashes[examId];
    if (hash != null) {
      // This is where you would navigate to an Admit Card details page or trigger a PDF view
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Loading Admit Card (ID: $hash)...")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration data not found.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0a1230),
      appBar: AppBar(
        backgroundColor: const Color(0xff0a1230),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Exam List & Schedule",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _exams.isEmpty
              ? const Center(child: Text("No exams available", style: TextStyle(color: Colors.white70)))
              : RefreshIndicator(
                  onRefresh: _fetchExams,
                  color: const Color(0xff2ea44f),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: _exams.map((exam) {
                        final bool isRegistered = _registeredExamIds.contains(exam['id']);
                        final bool isOpen = _expandedExams[exam['id']] ?? false;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: examCard(
                            exam,
                            isRegistered,
                            isOpen,
                            () {
                              setState(() {
                                _expandedExams[exam['id']] = !isOpen;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
    );
  }

  Widget examCard(
      dynamic exam,
      bool registered,
      bool open,
      VoidCallback onTap) {
    
    final startDateStr = exam['start_date'];
    final endDateStr = exam['end_date'];
    
    String formattedRange = "N/A";
    if (startDateStr != null && endDateStr != null) {
      try {
        DateTime start = DateTime.parse(startDateStr);
        DateTime end = DateTime.parse(endDateStr);
        formattedRange = "${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}";
      } catch (_) {}
    }

    final List<dynamic> papers = exam['papers'] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff3c4566),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          ListTile(
            title: Text(
              exam['name'] ?? 'Exam Name',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              exam['type'] ?? "Written",
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xff5f6a7a),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formattedRange,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 10),
                  ),
                ),
                const SizedBox(height: 2),
                Icon(
                  open
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            onTap: onTap,
          ),

          if (open)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description: ${exam['description'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),

                  /// PAPER SCHEDULE
                  const Row(
                    children: [
                      Icon(Icons.calendar_month,
                          color: Colors.white70, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "Paper Schedule",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// TABLE HEADER
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: const Color(0xff2f3756),
                    child: const Row(
                      children: [
                        Expanded(flex: 2, child: Text("Subject", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("Date", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("Time", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Text("Venue", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),

                  /// TABLE ROWS
                  ...papers.map((paper) {
                    final subject = paper['subject']?['name'] ?? 'N/A';
                    final date = paper['date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(paper['date'])) : 'N/A';
                    final time = "${paper['start_time'] ?? ''} - ${paper['end_time'] ?? ''}";
                    final venue = paper['venue'] ?? 'N/A';

                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white10))
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(subject, style: const TextStyle(color: Colors.white, fontSize: 11))),
                          Expanded(flex: 2, child: Text(date, style: const TextStyle(color: Colors.white, fontSize: 11))),
                          Expanded(flex: 2, child: Text(time, style: const TextStyle(color: Colors.white, fontSize: 11))),
                          Expanded(flex: 1, child: Text(venue, style: const TextStyle(color: Colors.white, fontSize: 11))),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 20),

                  /// BUTTON
                  GestureDetector(
                    onTap: registered ? null : () => _registerExam(exam),
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        color: registered
                            ? Colors.grey.withValues(alpha: 0.5)
                            : const Color(0xff2ea44f),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          registered
                              ? "ALREADY REGISTERED"
                              : "REGISTER NOW",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}
