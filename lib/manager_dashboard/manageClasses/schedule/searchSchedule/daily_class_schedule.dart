import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
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
  String _error = '';
  final List<ScheduleEntry> _schedule = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
      _schedule.clear();
    });

    try {
      // 1. Fetch all schedules from the API
      final response = await ApiService.get('manager/class-schedules');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] != true) {
          throw Exception('API returned an error: ${responseData['message']}');
        }

        // 2. Parse the date to find the weekday
        final DateFormat inputFormat = DateFormat('dd-MM-yyyy');
        final DateTime dateTime = inputFormat.parse(widget.date);
        final String weekday = DateFormat('EEEE').format(dateTime);

        // 3. Filter schedules by class, section, and weekday
        final List<dynamic> allSchedulesJson = responseData['data'] ?? [];
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
            _schedule.addAll(fetchedSchedule);
          });
        }
      } else {
        throw Exception('Failed to load schedule. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center,),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _fetchSchedule, child: const Text("Retry"))
            ],
          ),
        ),
      );
    }
    
    if (_schedule.isEmpty) {
       return const Center(child: Text("No schedule found for this day."));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use GridView for wider screens
        if (constraints.maxWidth > 600) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
            itemCount: _schedule.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400, // Max width per item
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.5, // Adjust for content
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
            itemCount: _schedule.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
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
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // For Grid layout
        children:[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use flexible to prevent overflow on very small screens
              Flexible(
                child: Text(
                  title,
                  // Using theme for scalable and consistent fonts
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                // Using theme colors for consistency
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Override")
              ),
            ],
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
    );
  }
}
