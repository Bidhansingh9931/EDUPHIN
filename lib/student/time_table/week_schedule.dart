import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  // Theme Colors
  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);

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
      final data = await ApiService.getStudentRoutine();
      setState(() {
        _schedules = data['schedules'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      // API uses 'weekday', Flutter code was looking for 'day'
      String weekdayRaw = schedule['weekday'] ?? schedule['day'] ?? '';
      if (weekdayRaw.isEmpty) continue;

      // Normalize to Title Case (e.g., "wednesday" -> "Wednesday")
      // to match the keys in the groupedSchedules map
      String day = weekdayRaw[0].toUpperCase() + weekdayRaw.substring(1).toLowerCase();

      if (groupedSchedules.containsKey(day)) {
        groupedSchedules[day]!.add(schedule);
      }
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Weekly Timetable",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _fetchSchedule,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primary))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white70)))
              : RefreshIndicator(
                  onRefresh: _fetchSchedule,
                  color: _primary,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: groupedSchedules.entries
                        .where((e) => e.value.isNotEmpty)
                        .map((entry) {
                      return _buildDaySection(
                        day: entry.key,
                        classes: entry.value,
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  Widget _buildDaySection({required String day, required List<dynamic> classes}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
          child: Text(
            day.toUpperCase(),
            style: TextStyle(
              color: _primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...classes.map((c) => _buildClassCard(c)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildClassCard(dynamic c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _secondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  c['start_time'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                const Text("to", style: TextStyle(color: Colors.white38, fontSize: 10)),
                const SizedBox(height: 2),
                Text(
                  c['end_time'] ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c['subject']?['name'] ?? 'N/A',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text(
                      c['teacher']?['name'] ?? c['teacher_name'] ?? 'N/A',
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.1)),
        ],
      ),
    );
  }
}

