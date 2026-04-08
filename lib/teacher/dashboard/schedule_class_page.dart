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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Schedule"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(),
          Expanded(
            child: FutureBuilder<List<TeacherScheduleItem>>(
                future: _scheduleFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return _buildScheduleList(snapshot.data!);
                  } else {
                    return const Center(
                        child: Text("No classes scheduled for this day."));
                  }
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Theme.of(context).colorScheme.surfaceVariant.withAlpha(100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat.yMMMMd().format(_selectedDate),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(List<TeacherScheduleItem> schedules) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: scheduleItem.isOverride
            ? BorderSide(color: Colors.orange.shade700, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  scheduleItem.subject?['name'] ?? 'N/A',
                  style: theme.textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${scheduleItem.startTime} - ${scheduleItem.endTime}',
                    style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${scheduleItem.classInfo?['name'] ?? 'N/A'} - ${scheduleItem.section?['name'] ?? 'N/A'}',
              style: theme.textTheme.bodyMedium,
            ),
            if (scheduleItem.isOverride) ...[
              const Divider(height: 20),
              _buildOverrideInfo(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildOverrideInfo() {
    final newTeacherName = scheduleItem.newTeacher?['user']?['name'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              'Class ${scheduleItem.overrideType}',
              style: TextStyle(
                  color: Colors.orange.shade600, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (newTeacherName != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('Taken by: $newTeacherName'),
          ),
        if (scheduleItem.note != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('Note: ${scheduleItem.note}'),
          ),
      ],
    );
  }
}
