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

  @override
  void initState() {
    super.initState();
    _fetchAttendees();
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
      if (_selectedFilter == "All") {
        _filteredAttendees = _allAttendees;
      } else {
        _filteredAttendees = _allAttendees
            .where((attendee) => attendee.attendance == _selectedFilter)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Annual Sports Day"),
              const SizedBox(height: 8),
              SearchBar(
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
                  Text("ATTENDEE LIST (${_allAttendees.length}) "),
                  DropdownButton<String>(
                    value: _selectedFilter,
                    items: <String>["All", "Attended", "Not Attended"]
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            style: TextStyle(color: Colors.blueAccent)),
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
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final attendee = _filteredAttendees[index];
                        final isAttended = attendee.attendance == 'Attended';
                        return ListTile(
                          title: Text(
                            attendee.name,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attendee.email,
                                style: TextStyle(
                                    color:
                                        theme.colorScheme.onSurface.withAlpha(180),
                                    fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                attendee.status,
                                style: TextStyle(
                                    color:
                                        theme.colorScheme.onSurface.withAlpha(180),
                                    fontSize: 14),
                              )
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                attendee.attendance,
                                style: TextStyle(
                                    color: isAttended
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isAttended
                                    ? Icons.check_circle_outline
                                    : Icons.cancel_outlined,
                                color: isAttended ? Colors.green : Colors.red,
                                size: 16,
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          Divider(color: theme.dividerColor, thickness: 1),
                      itemCount: _filteredAttendees.length),
            ],
          ),
        ),
      ),
    );
  }
}
