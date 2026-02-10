import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:eduphin/manager_dashboard/events/event_attendees.dart';
import 'package:flutter/material.dart';

import 'generate_new_event.dart';

class Event {
  final int id;
  final String title;
  final DateTime eventDate;
  final String day;
  final String month;
  final String fullDate;

  Event({
    required this.id,
    required this.title,
    required this.eventDate,
  })  : day = DateFormat('dd').format(eventDate),
        month = DateFormat('MMM').format(eventDate),
        fullDate = DateFormat('EEEE, MMMM d').format(eventDate);

  factory Event.fromJson(Map<String, dynamic> json) {
    // Validate and handle potential null or invalid data
    if (json['id'] == null || json['event_date'] == null) {
      throw const FormatException("Invalid event data: 'id' or 'event_date' is missing.");
    }

    try {
      return Event(
        id: json['id'],
        title: json['title'] ?? 'No Title',
        eventDate: DateTime.parse(json['event_date']),
      );
    } catch (e) {
      // Handle parsing errors gracefully
      throw FormatException("Error parsing event data: ${e.toString()}");
    }
  }
}

class EventManagementPage extends StatefulWidget {
  const EventManagementPage({super.key});

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  String _selectedStatus = 'Status';
  String _selectedType = 'Type';
  String _selectedAudience = 'Audience';

  List<String> _audienceOptions = ['Audience', 'All'];

  List<Event> _upcomingEvents = [];
  List<Event> _pastEvents = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Mapping UI values to API query params
      String? statusParam;
      if (_selectedStatus == 'Upcoming') {
        statusParam = 'upcoming';
      } else if (_selectedStatus == 'Past') {
        statusParam = 'expired';
      }

      String? typeParam;
      if (_selectedType == 'Paid') {
        typeParam = 'paid';
      } else if (_selectedType == 'Free') {
        typeParam = 'free';
      }

      String? audienceParam;
      if (_selectedAudience != 'Audience' && _selectedAudience != 'All') {
        audienceParam = _selectedAudience.toLowerCase();
      } else if (_selectedAudience == 'All') {
        audienceParam = 'all';
      }

      final queryParams = {
        if (statusParam != null) 'status': statusParam,
        if (typeParam != null) 'type': typeParam,
        if (audienceParam != null) 'audience': audienceParam,
      };

      final endpoint = Uri(path: 'manager/events', queryParameters: queryParams.isNotEmpty ? queryParams : null).toString();

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Safely access nested data
        final List<dynamic>? eventData = data['events'];
        final List<dynamic>? roleData = data['roles'];

        if (eventData == null || roleData == null) {
          throw Exception("Invalid data structure from API.");
        }

        final List<Event> allEvents = eventData
            .map((json) {
              try {
                return Event.fromJson(json);
              } catch (e) {
                // Log the error and skip the invalid event
                debugPrint("Error parsing event: ${e.toString()}");
                return null;
              }
            })
            .where((event) => event != null)
            .cast<Event>()
            .toList();

        final List<Event> upcoming = [];
        final List<Event> past = [];
        final now = DateTime.now();

        for (var event in allEvents) {
          final eventDateOnly = DateTime(event.eventDate.year, event.eventDate.month, event.eventDate.day);
          final nowDateOnly = DateTime(now.year, now.month, now.day);
          if (eventDateOnly.isAfter(nowDateOnly) || eventDateOnly.isAtSameMomentAs(nowDateOnly)) {
            upcoming.add(event);
          } else {
            past.add(event);
          }
        }

        final List<String> roles = ['Audience', 'All'];
        roles.addAll(roleData
            .map((role) => role['name']?.toString())
            .where((roleName) =>
                roleName != null && roleName != 'Admin' && roleName != 'Super Admin')
            .cast<String>()
            .toList());

        if (mounted) {
          setState(() {
            if (statusParam == 'upcoming') {
              _upcomingEvents = allEvents;
              _pastEvents.clear();
            } else if (statusParam == 'expired') {
              _pastEvents = allEvents;
              _upcomingEvents.clear();
            } else {
              _upcomingEvents = upcoming;
              _pastEvents = past;
            }

            _audienceOptions = roles.toSet().toList(); // Remove duplicates
            if (!_audienceOptions.contains(_selectedAudience)) {
              _selectedAudience = 'Audience';
            }
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load events. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error fetching events: ${e.toString().replaceFirst("Exception: ", "")}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage)),
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
          title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Event Management",
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.onSurface)),
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
                          builder: (context) => const GenerateNewEvent()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.add,
                    size: 30, color: theme.colorScheme.onPrimary),
                label: Text("Generate New Event",
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.onPrimary)),
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
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Text(_errorMessage,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: theme.colorScheme.error)))
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
        _buildDropdown(
            theme, _selectedStatus, ['Status', 'Upcoming', 'Past'],
            (newValue) {
          setState(() {
            _selectedStatus = newValue!;
          });
          _fetchEvents();
        }),
        _buildDropdown(theme, _selectedType, ['Type', 'Paid', 'Free'],
            (newValue) {
          setState(() {
            _selectedType = newValue!;
          });
          _fetchEvents();
        }),
        _buildDropdown(theme, _selectedAudience, _audienceOptions,
            (newValue) {
          setState(() {
            _selectedAudience = newValue!;
          });
          _fetchEvents();
        }),
      ],
    );
  }

  Widget _buildDropdown(ThemeData theme, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
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
          if (_upcomingEvents.isNotEmpty)
            _buildEventSection(context, "Upcoming Events", _upcomingEvents),
          if (_upcomingEvents.isNotEmpty && _pastEvents.isNotEmpty)
            const SizedBox(height: 16),
          if (_pastEvents.isNotEmpty)
            _buildEventSection(context, "Past Events", _pastEvents),
          if (_upcomingEvents.isEmpty && _pastEvents.isEmpty)
            const Center(child: Text('No events found.'))
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
            child: _upcomingEvents.isNotEmpty
                ? _buildEventSection(
                    context, "Upcoming Events", _upcomingEvents)
                : const Center(child: Text("No upcoming events.")),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SingleChildScrollView(
            child: _pastEvents.isNotEmpty
                ? _buildEventSection(context, "Past Events", _pastEvents)
                : const Center(child: Text("No past events.")),
          ),
        ),
      ],
    );
  }

  Widget _buildEventSection(
      BuildContext context, String title, List<Event> events) {
    final theme = Theme.of(context);
    return Container(
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
              Icon(Icons.event,
                  size: 30, color: theme.colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text(title,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: theme.colorScheme.onPrimary)),
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
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EventAttendees(eventId: event.id)));
      },
      child: Container(
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
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: theme.colorScheme.onPrimary)),
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
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.onPrimary),
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
            Icon(
              Icons.arrow_forward_ios_outlined,
              size: 20,
              color: theme.colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
