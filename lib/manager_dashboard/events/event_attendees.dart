import 'package:flutter/material.dart';

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
}

class EventAttendees extends StatefulWidget {
  const EventAttendees({super.key});

  @override
  State<StatefulWidget> createState() => _EventAttendeesState();
}

class _EventAttendeesState extends State<EventAttendees> {
  String _selectedFilter = "All";
  List<Attendee> _allAttendees = [];
  List<Attendee> _filteredAttendees = [];
  bool _isLoading = true;
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
    // Simulate API call to fetch attendees.
    // Replace this with your actual API call.
    await Future.delayed(const Duration(seconds: 2));
    final List<Attendee> attendees = [
      Attendee(name: "Aarav Sharma", email: "aarav.sharma@school.com", status: "Student", attendance: "Attended"),
      Attendee(name: "Diya Patel", email: "diya.patel@school.com", status: "Student", attendance: "Not Attended"),
      Attendee(name: "Rohan Kumar", email: "rohan.kumar@school.com", status: "Student", attendance: "Attended"),
      Attendee(name: "Ms.Anjali Mehta", email: "anjali.mehta@school.com", status: "Teacher", attendance: "Attended"),
      Attendee(name: "Arjun Gupta", email: "arjun.gupta@school.com", status: "Student", attendance: "Not Attended"),
      Attendee(name: "Mr.Vikram Rathore", email: "vikram.rathore@school.com", status: "Staff", attendance: "Not Attended"),
      Attendee(name: "Vivaan Reddy", email: "vivaan.reddy@school.com", status: "Student", attendance: "Attended"),
    ];

    if (mounted) {
      setState(() {
        _allAttendees = attendees;
        _filteredAttendees = attendees;
        _isLoading = false;
      });
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
            Text("Annual Sports Day", style: theme.textTheme.headlineSmall),
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
                    setState(() {
                      _selectedFilter = newValue!;
                      _filterAttendees();
                    });
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
        maxCrossAxisExtent: 400, // Each item will have a maximum width of 400
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3, // Adjust aspect ratio for better layout
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
    final statusColor = isAttended ? Colors.green : Colors.red;

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
