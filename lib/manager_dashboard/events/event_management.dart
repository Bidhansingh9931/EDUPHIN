import 'package:eduphin/manager_dashboard/events/event_attendees.dart';
import 'package:flutter/material.dart';

import 'generate_new_event.dart';

class Event {
  final String day;
  final String month;
  final String title;
  final String fullDate;

  Event({
    required this.day,
    required this.month,
    required this.title,
    required this.fullDate,
  });
}

class EventManagementPage extends StatefulWidget {
  const EventManagementPage({super.key});

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  String selectedValue = 'Status';
  String selectedValue1 = 'Type';
  String selectedValue2 = 'Audience';

  final List<Event> _upcomingEvents = [];
  final List<Event> _pastEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    // Simulate API call to fetch events.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));
    final List<Event> upcoming = [
      Event(day: "12", month: "Dec", title: "Annual Financial Literacy Working 2025", fullDate: "Friday, December 12"),
      Event(day: "03", month: "Jan", title: "Campus Cultural Fest 2025", fullDate: "Saturday, January 3"),
    ];
    final List<Event> past = [
      Event(day: "12", month: "Dec", title: "Annual Financial Literacy Working 2024", fullDate: "Thursday, December 12"),
      Event(day: "03", month: "Jan", title: "Campus Cultural Fest 2024", fullDate: "Friday, January 3"),
    ];

    if (mounted) {
      setState(() {
        _upcomingEvents.addAll(upcoming);
        _pastEvents.addAll(past);
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
          title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Event Management",
              style: TextStyle(color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center),
          Icon(Icons.download, color: theme.colorScheme.onSurface),
        ],
      )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UpcomingEvents()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 30, color: theme.colorScheme.onPrimary),
                      const SizedBox(width: 8),
                      Text("Generate New Event",
                          style: TextStyle(
                              fontSize: 20, color: theme.colorScheme.onPrimary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                color: theme.colorScheme.onSurface.withAlpha(50),
                thickness: 1,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedValue,
                        items: <String>['Status', 'Upcoming', 'Past'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedValue1,
                        items: <String>[
                          'Type',
                          'Event',
                          'Meeting',
                          'Party',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue1 = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedValue2,
                        items: <String>[
                          'Audience',
                          'Student',
                          'Teacher',
                          'Staff',
                          'Librarian',
                          'Counselor'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue2 = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        _buildEventSection(context, "Upcoming Events", _upcomingEvents),
                        const SizedBox(height: 16),
                        _buildEventSection(context, "Past Events", _pastEvents),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventSection(
      BuildContext context, String title, List<Event> events) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const EventAttendees()));
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, size: 30, color: theme.colorScheme.onPrimary),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(
                        fontSize: 20, color: theme.colorScheme.onPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final event = events[index];
                return _buildEventCard(context, event);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(event.day,
                  style: TextStyle(
                      fontSize: 20, color: theme.colorScheme.onPrimary)),
              Text(event.month,
                  style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onPrimary.withAlpha(180))),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                      fontSize: 16, color: theme.colorScheme.onPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  event.fullDate,
                  style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onPrimary.withAlpha(180)),
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_forward_ios_outlined,
              size: 20,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
