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
              style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center),
          Icon(Icons.download, color: theme.colorScheme.onSurface),
        ],
      )),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
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
                icon: Icon(Icons.add, size: 30, color: theme.colorScheme.onPrimary),
                label: Text("Generate New Event",
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              color: theme.colorScheme.onSurface.withAlpha(50),
              thickness: 1,
            ),
            const SizedBox(height: 16),
            _buildFilters(theme),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return _buildWideLayout(context);
                      } else {
                        return _buildNarrowLayout(context);
                      }
                    }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: [
        _buildDropdown(theme, selectedValue, ['Status', 'Upcoming', 'Past'], (newValue) {
          setState(() {
            selectedValue = newValue!;
          });
        }),
        _buildDropdown(theme, selectedValue1, ['Type', 'Event', 'Meeting', 'Party'], (newValue) {
          setState(() {
            selectedValue1 = newValue!;
          });
        }),
        _buildDropdown(theme, selectedValue2, ['Audience', 'Student', 'Teacher', 'Staff', 'Librarian', 'Counselor'], (newValue) {
          setState(() {
            selectedValue2 = newValue!;
          });
        }),
      ],
    );
  }

  Widget _buildDropdown(ThemeData theme, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildEventSection(context, "Upcoming Events", _upcomingEvents),
          const SizedBox(height: 16),
          _buildEventSection(context, "Past Events", _pastEvents),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: _buildEventSection(context, "Upcoming Events", _upcomingEvents),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SingleChildScrollView(
            child: _buildEventSection(context, "Past Events", _pastEvents),
          ),
        ),
      ],
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
                    style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
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
                  style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimary)),
              Text(event.month,
                  style: theme.textTheme.titleMedium?.copyWith(
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
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  event.fullDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
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
