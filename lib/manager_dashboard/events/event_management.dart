import 'dart:convert';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
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
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadCachedData().then((_) => _fetchEvents());
  }

  Future<void> _loadCachedData() async {
    final cache = await CacheService.getCache('event_management_data');
    if (cache != null && mounted) {
      _processEventData(cache);
      setState(() => _isLoading = false);
    }
  }

  void _processEventData(dynamic data) {
    final List<dynamic>? eventData = data['events'];
    final List<dynamic>? roleData = data['roles'];

    if (eventData == null || roleData == null) return;

    final List<Event> allEvents = eventData
        .map((json) {
          try {
            return Event.fromJson(json);
          } catch (e) {
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
        String? statusParam;
        if (_selectedStatus == 'Upcoming') {
          statusParam = 'upcoming';
        } else if (_selectedStatus == 'Past') {
          statusParam = 'expired';
        }

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

        _audienceOptions = roles.toSet().toList();
        if (!_audienceOptions.contains(_selectedAudience)) {
          _selectedAudience = 'Audience';
        }
      });
    }
  }

  Future<void> _fetchEvents() async {
    if (!mounted) return;
    if (_upcomingEvents.isEmpty && _pastEvents.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
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

      final Map<String, String> queryParams = {
        if (statusParam != null) 'status': statusParam,
        if (typeParam != null) 'type': typeParam,
        if (audienceParam != null) 'audience': audienceParam,
      };

      final response = await ApiService.get('manager/events', queryParams);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (queryParams.isEmpty) {
          await CacheService.setCache('event_management_data', data);
        }
        if (mounted) {
          _processEventData(data);
          setState(() => _isLoading = false);
        }
      } else {
        throw Exception('Failed to load events. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = _upcomingEvents.isEmpty && _pastEvents.isEmpty;
          _error = e;
        });
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Event Management",
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: theme.colorScheme.onSurface, fontSize: context.font(20))),
              Icon(Icons.download, color: theme.colorScheme.onSurface, size: context.scale(24)),
            ],
          )),
      body: Padding(
        padding: EdgeInsets.fromLTRB(context.scale(16), context.scale(16), context.scale(16), context.scale(50)),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: context.scale(50),
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
                    borderRadius: BorderRadius.circular(context.scale(12)),
                  ),
                ),
                icon: Icon(Icons.add,
                    size: context.scale(30), color: theme.colorScheme.onPrimary),
                label: Text("Generate New Event",
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.onPrimary, fontSize: context.font(16))),
              ),
            ),
            SizedBox(height: context.scale(16)),
            Divider(
              color: theme.colorScheme.onSurface.withAlpha(50),
              thickness: 1,
            ),
            SizedBox(height: context.scale(16)),
            _buildFilters(theme),
            SizedBox(height: context.scale(16)),
            Expanded(
              child: LoadingWrapper(
                isLoading: _isLoading,
                hasData: _upcomingEvents.isNotEmpty || _pastEvents.isNotEmpty,
                error: _error,
                onRetry: _fetchEvents,
                skeleton: _buildSkeleton(context),
                child: LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return _buildWideLayout(context);
                  } else {
                    return _buildNarrowLayout(context);
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.scale(16)),
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              borderRadius: BorderRadius.circular(context.scale(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: context.scale(200), height: context.scale(24)),
                SizedBox(height: context.scale(16)),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
                  itemBuilder: (context, index) => SkeletonBox(height: context.scale(80), borderRadius: context.scale(12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Wrap(
      spacing: context.scale(10),
      runSpacing: context.scale(10),
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
      padding: EdgeInsets.symmetric(horizontal: context.scale(10)),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(context.scale(12)),
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
                style: TextStyle(fontSize: context.font(14)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchEvents,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            if (_upcomingEvents.isNotEmpty)
              _buildEventSection(context, "Upcoming Events", _upcomingEvents),
            if (_upcomingEvents.isNotEmpty && _pastEvents.isNotEmpty)
              SizedBox(height: context.scale(16)),
            if (_pastEvents.isNotEmpty)
              _buildEventSection(context, "Past Events", _pastEvents),
            if (_upcomingEvents.isEmpty && _pastEvents.isEmpty)
              SizedBox(
                height: context.screenHeight * 0.4,
                child: Center(child: Text('No events found.', style: TextStyle(fontSize: context.font(16)))),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchEvents,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _upcomingEvents.isNotEmpty
                  ? _buildEventSection(
                  context, "Upcoming Events", _upcomingEvents)
                  : Center(child: Text("No upcoming events.", style: TextStyle(fontSize: context.font(16)))),
            ),
            SizedBox(width: context.scale(16)),
            Expanded(
              child: _pastEvents.isNotEmpty
                  ? _buildEventSection(context, "Past Events", _pastEvents)
                  : Center(child: Text("No past events.", style: TextStyle(fontSize: context.font(16)))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventSection(
      BuildContext context, String title, List<Event> events) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.scale(16)),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(context.scale(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event,
                  size: context.scale(30), color: theme.colorScheme.onPrimary),
              SizedBox(width: context.scale(8)),
              Text(title,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: theme.colorScheme.onPrimary, fontSize: context.font(20))),
            ],
          ),
          SizedBox(height: context.scale(16)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
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
    final theme = context.theme;
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EventAttendees(eventId: event.id)));
      },
      child: Container(
        padding: EdgeInsets.all(context.scale(12)),
        decoration: BoxDecoration(
          color: theme.colorScheme.onPrimary.withAlpha(25),
          borderRadius: BorderRadius.circular(context.scale(12)),
        ),
        child: Row(
          children: [
            Column(
              children: [
                Text(event.day,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: theme.colorScheme.onPrimary, fontSize: context.font(24))),
                Text(event.month,
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withAlpha(180), fontSize: context.font(16))),
              ],
            ),
            SizedBox(width: context.scale(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.onPrimary, fontSize: context.font(16)),
                  ),
                  SizedBox(height: context.scale(4)),
                  Text(
                    event.fullDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withAlpha(180), fontSize: context.font(14)),
                  )
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_outlined,
              size: context.scale(20),
              color: theme.colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
