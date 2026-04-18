import 'dart:convert';

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
  String _eventName = "";
  String _errorMessage = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAttendees();
    _searchController.addListener(_filterAttendees);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  Future<void> _fetchAttendees() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final response = await ApiService.get('manager/events/${widget.eventId}/participants');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final event = data['event'] as Map<String, dynamic>?;
        final participants = data['participants'] as List<dynamic>?;
        final users = data['users'] as List<dynamic>?;

        if (event == null || participants == null || users == null) {
          throw Exception('Invalid API response format');
        }

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

        if (mounted) {
          setState(() {
            _eventName = event['title'] as String? ?? 'Event Attendees';
            _allAttendees = attendees;
            _filteredAttendees = attendees;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load attendees. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage)),
        );
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Event Attendees"),
            Icon(Icons.download),
          ],
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_eventName, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            SearchBar(
              controller: _searchController,
              leading:
              Icon(Icons.search, color: theme.colorScheme.onSurface),
              hintText: "Search for students, teachers...",
              hintStyle: WidgetStateProperty.all(TextStyle(
                color: theme.hintColor,
              )),
              elevation: const WidgetStatePropertyAll(2),
              backgroundColor: WidgetStatePropertyAll(theme.cardColor),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  side: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text("ATTENDEE LIST (${_filteredAttendees.length})", style: theme.textTheme.titleMedium)),
                DropdownButton<String>(
                  value: _selectedFilter,
                  underline: const SizedBox.shrink(),
                  items: <String>["All", "Attended", "Not Attended"]
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage, style: TextStyle(color: theme.colorScheme.error)))
                  : _filteredAttendees.isEmpty
                  ? const Center(child: Text("No attendees found."))
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
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          Text(
            attendee.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(180),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            attendee.status,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(180),
            ),
          )
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            attendee.attendance,
            style: theme.textTheme.bodyMedium?.copyWith(color: statusColor),
          ),
          const SizedBox(width: 8),
          Icon(
            isAttended
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            color: statusColor,
            size: 16,
          ),
        ],
      ),
    );
  }
}