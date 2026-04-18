import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  bool _isLoading = true;
  List<dynamic> _schedules = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getStudentRoutine();
      setState(() {
        _schedules = data['schedules'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    Map<String, List<dynamic>> groupedSchedules = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': [],
    };

    for (var schedule in _schedules) {
      String weekdayRaw = schedule['weekday'] ?? schedule['day'] ?? '';
      if (weekdayRaw.isEmpty) continue;

      String day = weekdayRaw[0].toUpperCase() + weekdayRaw.substring(1).toLowerCase();

      if (groupedSchedules.containsKey(day)) {
        groupedSchedules[day]!.add(schedule);
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Weekly Timetable"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSchedule,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: TextStyle(color: colorScheme.onSurfaceVariant)))
              : RefreshIndicator(
                  onRefresh: _fetchSchedule,
                  color: colorScheme.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: context.pagePadding,
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: groupedSchedules.entries
                              .where((e) => e.value.isNotEmpty)
                              .map((entry) {
                            return _buildDaySection(
                              day: entry.key,
                              classes: entry.value,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildDaySection({required String day, required List<dynamic> classes}) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: context.sm, top: context.md),
          child: Text(
            day.toUpperCase(),
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: classes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.responsive(1, tablet: 2, desktop: 2),
            crossAxisSpacing: context.md,
            mainAxisSpacing: context.md,
            mainAxisExtent: context.scale(100),
          ),
          itemBuilder: (context, index) => _buildClassCard(classes[index]),
        ),
        SizedBox(height: context.md),
      ],
    );
  }

  Widget _buildClassCard(dynamic c) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: EdgeInsets.symmetric(vertical: context.xs),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  c['start_time'] ?? '',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text("to", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10)),
                Text(
                  c['end_time'] ?? '',
                  style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          SizedBox(width: context.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  c['subject']?['name'] ?? 'N/A',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.xs),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        c['teacher']?['name'] ?? c['teacher_name'] ?? 'N/A',
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}

