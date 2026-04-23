import 'dart:convert';

import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';

class Attendee {
  final String name;
  final String email;
  final String status;
  final String attendance;

  Attendee({
    required this.name,
    required this.email,
    required this.status,
    required this.attendance,
  });

  factory Attendee.fromJson(Map<String, dynamic> participant, Map<String, dynamic>? user) {
    final status = participant['status'] as String? ?? 'pending';
    final isAttended = status == 'confirmed';

    return Attendee(
      name: user?['name'] as String? ?? 'N/A',
      email: user?['email'] as String? ?? 'N/A',
      status: status,
      attendance: isAttended ? 'Attended' : 'Not Attended',
    );
  }
}

class EventAttendees extends StatefulWidget {
  final int eventId;
  const EventAttendees({super.key, required this.eventId});

  @override
  State<StatefulWidget> createState() => _EventAttendeesState();
}

class _EventAttendeesState extends State<EventAttendees> {
  String _selectedFilter = "All";
  List<Attendee> _allAttendees = [];
  List<Attendee> _filteredAttendees = [];
  bool _isLoading = true;
  Object? _error;
  String _eventName = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCachedData().then((_) => _fetchAttendees());
    _searchController.addListener(_filterAttendees);
  }

  Future<void> _loadCachedData() async {
    final cache = await CachingService.getCache('event_attendees_${widget.eventId}');
    if (cache != null && mounted) {
      _processData(cache);
    }
  }

  void _processData(dynamic data) {
    final event = data['event'] as Map<String, dynamic>?;
    final participants = data['participants'] as List<dynamic>?;
    final users = data['users'] as List<dynamic>?;

    if (event == null || participants == null || users == null) return;

    final userMap = {for (var user in users) user['id']: user};

    final attendees = participants.map((p) {
      try {
        final user = userMap[p['user_id']];
        return Attendee.fromJson(p, user);
      } catch (e) {
        debugPrint('Error parsing attendee: $e');
        return null;
      }
    }).where((a) => a != null).cast<Attendee>().toList();

    setState(() {
      _eventName = event['title'] as String? ?? 'Event Attendees';
      _allAttendees = attendees;
      _isLoading = false;
      _filterAttendees();
    });
  }

  Future<void> _fetchAttendees() async {
    if (!mounted) return;
    setState(() {
      _isLoading = _allAttendees.isEmpty;
      _error = null;
    });

    try {
      final response = await ApiService.get('manager/events/${widget.eventId}/participants');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await CachingService.setCache('event_attendees_${widget.eventId}', data);
        if (mounted) {
          _processData(data);
        }
      } else {
        throw Exception('Failed to load attendees. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e;
        });
      }
    }
  }

  void _filterAttendees() {
    setState(() {
      List<Attendee> results = _allAttendees;

      if (_selectedFilter != "All") {
        results = results
            .where((attendee) => attendee.attendance == _selectedFilter)
            .toList();
      }

      final String query = _searchController.text.toLowerCase();
      if (query.isNotEmpty) {
        results = results.where((attendee) {
          return attendee.name.toLowerCase().contains(query) ||
              attendee.email.toLowerCase().contains(query) ||
              attendee.status.toLowerCase().contains(query);
        }).toList();
      }

      _filteredAttendees = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Event Attendees", style: theme.textTheme.titleLarge?.copyWith(fontSize: context.font(20))),
            Icon(Icons.download, size: context.scale(24)),
          ],
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.fromLTRB(context.scale(16), context.scale(16), context.scale(16), context.scale(50)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_eventName, style: theme.textTheme.headlineSmall?.copyWith(fontSize: context.font(24))),
            SizedBox(height: context.scale(8)),
            SearchBar(
              controller: _searchController,
              leading: Icon(Icons.search, color: theme.colorScheme.onSurface, size: context.scale(24)),
              hintText: "Search for students, teachers...",
              hintStyle: WidgetStateProperty.all(TextStyle(
                color: theme.hintColor,
                fontSize: context.font(16),
              )),
              elevation: const WidgetStatePropertyAll(2),
              backgroundColor: WidgetStatePropertyAll(theme.cardColor),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(context.scale(30))),
                  side: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
            ),
            SizedBox(height: context.scale(16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "ATTENDEE LIST (${_filteredAttendees.length})",
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: context.font(16)),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedFilter,
                  underline: const SizedBox.shrink(),
                  items: <String>["All", "Attended", "Not Attended"]
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: context.font(14))),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedFilter = newValue;
                        _filterAttendees();
                      });
                    }
                  },
                ),
              ],
            ),
            Divider(
              color: theme.dividerColor,
              thickness: 2,
            ),
            Expanded(
              child: LoadingWrapper(
                isLoading: _isLoading,
                hasData: _allAttendees.isNotEmpty,
                error: _error,
                onRetry: _fetchAttendees,
                skeleton: _buildSkeleton(),
                child: RefreshIndicator(
                  onRefresh: _fetchAttendees,
                  child: _filteredAttendees.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: context.screenHeight * 0.4,
                              child: const Center(child: Text("No attendees found.")),
                            ),
                          ],
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 600) {
                              return _buildAttendeeList();
                            } else {
                              return _buildAttendeeGrid();
                            }
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      itemCount: 8,
      separatorBuilder: (context, index) => Divider(color: Theme.of(context).dividerColor, thickness: 1),
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(vertical: context.scale(8)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: context.scale(150), height: context.scale(20)),
                  SizedBox(height: context.scale(8)),
                  SkeletonBox(width: context.scale(200), height: context.scale(16)),
                  SizedBox(height: context.scale(4)),
                  SkeletonBox(width: context.scale(100), height: context.scale(16)),
                ],
              ),
            ),
            SkeletonBox(width: context.scale(80), height: context.scale(24)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeeList() {
    return ListView.separated(
        itemBuilder: (context, index) {
          final attendee = _filteredAttendees[index];
          return _buildAttendeeTile(attendee);
        },
        separatorBuilder: (context, index) =>
            Divider(color: Theme.of(context).dividerColor, thickness: 1),
        itemCount: _filteredAttendees.length);
  }

  Widget _buildAttendeeGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      itemCount: _filteredAttendees.length,
      itemBuilder: (context, index) {
        final attendee = _filteredAttendees[index];
        return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: _buildAttendeeTile(attendee)
        );
      },
    );
  }

  Widget _buildAttendeeTile(Attendee attendee) {
    final theme = Theme.of(context);
    final isAttended = attendee.attendance == 'Attended';
    final statusColor = isAttended ? theme.colorScheme.primary : theme.colorScheme.error;

    return ListTile(
      title: Text(
        attendee.name,
        style: theme.textTheme.titleMedium?.copyWith(fontSize: context.font(16)),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: context.scale(4)),
          Text(
            attendee.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(180),
              fontSize: context.font(14),
            ),
          ),
          SizedBox(height: context.scale(4)),
          Text(
            attendee.status,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(180),
              fontSize: context.font(14),
            ),
          )
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            attendee.attendance,
            style: theme.textTheme.bodyMedium?.copyWith(color: statusColor, fontSize: context.font(14)),
          ),
          SizedBox(width: context.scale(8)),
          Icon(
            isAttended
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            color: statusColor,
            size: context.scale(16),
          ),
        ],
      ),
    );
  }
}