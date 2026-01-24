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
  // Corrected property name from 'subject' to 'className' for clarity
  final String className;
  final String section;

  const ShowSchedulePage({
    super.key,
    this.className = "Class VIII", // Default values for demonstration
    this.section = "A",
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
        Schedule(subject: "Physics", professor: "Prof Jane Smith", time: "10:00 AM - 11:00 AM"),
      ],
      "Tuesday": [
        Schedule(subject: "Chemistry", professor: "Dr. Alan Grant", time: "11:00 AM - 12:00 PM"),
      ],
      "Wednesday": [
        Schedule(subject: "Biology", professor: "Dr. Ellie Sattler", time: "9:00 AM - 10:00 AM"),
      ],
      "Thursday": [
         Schedule(subject: "Mathematics", professor: "Prof John Doe", time: "9:00 AM - 10:00 AM"),
         Schedule(subject: "History", professor: "Mr. Ian Malcolm", time: "1:00 PM - 2:00 PM"),
      ],
      "Friday": [
        Schedule(subject: "English", professor: "Mrs. Sarah Harding", time: "2:00 PM - 3:00 PM"),
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
        // Use the corrected property name
        title: Text("${widget.className} - ${widget.section}"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                // Use a GridView for wider screens
                if (constraints.maxWidth > 600) {
                  return _buildGridView();
                } else {
                  // Use a ListView for narrower screens
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
        return _DayScheduleCard(day: day, schedules: schedules);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      itemCount: _scheduleByDay.keys.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400, // Max width for each day's card
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2, // Adjust aspect ratio as needed
      ),
      itemBuilder: (context, index) {
        String day = _scheduleByDay.keys.elementAt(index);
        List<Schedule> schedules = _scheduleByDay[day]!;
        return _DayScheduleCard(day: day, schedules: schedules);
      },
    );
  }
}

// Widget to display the schedule for a single day
class _DayScheduleCard extends StatelessWidget {
  final String day;
  final List<Schedule> schedules;

  const _DayScheduleCard({required this.day, required this.schedules});

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
          // Use a flexible list for the schedules within the card
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedules.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return ScheduleCard(schedule: schedules[index]);
            },
          )
        ],
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
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, // Use a different color for nested card
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
                // Use theme for scalable and consistent text styles
                Text(schedule.subject, style: theme.textTheme.titleMedium),
                // Use theme color for icon
                Icon(Icons.delete, color: theme.colorScheme.error, size: 20),
              ],
            ),
            // Use theme hintColor for less important text
            Text(schedule.professor, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
            Text(schedule.time, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
          ],
        ),
      ),
    );
  }
}
