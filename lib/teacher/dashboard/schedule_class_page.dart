import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/schedule_models.dart';
import 'package:intl/intl.dart';
import 'common_widgets.dart';

class ScheduleClassPage extends StatefulWidget {
  const ScheduleClassPage({super.key});

  @override
  State<ScheduleClassPage> createState() => _ScheduleClassPageState();
}

class _ScheduleClassPageState extends State<ScheduleClassPage> {
  late Future<List<TeacherScheduleItem>> _scheduleFuture;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scheduleFuture = _fetchScheduleForDate(_selectedDate);
  }

  Future<List<TeacherScheduleItem>> _fetchScheduleForDate(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return ApiService.getMySchedule(formattedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _scheduleFuture = _fetchScheduleForDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Schedule"),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, size: context.scale(20)),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(800)),
          child: Column(
            children: [
              _buildDateHeader(),
              Expanded(
                child: FutureBuilder<List<TeacherScheduleItem>>(
                    future: _scheduleFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Padding(
                          padding: EdgeInsets.all(context.spacing),
                          child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: context.font(14))),
                        ));
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return _buildScheduleList(snapshot.data!);
                      } else {
                        return Center(
                            child: Text("No classes scheduled for this day.", style: TextStyle(fontSize: context.font(14), color: theme.hintColor)));
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: context.scale(12), horizontal: context.spacing),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.today, size: context.scale(18), color: theme.colorScheme.primary),
          SizedBox(width: context.scale(8)),
          Text(
            DateFormat.yMMMMd().format(_selectedDate),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(List<TeacherScheduleItem> schedules) {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final item = schedules[index];
        return ScheduleCard(scheduleItem: item);
      },
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final TeacherScheduleItem scheduleItem;

  const ScheduleCard(
      {super.key, required this.scheduleItem});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: context.spacing),
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        side: BorderSide(
          color: scheduleItem.isOverride
              ? const Color(0xFFF59E0B).withValues(alpha: 0.5) // Amber
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: scheduleItem.isOverride ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    scheduleItem.subject?['name'] ?? 'N/A',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(context.scale(6)),
                  ),
                  child: Text(
                    '${scheduleItem.startTime} - ${scheduleItem.endTime}',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.scale(8)),
            Row(
              children: [
                Icon(Icons.class_outlined, size: context.scale(14), color: theme.colorScheme.onSurfaceVariant),
                SizedBox(width: context.scale(4)),
                Text(
                  '${scheduleItem.classInfo?['name'] ?? 'N/A'} - ${scheduleItem.section?['name'] ?? 'N/A'}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            if (scheduleItem.isOverride) ...[
              Divider(height: context.scale(24), color: const Color(0xFFF59E0B).withValues(alpha: 0.3)), // Amber
              _buildOverrideInfo(context),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildOverrideInfo(BuildContext context) {
    final theme = context.theme;
    final newTeacherName = scheduleItem.newTeacher?['user']?['name'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: const Color(0xFFF59E0B), size: context.scale(18)), // Amber
            SizedBox(width: context.scale(8)),
            Text(
              'Class ${scheduleItem.overrideType}',
              style: TextStyle(
                  color: const Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: context.font(13)), // Amber
            ),
          ],
        ),
        if (newTeacherName != null)
          Padding(
            padding: EdgeInsets.only(top: context.scale(4.0)),
            child: Text('Taken by: $newTeacherName', style: TextStyle(fontSize: context.font(12))),
          ),
        if (scheduleItem.note != null)
          Padding(
            padding: EdgeInsets.only(top: context.scale(4.0)),
            child: Text('Note: ${scheduleItem.note}', style: TextStyle(fontSize: context.font(12), fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }
}

