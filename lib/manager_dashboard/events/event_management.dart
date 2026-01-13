import 'package:eduphin/manager_dashboard/events/event_attendees.dart';
import 'package:flutter/material.dart';

import 'generate_new_event.dart';

class EventManagementPage extends StatefulWidget{
  const EventManagementPage({super.key});

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  String selectedValue = 'Status';
  String selectedValue1 = 'Type';
  String selectedValue2 = 'Audience';

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
                    style: TextStyle(
                        color: theme.colorScheme.onSurface),
                    textAlign: TextAlign.center),
                Icon(Icons.download, color: theme.colorScheme.onSurface),
              ],
            )
        ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const UpcomingEvents()));
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
                          style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
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
                      items:<String>['Status', 'Upcoming', 'Past'].map((String value) {
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
                      items:<String>['Type', 'Event', 'Meeting', 'Party',].map((String value) {
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
                      items:<String>['Audience', 'Student', 'Teacher', 'Staff', 'Librarian', 'Counselor'].map((String value) {
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

              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const EventAttendees()));
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
                          Text("Upcoming Events",
                              style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Text("12",
                                    style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                                Text("Dec",
                                    style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary.withAlpha(180))),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Annual Financial Literacy Working 2025",
                                    style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Friday, December 12",
                                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onPrimary.withAlpha(180)),
                                  )
                                ],
                              ),
                            ),
                            IconButton(
                                onPressed: (){},
                                icon: Icon(Icons.arrow_forward_ios_outlined, size: 20, color: theme.colorScheme.onPrimary,
                                ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Text("0",
                                    style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                                Text("Jan",
                                    style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary.withAlpha(180))),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Campus Cultural Fest 2025",
                                    style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Saturday, January 3",
                                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onPrimary.withAlpha(180)),
                                  ),

                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: (){},
                              icon: Icon(Icons.arrow_forward_ios_outlined, size: 20, color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
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
                        Text("Past Events",
                            style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Text("12",
                                  style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                              Text("Dec",
                                  style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary.withAlpha(180))),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Annual Financial Literacy Working 2025",
                                  style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Friday, December 12",
                                  style: TextStyle(fontSize: 14, color: theme.colorScheme.onPrimary.withAlpha(180)),
                                )
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: (){},
                            icon: Icon(Icons.arrow_forward_ios_outlined, size: 20, color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Text("0",
                                  style: TextStyle(fontSize: 20, color: theme.colorScheme.onPrimary)),
                              Text("Jan",
                                  style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary.withAlpha(180))),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Campus Cultural Fest 2025",
                                  style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Saturday, January 3",
                                  style: TextStyle(fontSize: 14, color: theme.colorScheme.onPrimary.withAlpha(180)),
                                )
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: (){},
                            icon: Icon(Icons.arrow_forward_ios_outlined, size: 20, color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ],
          ),
        ),
      ),
    );
  }
}
