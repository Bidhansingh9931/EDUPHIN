import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/error_handler.dart';

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
    _loadCachedSchedule();
    _fetchSchedule();
  }

  Future<void> _loadCachedSchedule() async {
    final cached = await CacheService.getData('student_routine');
    if (cached != null && mounted) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(cached as Map);
      setState(() {
        _schedules = List<dynamic>.from(data['schedules'] ?? []);
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSchedule() async {
    if (_schedules.isEmpty) setState(() => _isLoading = true);
    try {
      final data = await ApiService.getStudentRoutine();
      if (mounted) {
        setState(() {
          _schedules = data['schedules'] ?? [];
          _isLoading = false;
          _errorMessage = null;
        });
        CacheService.saveData('student_routine', data);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          ErrorHandler.showError(context, e);
          if (_schedules.isEmpty) _errorMessage = ErrorHandler.getMessage(e);
        });
      }
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
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _schedules.isNotEmpty,
        skeleton: const _TimetableSkeleton(),
        onRefresh: _fetchSchedule,
        child: _errorMessage != null && _schedules.isEmpty
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
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showClassDetails(c),
          child: Padding(
            padding: EdgeInsets.all(context.md),
            child: Row(
              children: [
                Container(
                  width: context.scale(80),
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
          ),
        ),
      ),
    );
  }

  void _showClassDetails(dynamic c) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(context.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              c['subject']?['name'] ?? 'Class Details',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.person, "Teacher", c['teacher']?['name'] ?? c['teacher_name'] ?? 'N/A'),
            _buildDetailRow(Icons.access_time, "Time", "${c['start_time']} - ${c['end_time']}"),
            if (c['room'] != null) _buildDetailRow(Icons.location_on, "Room", c['room'].toString()),
            if (c['note'] != null && c['note'].toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text("Notes", style: theme.textTheme.titleSmall),
              Text(c['note'], style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scale(8.0)),
      child: Row(
        children: [
          Icon(icon, size: context.scale(20), color: theme.colorScheme.primary),
          SizedBox(width: context.scale(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11))),
                Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontSize: context.font(14))),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _TimetableSkeleton extends StatelessWidget {
  const _TimetableSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(3, (i) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 4, bottom: context.sm, top: context.md),
                  child: SkeletonBox(height: 15, width: 80),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 2,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.responsive(1, tablet: 2, desktop: 2),
                    crossAxisSpacing: context.md,
                    mainAxisSpacing: context.md,
                    mainAxisExtent: context.scale(100),
                  ),
                  itemBuilder: (context, index) => SkeletonBox(
                    height: 100,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            )),
          ),
        ),
      ),
    );
  }
}

