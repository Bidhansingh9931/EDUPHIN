import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/manager_dashboard/manageClasses/schedule/searchSchedule/overrideSchedule/override_schedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Data model for API response
class ApiSchedule {
  final int id;
  final String subjectName;
  final String teacherName;
  final String className;
  final String sectionName;
  final String weekday;
  final String startTime;
  final String endTime;

  ApiSchedule({
    required this.id,
    required this.subjectName,
    required this.teacherName,
    required this.className,
    required this.sectionName,
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });

  factory ApiSchedule.fromJson(Map<String, dynamic> json) {
    return ApiSchedule(
      id: json['id'] ?? 0,
      subjectName: json['subject']?['name'] ?? 'N/A',
      teacherName: json['teacher']?['name'] ?? 'N/A',
      className: json['class']?['name'] ?? 'N/A',
      sectionName: json['section']?['name'] ?? 'N/A',
      weekday: json['weekday'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }
}

// Data model for a schedule entry
class ScheduleEntry {
  final int id;
  final String title;
  final String subtitle;
  final String time;

  ScheduleEntry({required this.id, required this.title, required this.subtitle, required this.time});
}

class DailyClassSchedulePage extends StatefulWidget{
  final String className;
  final String section;
  final String date;

  const DailyClassSchedulePage({
    super.key,
    required this.className,
    required this.section,
    required this.date,
  });

  @override
  State<StatefulWidget> createState() => _DailyClassSchedulePageState();
}

class _DailyClassSchedulePageState extends State<DailyClassSchedulePage>{
  bool _isLoading = true;
  Object? _error;
  List<ScheduleEntry> _schedule = [];
  static const String _cacheKey = 'manager_class_schedules';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchSchedule();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CacheService.getCache(_cacheKey);
    if (cachedData != null && mounted) {
      _processScheduleData(cachedData);
    }
  }

  void _processScheduleData(dynamic data) {
    // 2. Parse the date to find the weekday
    final DateFormat inputFormat = DateFormat('dd-MM-yyyy');
    final DateTime dateTime = inputFormat.parse(widget.date);
    final String weekday = DateFormat('EEEE').format(dateTime);

    // 3. Filter schedules by class, section, and weekday
    final List<dynamic> allSchedulesJson = data ?? [];
    final List<ApiSchedule> allSchedules = allSchedulesJson.map((json) => ApiSchedule.fromJson(json)).toList();

    final List<ApiSchedule> filteredSchedules = allSchedules.where((schedule) {
      return schedule.className == widget.className &&
             schedule.sectionName == widget.section &&
             schedule.weekday.toLowerCase() == weekday.toLowerCase();
    }).toList();

    // 4. Format the time and map to UI model
    final DateFormat apiTimeFormat = DateFormat('HH:mm:ss');
    final DateFormat displayTimeFormat = DateFormat('h:mm a');

    final List<ScheduleEntry> fetchedSchedule = filteredSchedules.map((schedule) {
      try {
        final DateTime startTime = apiTimeFormat.parse(schedule.startTime);
        final DateTime endTime = apiTimeFormat.parse(schedule.endTime);

        final String formattedTime = '${displayTimeFormat.format(startTime)} - ${displayTimeFormat.format(endTime)}';

        return ScheduleEntry(
          id: schedule.id,
          title: schedule.subjectName,
          subtitle: schedule.teacherName,
          time: formattedTime,
        );
      } catch (e) {
        // Handle potential time parsing errors gracefully
        return ScheduleEntry(
          id: schedule.id,
          title: schedule.subjectName,
          subtitle: schedule.teacherName,
          time: 'Invalid Time',
        );
      }
    }).toList();

    if (mounted) {
      setState(() {
        _schedule = fetchedSchedule;
      });
    }
  }

  Future<void> _fetchSchedule() async {
    if (!mounted) return;
    setState(() {
      _isLoading = _schedule.isEmpty;
      _error = null;
    });

    try {
      final response = await ApiService.get('manager/class-schedules');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] != true) {
          throw Exception('API returned an error: ${responseData['message']}');
        }

        await CacheService.setCache(_cacheKey, responseData['data']);
        _processScheduleData(responseData['data']);
      } else {
        throw Exception('Failed to load schedule. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          _error = e;
        });
        ErrorHandler.showError(context, e);
      }
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("${widget.className} - ${widget.section}"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSchedule,
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final theme = context.theme;
    
    return LoadingWrapper(
      isLoading: _isLoading,
      hasData: _schedule.isNotEmpty,
      error: _error,
      onRetry: _fetchSchedule,
      skeleton: _buildSkeleton(),
      child: RefreshIndicator(
        onRefresh: _fetchSchedule,
        color: theme.colorScheme.primary,
        child: _schedule.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy_outlined, size: context.scale(64), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    SizedBox(height: context.scale(16)),
                    Text("No schedule found for this day.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16))),
                  ],
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Use GridView for wider screens
                      if (constraints.maxWidth > 600) {
                        return GridView.builder(
                          padding: context.pagePadding,
                          itemCount: _schedule.length,
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: context.scale(400),
                            mainAxisSpacing: context.scale(16),
                            crossAxisSpacing: context.scale(16),
                            childAspectRatio: 2.5,
                          ),
                          itemBuilder: (context, index) {
                            final entry = _schedule[index];
                            return ScheduleCard(
                              scheduleId: entry.id,
                              className: "${widget.className} - ${widget.section}",
                              title: entry.title,
                              subtitle: entry.subtitle,
                              time: entry.time,
                            );
                          },
                        );
                      } else {
                        // Use ListView for narrower screens
                        return ListView.separated(
                          padding: context.pagePadding,
                          itemCount: _schedule.length,
                          separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
                          itemBuilder: (context, index) {
                            final entry = _schedule[index];
                            return ScheduleCard(
                              scheduleId: entry.id,
                              className: "${widget.className} - ${widget.section}",
                              title: entry.title,
                              subtitle: entry.subtitle,
                              time: entry.time,
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: context.pagePadding,
      itemCount: 5,
      separatorBuilder: (context, index) => SizedBox(height: context.scale(16)),
      itemBuilder: (context, index) => Container(
        padding: EdgeInsets.all(context.scale(16)),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(context.scale(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: context.scale(20), width: context.scale(150)),
                  SizedBox(height: context.scale(8)),
                  SkeletonBox(height: context.scale(14), width: context.scale(100)),
                  SizedBox(height: context.scale(4)),
                  SkeletonBox(height: context.scale(14), width: context.scale(80)),
                ],
              ),
            ),
            SkeletonBox(height: context.scale(36), width: context.scale(80), borderRadius: context.scale(10)),
          ],
        ),
      ),
    );
  }
}

// Renamed to ScheduleCard for clarity
class ScheduleCard extends StatelessWidget{
  final int scheduleId;
  final String className;
  final String title;
  final String subtitle;
  final String time;

  const ScheduleCard({
    super.key,
    required this.scheduleId,
    required this.className,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // For Grid layout
              children:[
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold)
                ),
                Text(
                  time,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
          ElevatedButton(onPressed: (){
            // Passing data to the OverrideSchedulePage
            Navigator.push(context, MaterialPageRoute(builder: (context)=>OverrideSchedulePage(
              scheduleId: scheduleId,
              scheduleDetails: OriginalScheduleDetails(
                className: className,
                subject: title,
                teacher: subtitle,
                time: time,
              ),
            )));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const FittedBox(
            child: Text("Override"),
          )
          ),
        ],
      ),
    );
  }
}

