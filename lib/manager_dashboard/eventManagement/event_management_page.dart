import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ───────────────────────────────────────────────────────────
//                          DATA MODELS
// ───────────────────────────────────────────────────────────

class Event {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final String description;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
  });
}

// ───────────────────────────────────────────────────────────
//                         MOCK SERVICE
// ───────────────────────────────────────────────────────────

class EventService {
  // Mock data - replace with your actual API calls
  final List<Event> _upcomingEvents = [
    Event(
      id: '1',
      title: 'Annual Science Fair',
      date: DateTime.now().add(const Duration(days: 10)),
      location: 'Main Auditorium',
      description: 'A display of the best science projects from all grades.',
    ),
    Event(
      id: '2',
      title: 'Parent-Teacher Meeting',
      date: DateTime.now().add(const Duration(days: 25)),
      location: 'Respective Classrooms',
      description: 'A meeting to discuss student progress for the term.',
    ),
  ];

  final List<Event> _pastEvents = [
    Event(
      id: '3',
      title: 'Sports Day 2023',
      date: DateTime.now().subtract(const Duration(days: 30)),
      location: 'School Ground',
      description: 'Annual sports competition for all students.',
    ),
  ];

  Future<List<Event>> getUpcomingEvents() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // In a real app, you would make an API call here.
    // e.g., final response = await ApiService.get('manager/events?type=upcoming');
    return _upcomingEvents;
  }

  Future<List<Event>> getPastEvents() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // In a real app, you would make an API call here.
    // e.g., final response = await ApiService.get('manager/events?type=past');
    return _pastEvents;
  }
}

// ───────────────────────────────────────────────────────────
//                      EVENT MANAGEMENT PAGE
// ───────────────────────────────────────────────────────────

class EventManagementPage extends StatelessWidget {
  const EventManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Event Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _EventList(eventType: _EventType.upcoming),
            _EventList(eventType: _EventType.past),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Navigate to a "Create New Event" page.
            // For example:
            // Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateEventPage()));
          },
          label: const Text('New Event'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}

enum _EventType { upcoming, past }

class _EventList extends StatefulWidget {
  final _EventType eventType;

  const _EventList({required this.eventType});

  @override
  State<_EventList> createState() => _EventListState();
}

class _EventListState extends State<_EventList> {
  final EventService _eventService = EventService();
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  void _fetchEvents() {
    setState(() {
      _eventsFuture = widget.eventType == _EventType.upcoming
          ? _eventService.getUpcomingEvents()
          : _eventService.getPastEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: _eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No ${widget.eventType.name} events found.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        final events = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async {
            _fetchEvents();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return _EventCard(event: events[index]);
            },
          ),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(25), // Adjusted for transparency
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('MMM').format(event.date).toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('dd').format(event.date),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
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
                        event.title,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: theme.hintColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.description,
              style: theme.textTheme.bodyLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to edit event page
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  onPressed: () {
                    // TODO: Show delete confirmation dialog
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}