import 'package:eduphin/manager_dashboard/manageClasses/schedule/searchSchedule/overrideSchedule/override_schedule.dart';
import 'package:flutter/material.dart';

// Data model for a schedule entry
class ScheduleEntry {
  final String title;
  final String subtitle;
  final String time;

  ScheduleEntry({required this.title, required this.subtitle, required this.time});
}

class DailyClassSchedulePage extends StatefulWidget{
  final String className;
  final String section;
  final String date;

  const DailyClassSchedulePage({
    super.key,
    // Provide default values for demonstration
    this.className = "Class VIII",
    this.section = "A",
    this.date = "20-07-2024",
  });

  @override
  State<StatefulWidget> createState() => _DailyClassSchedulePageState();
}

class _DailyClassSchedulePageState extends State<DailyClassSchedulePage>{
  bool _isLoading = true;
  final List<ScheduleEntry> _schedule = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    // Simulate API call to fetch schedule for the given class, section, and date
    await Future.delayed(const Duration(seconds: 2));

    // Mock data
    final List<ScheduleEntry> fetchedSchedule = [
      ScheduleEntry(title: "Mathematics", subtitle: "Mr. John Smith", time: "9:00 AM - 10:00 AM"),
      ScheduleEntry(title: "Physics", subtitle: "Ms. Emily White", time: "10:00 AM - 11:00 AM"),
      ScheduleEntry(title: "Chemistry", subtitle: "Dr. Alan Grant", time: "11:00 AM - 12:00 PM"),
      ScheduleEntry(title: "Biology", subtitle: "Mrs. Sarah Conner", time: "1:00 PM - 2:00 PM"),
      ScheduleEntry(title: "English Literature", subtitle: "Mr. David Chen", time: "2:00 PM - 3:00 PM"),
    ];

    if (mounted) {
      setState(() {
        _schedule.addAll(fetchedSchedule);
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
        title: Text("${widget.className} - ${widget.section}"),
        centerTitle: true,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : LayoutBuilder(
        builder: (context, constraints) {
          // Use GridView for wider screens
          if (constraints.maxWidth > 600) {
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
              itemCount: _schedule.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400, // Max width per item
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.5, // Adjust for content
              ),
              itemBuilder: (context, index) {
                final entry = _schedule[index];
                return ScheduleCard(
                  className: "${widget.className} - ${widget.section}",
                  title: entry.title,
                  subtitle: entry.subtitle,
                  time: entry.time,
                );
              },
            );
          } else {
            // Use ListView for narrower screens
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
              itemCount: _schedule.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final entry = _schedule[index];
                return ScheduleCard(
                  className: "${widget.className} - ${widget.section}",
                  title: entry.title,
                  subtitle: entry.subtitle,
                  time: entry.time,
                );
              },
            );
          }
        },
      ),
    );
  }
}

// Renamed to ScheduleCard for clarity
class ScheduleCard extends StatelessWidget{
  final String className;
  final String title;
  final String subtitle;
  final String time;

  const ScheduleCard({
    super.key,
    required this.className,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // For Grid layout
        children:[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use flexible to prevent overflow on very small screens
              Flexible(
                child: Text(
                  title,
                  // Using theme for scalable and consistent fonts
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(onPressed: (){
                // Passing data to the OverrideSchedulePage
                Navigator.push(context, MaterialPageRoute(builder: (context)=>OverrideSchedulePage(
                  scheduleDetails: OriginalScheduleDetails(
                    className: className,
                    subject: title,
                    teacher: subtitle,
                    time: time,
                  ),
                )));
              },
              style: ElevatedButton.styleFrom(
                // Using theme colors for consistency
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ), 
              child: const Text("Override")
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle, 
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold)
          ),
          Text(
            time, 
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }
}
