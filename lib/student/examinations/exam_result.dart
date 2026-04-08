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
          SnackBar(content: Text("Error fetching results: $e")),
        );
      }
    }
  }

  Future<void> _viewReportCard(dynamic registration) async {
    final String? idHash = registration['id_hash']?.toString();
    if (idHash == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report ID not found.")),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Opening Report Card...")),
      );
      // Fetches report data from API
      final reportData = await ApiService.getReportCard(idHash);
      debugPrint("Report Data Loaded: ${reportData['exam']?['name']}");
      
      // You can implement navigation to a full report page here
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not load report card: $e")),
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
          "Examination Results",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _examResults.isEmpty
              ? const Center(child: Text("No exam results found", style: TextStyle(color: Colors.white70)))
              : RefreshIndicator(
                  onRefresh: _fetchResults,
                  color: Colors.indigo,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _examResults.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final registration = _examResults[index];
                      final exam = registration['exam'];
                      final bool isOpen = _expandedExams[registration['id']] ?? false;

                      return resultCard(registration, exam, isOpen, () {
                        setState(() {
                          _expandedExams[registration['id']] = !isOpen;
                        });
                      });
                    },
                  ),
                ),
    );
  }

  Widget resultCard(dynamic registration, dynamic exam, bool open, VoidCallback onTap) {
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
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Status: ${registration['status']?.toUpperCase() ?? 'N/A'}",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xff5f6a7a),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formattedRange,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                const SizedBox(height: 2),
                Icon(
                  open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            onTap: onTap,
          ),

          /// DETAILS
          if (open)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Result Summary",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  /// TABLE HEADER
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: const Color(0xff2f3756),
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: Text("Subject", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Text("Marks", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Text("Grade", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Text("Result", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(subject, style: const TextStyle(color: Colors.white, fontSize: 11))),
                          Expanded(flex: 1, child: Text(marks, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                          Expanded(flex: 1, child: Text(grade, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11))),
                          Expanded(
                            flex: 1,
                            child: Text(
                              isPass ? "Pass" : "Fail",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: isPass ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  /// TOTAL / REPORT BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Marks: ${totalObtained.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _viewReportCard(registration),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.description, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text("REPORT CARD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}
