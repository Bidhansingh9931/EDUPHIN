import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:intl/intl.dart';
import 'schedule_models.dart';

class MySchedulePage extends StatefulWidget {
  const MySchedulePage({super.key});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  List<TeacherScheduleItem>? _schedules;
  bool _isLoading = true;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final cacheKey = 'schedule_$dateStr';

    try {
      // Load from cache first
      final cachedData = await TeacherCacheService.load(cacheKey);
      if (cachedData != null && cachedData is List) {
        setState(() {
          _schedules = cachedData.map((e) => TeacherScheduleItem.fromJson(e)).toList();
          _isLoading = false;
        });
      }

      // Fetch fresh data
      final freshData = await ApiService.getMySchedule(dateStr);
      await TeacherCacheService.save(cacheKey, freshData.map((e) => e.toJson()).toList());

      if (mounted) {
        setState(() {
          _schedules = freshData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        if (_schedules == null) {
          setState(() {
            _error = ErrorHandler.getMessage(e);
            _isLoading = false;
          });
        } else {
          ErrorHandler.showError(context, e);
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _schedules = null; // Clear current data to show skeleton for new date
      });
      _fetchSchedule();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Daily Schedule'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month, size: context.scale(20)),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSchedule,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.scale(800)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.spacing),
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.today, size: context.scale(18), color: theme.colorScheme.primary),
                      SizedBox(width: context.scale(8)),
                      Text(
                        DateFormat('EEEE, d MMM yyyy').format(_selectedDate),
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TeacherLoadingWrapper(
                    isLoading: _isLoading,
                    hasData: _schedules != null,
                    skeleton: _buildSkeleton(),
                    child: _error != null
                        ? Center(child: Text('Error: $_error', style: TextStyle(fontSize: context.font(14))))
                        : (_schedules == null || _schedules!.isEmpty)
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: context.pagePadding,
                                itemCount: _schedules!.length,
                                itemBuilder: (context, index) => _buildScheduleCard(_schedules![index]),
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: context.spacing),
        child: TeacherSkeleton(
          height: context.scale(80),
          borderRadius: BorderRadius.circular(context.scale(12)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = context.theme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: context.scale(64), color: theme.hintColor.withValues(alpha: 0.3)),
          SizedBox(height: context.spacing),
          Text("No classes scheduled for today", style: TextStyle(color: theme.hintColor, fontSize: context.font(14))),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(TeacherScheduleItem item) {
    final theme = context.theme;
    final startTime = item.startTime?.split(':').take(2).join(':') ?? "00:00";
    final endTime = item.endTime?.split(':').take(2).join(':') ?? "00:00";
    final subjectName = item.subject?['name']?.toString() ?? "N/A";
    final className = item.classInfo?['name']?.toString() ?? "N/A";
    final sectionName = item.section?['name']?.toString() ?? "N/A";

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: context.spacing),
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(12)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(8)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(context.scale(8)),
              ),
              child: Column(
                children: [
                  Text(startTime, 
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: context.font(13))),
                  Text("TO", style: TextStyle(fontSize: context.font(8), color: theme.colorScheme.primary.withValues(alpha: 0.7))),
                  Text(endTime, 
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: context.font(13))),
                ],
              ),
            ),
            SizedBox(width: context.spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subjectName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(15))),
                  SizedBox(height: context.scale(4)),
                  Text("$className - $sectionName", style: theme.textTheme.bodySmall?.copyWith(fontSize: context.font(12))),
                  if (item.isOverride)
                    Container(
                      margin: EdgeInsets.only(top: context.scale(8)),
                      padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(2)),
                      decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(context.scale(4))),
                      child: Text("SUBSTITUTION", style: TextStyle(color: const Color(0xFFF59E0B), fontSize: context.font(9), fontWeight: FontWeight.bold)), // Amber
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.hintColor.withValues(alpha: 0.5), size: context.scale(20)),
          ],
        ),
      ),
    );
  }
}
