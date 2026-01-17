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
        : Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,115),
        child: ListView.separated(
          itemCount: _schedule.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final entry = _schedule[index];
            return CustomContainer(
              title: entry.title,
              subtitle: entry.subtitle,
              time: entry.time,
            );
          },
        ),
      ),
    );
  }

}
class CustomContainer extends StatelessWidget{
  final String title;
  final String subtitle;
  final String time;

  const CustomContainer({
    super.key,
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16,16,16,16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,style: const TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold),),
                ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const OverrideSchedulePage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ), child: const Text("Override",style: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold),)
                ),
              ],
            ),
            Text(subtitle,style: TextStyle(fontSize: 12,color: Colors.white.withAlpha(150),fontWeight: FontWeight.bold)),
            Text(time,style: TextStyle(fontSize: 12,color: Colors.white.withAlpha(150),fontWeight: FontWeight.bold),

            ),
          ],
        ),
      ),
    );
  }

}
