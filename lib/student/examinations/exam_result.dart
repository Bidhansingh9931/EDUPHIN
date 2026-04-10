import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';

class ExamResultPage extends StatefulWidget {
  const ExamResultPage({super.key});

  @override
  State<ExamResultPage> createState() => _ExamResultPageState();
}

class _ExamResultPageState extends State<ExamResultPage> {
  List<dynamic> _examResults = [];
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
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getExamResults();
      setState(() {
        _examResults = data;
        _isLoading = false;
        
        // Expand first result by default if available
        if (_examResults.isNotEmpty && _expandedExams.isEmpty) {
          _expandedExams[_examResults[0]['id']] = true;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching results: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _viewReportCard(dynamic registration) async {
    final String id = registration['id'].toString();

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Opening Report Card...")),
      );
      final reportData = await ApiService.getReportCard(id);
      debugPrint("Report Data Loaded: ${reportData['exam']?['name']}");
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not load report card: $e")),
      );
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
          "Examination Results",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primary))
          : _examResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.grade_outlined, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      const Text("No exam results found", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchResults,
                  color: _primary,
                  backgroundColor: _card,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _examResults.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final registration = _examResults[index];
                      final exam = registration['exam'];
                      final bool isOpen = _expandedExams[registration['id']] ?? false;

                      return _buildResultCard(registration, exam, isOpen, () {
                        setState(() {
                          _expandedExams[registration['id']] = !isOpen;
                        });
                      });
                    },
                  ),
                ),
    );
  }

  Widget _buildResultCard(dynamic registration, dynamic exam, bool open, VoidCallback onTap) {
    if (exam == null) return const SizedBox.shrink();

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

    final results = registration['results'] as List? ?? [];
    
    double totalObtained = 0;
    for (var res in results) {
      totalObtained += double.tryParse(res['marks'].toString()) ?? 0;
    }

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
                        Row(
                          children: [
                            Text(
                              "Status: ",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                            ),
                            Text(
                              registration['status']?.toUpperCase() ?? 'N/A',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

          /// DETAILS
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Result Summary",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Total: ${totalObtained.toStringAsFixed(0)}",
                          style: TextStyle(color: _primary, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
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
                              Expanded(flex: 3, child: Text("Subject", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                              Expanded(flex: 1, child: Text("Marks", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                              Expanded(flex: 1, child: Text("Grade", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                              Expanded(flex: 1, child: Text("Result", textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),

                        /// TABLE ROWS
                        ...results.map((res) {
                          final subject = res['subject']?['name'] ?? 'N/A';
                          final marks = res['marks']?.toString() ?? 'N/A';
                          final grade = res['grade'] ?? '-';
                          final isPass = res['status']?.toString().toLowerCase() == 'pass';

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text(subject, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500))),
                                Expanded(flex: 1, child: Text(marks, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                                Expanded(flex: 1, child: Text(grade, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11))),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    isPass ? "Pass" : "Fail",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(color: isPass ? Colors.greenAccent : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// REPORT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _viewReportCard(registration),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.description_outlined, size: 20),
                      label: const Text("VIEW REPORT CARD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
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
