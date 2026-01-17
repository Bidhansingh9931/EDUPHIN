import 'package:flutter/material.dart';

// --- Data Models ---
class Schedule {
  final String subject;
  final String professor;
  final String time;

  Schedule({
    required this.subject,
    required this.professor,
    required this.time,
  });
}

// --- Page Widget ---
class ShowSchedulePage extends StatefulWidget {
  final String subject;
  final String section;

  const ShowSchedulePage({
    super.key,
    this.subject = "Mathematics", // Default values for demonstration
    this.section = "Sec A",
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
    // Simulate API call to fetch schedule data.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));

    // Mock data, grouped by day
    final Map<String, List<Schedule>> fetchedSchedule = {
      "Monday": [
        Schedule(subject: "Mathematics", professor: "Prof John Doe", time: "9:00 AM - 10:00 AM"),
      ],
      "Tuesday": [
        Schedule(subject: "Mathematics", professor: "Prof John Doe", time: "11:00 AM - 12:00 PM"),
      ],
      "Wednesday": [
        Schedule(subject: "Mathematics", professor: "Prof John Doe", time: "9:00 AM - 10:00 AM"),
      ],
      "Friday": [
        Schedule(subject: "Mathematics", professor: "Prof John Doe", time: "2:00 PM - 3:00 PM"),
      ],
    };

    if (mounted) {
      setState(() {
        _scheduleByDay = fetchedSchedule;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("${widget.subject} - ${widget.section}"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 115),
              child: ListView.builder(
                itemCount: _scheduleByDay.keys.length,
                itemBuilder: (context, index) {
                  String day = _scheduleByDay.keys.elementAt(index);
                  List<Schedule> schedules = _scheduleByDay[day]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(day, style: theme.textTheme.headlineSmall),
                      ),
                      ...schedules.map((schedule) => ScheduleCard(schedule: schedule)),
                       const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
    );
  }
}

// --- Reusable Widgets ---
class ScheduleCard extends StatelessWidget {
  final Schedule schedule;

  const ScheduleCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(schedule.subject, style: const TextStyle(fontSize: 16, color: Colors.white)),
                const Icon(Icons.delete, color: Colors.red, size: 20),
              ],
            ),
            Text(schedule.professor, style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(150))),
            Text(schedule.time, style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(150))),
          ],
        ),
      ),
    );
  }
}
