import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class ExamRegistrationPage extends StatefulWidget {
  const ExamRegistrationPage({super.key});

  @override
  State<ExamRegistrationPage> createState() => _ExamRegistrationPageState();
}

class _ExamRegistrationPageState extends State<ExamRegistrationPage> {
  List<dynamic> _exams = [];
  List<dynamic> _registeredExamIds = [];
  Map<int, String> _registrationHashes = {};
  bool _isLoading = true;
  final Map<int, bool> _expandedExams = {};

  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);
  final Color _headerRow = const Color(0xff2A3450);

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
        
        final rawIds = data['registeredExamIds'] as List?;
        _registeredExamIds = rawIds?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? [];
        
        _registrationHashes = {
          for (var reg in admitCards)
            if (reg['exam_id'] != null)
              (reg['exam_id'] as num).toInt(): reg['id']?.toString() ?? reg['id_hash'].toString()
        };

        _isLoading = false;
        
        if (_exams.isNotEmpty && _expandedExams.isEmpty) {
          _expandedExams[_exams[0]['id']] = true;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching exams: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _registerExam(dynamic exam) async {
    try {
      // Use plain ID as the backend no longer expects encrypted hashes
      final String examId = exam['id'].toString();
      
      await ApiService.registerForExam(examId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully registered for exam!"),
            backgroundColor: Colors.green,
          ),
        );
        _fetchExams(); 
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith("Exception: ")) {
          errorMessage = errorMessage.replaceFirst("Exception: ", "");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
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
          "Exam List & Schedule",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primary))
          : _exams.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      const Text("No exams available", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchExams,
                  color: _primary,
                  backgroundColor: _card,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: _exams.map((exam) {
                        final bool isRegistered = _registeredExamIds.contains(exam['id']);
                        final bool isOpen = _expandedExams[exam['id']] ?? false;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildExamCard(
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

  Widget _buildExamCard(dynamic exam, bool registered, bool open, VoidCallback onTap) {
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: open ? _primary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          if (open) BoxShadow(color: _primary.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam['name'] ?? 'Exam Name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exam['type'] ?? "Written Examination",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          formattedRange,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 16),
                  
                  _buildInfoRow("Description", exam['description'] ?? 'No description available.'),
                  
                  const SizedBox(height: 24),

                  /// PAPER SCHEDULE
                  Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, color: _primary, size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        "Paper Schedule",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// TABLE
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        /// TABLE HEADER
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          color: _headerRow,
                          child: const Row(
                            children: [
                              Expanded(flex: 2, child: Text("Subject", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text("Date", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text("Time", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(flex: 1, child: Text("Venue", textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),

                        /// TABLE ROWS
                        ...papers.map((paper) {
                          final subject = paper['subject']?['name'] ?? 'N/A';
                          final date = paper['date'] != null ? DateFormat('dd MMM').format(DateTime.parse(paper['date'])) : 'N/A';
                          final time = "${paper['start_time'] ?? ''}\n${paper['end_time'] ?? ''}";
                          final venue = paper['venue'] ?? 'N/A';

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05)))
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text(subject, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500))),
                                Expanded(flex: 2, child: Text(date, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10))),
                                Expanded(flex: 2, child: Text(time, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10))),
                                Expanded(flex: 1, child: Text(venue, textAlign: TextAlign.right, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10))),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: registered ? null : () => _registerExam(exam),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        disabledBackgroundColor: _secondary.withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white54,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        registered
                            ? "ALREADY REGISTERED"
                            : "REGISTER FOR EXAM",
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 13),
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

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.5),
        ),
      ],
    );
  }
}
