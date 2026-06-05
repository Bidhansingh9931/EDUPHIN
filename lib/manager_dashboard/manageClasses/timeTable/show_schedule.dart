import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

// --- Data Models ---
class Schedule {
  final int id; // Added for API integration
  final String subject;
  final String professor;
  final String time;
  final String day; // Added for grouping

  Schedule({
    required this.id,
    required this.subject,
    required this.professor,
    required this.time,
    required this.day,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    // Helper to format time safely
    String formatTime(String? timeString) {
      if (timeString == null) return 'N/A';
      try {
        final parsedTime = DateFormat.Hms().parse(timeString);
        return DateFormat.jm().format(parsedTime); // e.g., 9:00 AM
      } catch (e) {
        return timeString; // Return original if parsing fails
      }
    }

    final startTime = formatTime(json['start_time']);
    final endTime = formatTime(json['end_time']);

    return Schedule(
      id: json['id'] ?? 0,
      // Use null-aware operators for safety
      subject: json['subject']?['subject_name'] ?? 'No Subject',
      professor: json['teacher']?['name'] ?? 'No Professor',
      time: '$startTime - $endTime',
      day: json['day'] ?? 'Unknown',
    );
  }
}

// --- Page Widget ---
class ShowSchedulePage extends StatefulWidget {
  final String className;
  final String section;
  final int classId; // Required for API call
  final int sectionId; // Required for API call

  const ShowSchedulePage({
    super.key,
    required this.className,
    required this.section,
    required this.classId,
    required this.sectionId,
  });

  @override
  State<StatefulWidget> createState() => _ShowSchedulePageState();
}

class _ShowSchedulePageState extends State<ShowSchedulePage> {
  bool _isLoading = true;
  Map<String, List<Schedule>> _scheduleByDay = {};
  Object? _error;
  String get _cacheKey => 'manager_schedule_${widget.classId}_${widget.sectionId}';

  @override
  void initState() {
    super.initState();
    _loadCacheAndFetch();
  }

  Future<void> _loadCacheAndFetch() async {
    final cachedData = await CacheService.getCache(_cacheKey);
    if (cachedData != null && mounted) {
      setState(() {
        _scheduleByDay = _processScheduleData(cachedData);
        _isLoading = false;
      });
    }
    _fetchSchedule();
  }

  Map<String, List<Schedule>> _processScheduleData(dynamic data) {
    final List<dynamic> scheduleData = data['data'] ?? [];

    final List<Schedule> schedules = scheduleData
        .where((json) => json != null)
        .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
        .toList();

    // Group by day
    final Map<String, List<Schedule>> grouped = {};
    for (var schedule in schedules) {
      (grouped[schedule.day] ??= []).add(schedule);
    }

    // Sort days of the week
    final sortedDays = grouped.keys.toList()
      ..sort((a, b) {
        const dayOrder = {"Monday": 1, "Tuesday": 2, "Wednesday": 3, "Thursday": 4, "Friday": 5, "Saturday": 6, "Sunday": 7};
        return (dayOrder[a] ?? 8) - (dayOrder[b] ?? 8);
      });

    return {for (var day in sortedDays) day: grouped[day]!};
  }

  Future<void> _fetchSchedule() async {
    if (!mounted) return;
    if (_scheduleByDay.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await ApiService.get('manager/class-schedules?class_id=${widget.classId}&section_id=${widget.sectionId}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await CacheService.setCache(_cacheKey, data);

        setState(() {
          _scheduleByDay = _processScheduleData(data);
          _isLoading = false;
          _error = null;
        });
      } else {
        throw Exception('Failed to load schedule: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e;
        });
        if (_scheduleByDay.isEmpty) {
          ErrorHandler.showError(context, e);
        }
      }
    }
  }
  
  Future<void> _deleteSchedule(int scheduleId) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Delete",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return DeleteScheduleDialog(
          onConfirm: () async {
            try {
              final response = await ApiService.delete('manager/class-schedules/$scheduleId');
              if (!mounted) return;
              final theme = Theme.of(context);

              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Schedule deleted successfully!'), backgroundColor: theme.colorScheme.primary),
                );
                _fetchSchedule(); // Refresh the schedule list
              } else {
                throw Exception('Failed to delete schedule: ${response.body}');
              }
            } catch (e) {
              if (mounted) {
                ErrorHandler.showError(context, e);
              }
            }
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${widget.className} - ${widget.section}", style: theme.textTheme.titleLarge?.copyWith(fontSize: context.font(18), fontWeight: FontWeight.bold)),
            Text("Weekly Class Schedule", style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11))),
          ],
        ),
        centerTitle: false,
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _scheduleByDay.isNotEmpty,
        error: _error,
        onRetry: _fetchSchedule,
        onRefresh: _fetchSchedule,
        skeleton: _buildSkeleton(),
        child: _scheduleByDay.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: context.scale(64), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    SizedBox(height: context.scale(16)),
                    Text("No schedule found for this class.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16))),
                  ],
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: context.responsive(
                    _buildListView(),
                    tablet: _buildGridView(),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: context.pagePadding,
      itemCount: 3,
      separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(context.scale(16)),
            border: Border.all(color: context.theme.colorScheme.outlineVariant),
          ),
          padding: EdgeInsets.all(context.scale(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(width: context.scale(18), height: context.scale(18)),
                  SizedBox(width: context.scale(8)),
                  SkeletonBox(width: context.scale(100), height: context.scale(20)),
                ],
              ),
              SizedBox(height: context.scale(12)),
              Divider(color: context.theme.colorScheme.outlineVariant),
              SizedBox(height: context.scale(8)),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
                itemBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(context.scale(12)),
                      border: Border.all(color: context.theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    padding: EdgeInsets.all(context.scale(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: context.scale(150), height: context.scale(16)),
                        SizedBox(height: context.scale(8)),
                        SkeletonBox(width: context.scale(120), height: context.scale(14)),
                        SizedBox(height: context.scale(4)),
                        SkeletonBox(width: context.scale(100), height: context.scale(14)),
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: context.pagePadding,
      itemCount: _scheduleByDay.keys.length,
      separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
      itemBuilder: (context, index) {
        String day = _scheduleByDay.keys.elementAt(index);
        List<Schedule> schedules = _scheduleByDay[day]!;
        return _DayScheduleCard(day: day, schedules: schedules, onDelete: _deleteSchedule);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: context.pagePadding,
      itemCount: _scheduleByDay.keys.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: context.scale(450),
        mainAxisSpacing: context.scale(16),
        crossAxisSpacing: context.scale(16),
        mainAxisExtent: context.scale(300), // Adjusted for dynamic content height if possible, or fixed
      ),
      itemBuilder: (context, index) {
        String day = _scheduleByDay.keys.elementAt(index);
        List<Schedule> schedules = _scheduleByDay[day]!;
        return _DayScheduleCard(day: day, schedules: schedules, onDelete: _deleteSchedule);
      },
    );
  }
}

class _DayScheduleCard extends StatelessWidget {
  final String day;
  final List<Schedule> schedules;
  final void Function(int scheduleId) onDelete; // Callback for deletion

  const _DayScheduleCard({required this.day, required this.schedules, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: EdgeInsets.all(context.scale(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: context.scale(18), color: theme.colorScheme.primary),
              SizedBox(width: context.scale(8)),
              Text(day, style: TextStyle(fontSize: context.font(18), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            ],
          ),
          SizedBox(height: context.scale(12)),
          Divider(color: theme.colorScheme.outlineVariant),
          SizedBox(height: context.scale(8)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedules.length,
            separatorBuilder: (context, index) => SizedBox(height: context.scale(12)),
            itemBuilder: (context, index) {
              return ScheduleCard(
                schedule: schedules[index],
                onDelete: () => onDelete(schedules[index].id),
              );
            },
          )
        ],
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onDelete;

  const ScheduleCard({super.key, required this.schedule, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(context.scale(12)),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    schedule.subject,
                    style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: context.scale(18)),
                  onPressed: onDelete,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            SizedBox(height: context.scale(4)),
            _infoRow(context, Icons.person_outline, schedule.professor),
            SizedBox(height: context.scale(2)),
            _infoRow(context, Icons.access_time, schedule.time),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, size: context.scale(14), color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: context.scale(4)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: context.font(12), color: theme.colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class DeleteScheduleDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteScheduleDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: context.scale(24)),
            padding: EdgeInsets.all(context.scale(20)),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(context.scale(20)),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Delete Schedule",
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: context.font(20)),
                ),
                SizedBox(height: context.scale(12)),
                Text(
                  "Are you sure you want to delete this schedule entry? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14)),
                ),
                SizedBox(height: context.scale(24)),
                SizedBox(
                  width: double.infinity,
                  child: buildActionButton(context, "YES, DELETE", () {
                    Navigator.pop(context);
                    onConfirm();
                  }),
                ),
                SizedBox(height: context.scale(12)),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.scale(12)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("CANCEL", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(14), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

