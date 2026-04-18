import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/my_class_model.dart';
import 'package:eduphin/teacher/dashboard/student_remarks_page.dart';
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
    final theme = context.theme;
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
                  padding: context.pagePadding,
                  child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14))),
                ),
              );
            } else if (snapshot.hasData) {
              final myClassData = snapshot.data!;
              final sectionName = myClassData.sections.isNotEmpty ? myClassData.sections.first.name : "No Mentored Section";

              return SingleChildScrollView(
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
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
                            elevation: 0,
                            color: theme.colorScheme.surfaceContainerLow,
                            surfaceTintColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.scale(20)),
                              side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(18)),
                              child: Row(
                                children: [
                                  Icon(Icons.groups, color: theme.colorScheme.primary, size: context.scale(24)),
                                  SizedBox(width: context.scale(12)),
                                  Expanded(
                                    child: Text(
                                      sectionName,
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
                                    ),
                                  ),
                                  Icon(
                                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: context.scale(24),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),

                        /// EXPANDED CONTENT
                        if (isExpanded) ...[
                          SizedBox(height: context.spacing),
                          buildSchedulesCard(context, myClassData.schedules),
                          SizedBox(height: context.spacing),
                          buildStudentsCard(context, myClassData.students),
                        ]
                      ],
                    ),
                  ),
                ),
              );
            }
            return Center(
              child: Text('No data found.', style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant)),
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
    final theme = context.theme;
    final Map<String, List<Schedule>> schedulesByDay = {};
    for (var schedule in schedules) {
      (schedulesByDay[schedule.dayOfWeek] ??= []).add(schedule);
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: theme.colorScheme.primary, size: context.scale(20)),
                SizedBox(width: context.scale(10)),
                Text(
                  "Schedules",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
                )
              ],
            ),
            SizedBox(height: context.spacing),
            if (schedules.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.spacing),
                child: Center(child: Text("No schedules available.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14)))),
              )
            else
              ...schedulesByDay.entries.expand((entry) {
                final day = entry.key;
                final daySchedules = entry.value;
                return [
                  Padding(
                    padding: EdgeInsets.only(top: context.scale(8), bottom: context.scale(12)),
                    child: Text(
                      day,
                      style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: context.font(14)),
                    ),
                  ),
                  ...daySchedules.map((schedule) => buildScheduleTile(context, schedule)),
                  SizedBox(height: context.scale(12)),
                ];
              }),
          ],
        ),
      ),
    );
  }

  Widget buildScheduleTile(BuildContext context, Schedule schedule) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      margin: EdgeInsets.only(bottom: context.scale(8)),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.scale(8)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(context.scale(8)),
              ),
              child: Icon(Icons.book_outlined, size: context.scale(20), color: theme.colorScheme.primary),
            ),
            SizedBox(width: context.scale(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.subject?.name ?? 'N/A',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurface),
                  ),
                  SizedBox(height: context.scale(2)),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: context.scale(12), color: theme.colorScheme.onSurfaceVariant),
                      SizedBox(width: context.scale(4)),
                      Text(
                        "${schedule.startTime} - ${schedule.endTime}",
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12)),
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
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups, color: theme.colorScheme.primary, size: context.scale(20)),
                SizedBox(width: context.scale(10)),
                Text(
                  "Students (${students.length})",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
                )
              ],
            ),
            SizedBox(height: context.spacing),
            if (students.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.spacing),
                child: Center(child: Text("No students found in this section.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14)))),
              )
            else
              ...students.asMap().entries.map((entry) {
                int i = entry.key;
                Student student = entry.value;
                return _buildStudentRow(context, i + 1, student);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentRow(BuildContext context, int index, Student student) {
    final theme = context.theme;
    return Container(
      margin: EdgeInsets.only(bottom: context.scale(8)),
      padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(10)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(context.scale(12)),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Row(
        children: [
          ProfileAvatar(
            imageUrl: ApiService.getStorageUrl(student.photo),
            radius: context.scale(14),
            borderWidth: 0,
          ),
          SizedBox(width: context.scale(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurface),
                ),
                Text(
                  "Roll: ${student.rollNumber ?? 'N/A'}",
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentRemarksPage(
                    studentId: student.id,
                    studentName: student.name,
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: context.scale(12)),
              minimumSize: Size(0, context.scale(32)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(6))),
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Text('REMARKS', style: TextStyle(fontSize: context.font(11), fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          )
        ],
      ),
    );
  }
}
