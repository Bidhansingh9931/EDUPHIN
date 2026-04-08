import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/my_class_model.dart';
import 'package:flutter/material.dart';

class MentoredSectionsPage extends StatefulWidget {
  const MentoredSectionsPage({super.key});

  @override
  State<MentoredSectionsPage> createState() => _MentoredSectionsPageState();
}

class _MentoredSectionsPageState extends State<MentoredSectionsPage> {
  bool isExpanded = true;
  late Future<MyClassData> _myClassDataFuture;

  @override
  void initState() {
    super.initState();
    _myClassDataFuture = ApiService.getMyClassData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Mentored Sections"),
      ),
      body: SafeArea(
        child: FutureBuilder<MyClassData>(
          future: _myClassDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                ),
              );
            } else if (snapshot.hasData) {
              final myClassData = snapshot.data!;
              final sectionName = myClassData.sections.isNotEmpty
                  ? myClassData.sections.first.name
                  : "No Mentored Section";

              return SingleChildScrollView(
                padding: context.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// DROPDOWN HEADER
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                          child: Row(
                            children: [
                              Icon(Icons.groups, color: theme.colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  sectionName,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: theme.hintColor,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    /// EXPANDED CONTENT
                    if (isExpanded) ...[
                      const SizedBox(height: 24),
                      buildSchedulesCard(context, myClassData.schedules),
                      const SizedBox(height: 24),
                      buildStudentsCard(context, myClassData.students),
                    ]
                  ],
                ),
              );
            }
            return const Center(
              child: Text('No data found.'),
            );
          },
        ),
      ),
    );
  }

  // ==========================
  // SCHEDULES CARD
  // ==========================

  Widget buildSchedulesCard(BuildContext context, List<Schedule> schedules) {
    final theme = Theme.of(context);
    final Map<String, List<Schedule>> schedulesByDay = {};
    for (var schedule in schedules) {
      (schedulesByDay[schedule.dayOfWeek] ??= []).add(schedule);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  "Schedules",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(height: 20),
            if (schedules.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("No schedules available.", style: TextStyle(color: theme.hintColor))),
              )
            else
              ...schedulesByDay.entries.expand((entry) {
                final day = entry.key;
                final daySchedules = entry.value;
                return [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                    child: Text(
                      day,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  ...daySchedules.map((schedule) => buildScheduleTile(context, schedule)),
                  const SizedBox(height: 12),
                ];
              }),
          ],
        ),
      ),
    );
  }

  Widget buildScheduleTile(BuildContext context, Schedule schedule) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1))
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.subject?.name ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        "${schedule.startTime} - ${schedule.endTime}",
                        style: TextStyle(color: theme.hintColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================
  // STUDENTS CARD
  // ==========================

  Widget buildStudentsCard(BuildContext context, List<Student> students) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  "Students (${students.length})",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                )
              ],  
            ),
            const SizedBox(height: 20),
            if (students.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("No students found in this section.", style: TextStyle(color: theme.hintColor))),
              )
            else
              ...students.asMap().entries.map((entry) {
                int i = entry.key;
                Student student = entry.value;
                return _buildStudentRow(
                    context, i + 1, student.name, student.rollNumber ?? 'N/A');
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentRow(BuildContext context, int index, String name, String roll) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(index.toString(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Roll: $roll",
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {}, 
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 32),
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)
            ),
            child: const Text('REMARKS')
          )
        ],
      ),
    );
  }
}
