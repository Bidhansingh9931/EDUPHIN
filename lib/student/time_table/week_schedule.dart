import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  bool _isLoading = true;
  List<dynamic> _schedules = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    setState(() => _isLoading = true);
    try {
      // Corrected endpoint to match your Laravel routes: student/routine
      final response = await ApiService.get('student/routine');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _schedules = data['data']?['schedules'] ?? data['schedules'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load schedule: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group schedules by day
    Map<String, List<dynamic>> groupedSchedules = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': [],
    };

    for (var schedule in _schedules) {
      String day = schedule['day'] ?? '';
      if (groupedSchedules.containsKey(day)) {
        groupedSchedules[day]!.add(schedule);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xff0a1230),
      appBar: AppBar(
        backgroundColor: const Color(0xff0a1230),
        elevation: 0,
        title: const Text(
          "Weekly Timetable",
          style: TextStyle(fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white70)))
              : RefreshIndicator(
                  onRefresh: _fetchSchedule,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: groupedSchedules.entries.map((entry) {
                      return timetableCard(
                        day: entry.key,
                        classes: entry.value,
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  Widget timetableCard({required String day, required List<dynamic> classes}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xff3c4566),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          /// DAY HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white24),
              ),
            ),
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (classes.isNotEmpty)
            Column(
              children: [
                /// TABLE HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: const [
                      Expanded(flex: 3, child: Text("Time", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
                      Expanded(flex: 4, child: Text("Subject", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
                      Expanded(flex: 3, child: Text("Teacher", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),

                /// DATA ROWS
                ...classes.map((c) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              "${c['start_time'] ?? ''}\n${c['end_time'] ?? ''}",
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              c['subject']?['name'] ?? 'N/A',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              c['teacher']?['name'] ?? c['teacher_name'] ?? 'N/A',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            )
          else
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "No classes scheduled",
                style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}
