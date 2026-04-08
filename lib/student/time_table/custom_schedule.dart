import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eduphin/services/api_service.dart';

class ClassSchedulePage extends StatefulWidget {
  const ClassSchedulePage({super.key});

  @override
  State<ClassSchedulePage> createState() => _ClassSchedulePageState();
}

class _ClassSchedulePageState extends State<ClassSchedulePage> {
  DateTime? selectedDate;
  final TextEditingController dateController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _scheduleData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Default to today
    selectedDate = DateTime.now();
    dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
    _fetchDatewiseSchedule();
  }

  Future<void> _fetchDatewiseSchedule() async {
    if (selectedDate == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final response = await ApiService.get('student/routine/date-wise', {'date': formattedDate});
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _scheduleData = data['data'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
        dateController.text = DateFormat('yyyy-MM-dd').format(date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedules = _scheduleData?['schedules'] as List? ?? [];
    final overrides = _scheduleData?['overrides'] as List? ?? [];
    final student = _scheduleData?['student'];

    return Scaffold(
      backgroundColor: const Color(0xff0a1230),
      appBar: AppBar(
        backgroundColor: const Color(0xff0a1230),
        elevation: 0,
        title: const Text(
          "Class Schedule",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// COURSE / STUDENT INFO CARD
          if (student != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff3c4566),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${student['first_name']} ${student['last_name'] ?? ''}",
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Roll No: ${student['student_roll_no'] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      statusBox("Regular: ${schedules.length}"),
                      statusBox("Overrides: ${overrides.length}"),
                    ],
                  )
                ],
              ),
            ),

          const SizedBox(height: 20),

          /// SELECT DATE CARD
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xff3c4566),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Date",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  onTap: pickDate,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "yyyy-mm-dd",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xff5d6a7a),
                    suffixIcon: const Icon(Icons.calendar_today, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff3d64d8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : _fetchDatewiseSchedule,
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("SHOW SCHEDULE", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff5d6a7a),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedDate = DateTime.now();
                            dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
                          });
                          _fetchDatewiseSchedule();
                        },
                        child: const Text("TODAY", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// SCHEDULE RESULT CARD
          if (_errorMessage != null)
            Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)))
          else if (_scheduleData != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff3c4566),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.list, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Schedule for ${DateFormat('EEEE, d MMM yyyy').format(selectedDate ?? DateTime.now())}",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Total classes: ${schedules.length + overrides.length}",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  
                  ...schedules.map((s) => classCard(s, isOverride: false)),
                  ...overrides.map((o) => classCard(o, isOverride: true)),
                  
                  if (schedules.isEmpty && overrides.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text("No classes scheduled for this date", style: TextStyle(color: Colors.white54)),
                      ),
                    ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget classCard(dynamic schedule, {required bool isOverride}) {
    // Corrected null-aware bracket access for Maps
    final classSchedule = isOverride ? schedule['class_schedule'] : null;
    final subject = isOverride 
        ? (classSchedule != null ? classSchedule['subject'] : null) 
        : schedule['subject'];
        
    final startTime = schedule['start_time'] ?? 'N/A';
    final endTime = schedule['end_time'] ?? 'N/A';
    
    final teacher = isOverride 
        ? (schedule['teacher'] != null ? schedule['teacher']['name'] : 'N/A') 
        : (schedule['teacher_name'] ?? 'N/A');

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOverride ? Colors.orangeAccent.withAlpha(128) : Colors.white30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subject != null ? (subject['name'] ?? 'Subject N/A') : 'Subject N/A',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (isOverride)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                  child: const Text("OVERRIDE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(teacher ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$startTime - $endTime", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              if (!isOverride)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                  child: const Text("REGULAR", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget statusBox(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          color: const Color(0xff5d6a7a),
          border: Border.all(color: Colors.white30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ),
    );
  }
}
