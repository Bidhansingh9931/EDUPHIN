import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- Data Models ---
class Schedule {
  final int id; // Added for API integration
  final String subject;
  final String professor;
  final String time;
  final String day; // Added for grouping

  Schedule({
    required this.id,
    required this.subject,
    required this.professor,
    required this.time,
    required this.day,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    // Helper to format time safely
    String formatTime(String? timeString) {
      if (timeString == null) return 'N/A';
      try {
        final parsedTime = DateFormat.Hms().parse(timeString);
        return DateFormat.jm().format(parsedTime); // e.g., 9:00 AM
      } catch (e) {
        return timeString; // Return original if parsing fails
      }
    }

    final startTime = formatTime(json['start_time']);
    final endTime = formatTime(json['end_time']);

    return Schedule(
      id: json['id'],
      // Use null-aware operators for safety
      subject: json['subject']?['subject_name'] ?? 'No Subject',
      professor: json['teacher']?['name'] ?? 'No Professor',
      time: '$startTime - $endTime',
      day: json['day'] ?? 'Unknown',
    );
  }
}

// --- Page Widget ---
class ShowSchedulePage extends StatefulWidget {
  final String className;
  final String section;
  final int classId; // Required for API call
  final int sectionId; // Required for API call

  const ShowSchedulePage({
    super.key,
    required this.className,
    required this.section,
    required this.classId,
    required this.sectionId,
  });

  @override
  State<StatefulWidget> createState() => _ShowSchedulePageState();
}

class _ShowSchedulePageState extends State<ShowSchedulePage> {
  bool _isLoading = true;
  Map<String, List<Schedule>> _scheduleByDay = {};

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.get('manager/class-schedules?class_id=${widget.classId}&section_id=${widget.sectionId}');
      
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> scheduleData = data['data'];

        final List<Schedule> schedules = scheduleData.map((json) => Schedule.fromJson(json)).toList();

        // Group by day
        final Map<String, List<Schedule>> grouped = {};
        for (var schedule in schedules) {
          (grouped[schedule.day] ??= []).add(schedule);
        }
        
        // Sort days of the week
        final sortedDays = grouped.keys.toList()..sort((a, b) {
            const dayOrder = {"Monday": 1, "Tuesday": 2, "Wednesday": 3, "Thursday": 4, "Friday": 5, "Saturday": 6, "Sunday": 7};
            return (dayOrder[a] ?? 8) - (dayOrder[b] ?? 8);
        });
        
        final Map<String, List<Schedule>> sortedSchedules = {
            for (var day in sortedDays) day: grouped[day]!
        };

        setState(() {
          _scheduleByDay = sortedSchedules;
          _isLoading = false;
        });

      } else {
        throw Exception('Failed to load schedule: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }
  
  Future<void> _deleteSchedule(int scheduleId) async {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await ApiService.delete('manager/class-schedules/$scheduleId');
      if (!mounted) return;
      final theme = Theme.of(context);

      if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Schedule deleted successfully!'), backgroundColor: theme.colorScheme.primary),
          );
          _fetchSchedule(); // Refresh the schedule list
      } else {
         throw Exception('Failed to delete schedule: ${response.body}');
      }
    } catch (e) {
       if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: theme.colorScheme.error),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("${widget.className} - ${widget.section}"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                if (_scheduleByDay.isEmpty) {
                    return const Center(child: Text("No schedule found for this class."));
                }
                if (constraints.maxWidth > 600) {
                  return _buildGridView();
                } else {
                  return _buildListView();
                }
              },
            ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      itemCount: _scheduleByDay.keys.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        String day = _scheduleByDay.keys.elementAt(index);
        List<Schedule> schedules = _scheduleByDay[day]!;
        return _DayScheduleCard(day: day, schedules: schedules, onDelete: _deleteSchedule);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      itemCount: _scheduleByDay.keys.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        String day = _scheduleByDay.keys.elementAt(index);
        List<Schedule> schedules = _scheduleByDay[day]!;
        return _DayScheduleCard(day: day, schedules: schedules, onDelete: _deleteSchedule);
      },
    );
  }
}

class _DayScheduleCard extends StatelessWidget {
  final String day;
  final List<Schedule> schedules;
  final void Function(int scheduleId) onDelete; // Callback for deletion

  const _DayScheduleCard({required this.day, required this.schedules, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedules.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return ScheduleCard(
                schedule: schedules[index],
                onDelete: () => onDelete(schedules[index].id),
              );
            },
          )
        ],
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onDelete;

  const ScheduleCard({super.key, required this.schedule, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(schedule.subject, style: theme.textTheme.titleMedium),
                IconButton(
                  icon: Icon(Icons.delete, color: theme.colorScheme.error, size: 20),
                  onPressed: onDelete, // Use the callback
                  constraints: const BoxConstraints(), // To remove extra padding
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            Text(schedule.professor, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
            Text(schedule.time, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
          ],
        ),
      ),
    );
  }
}
