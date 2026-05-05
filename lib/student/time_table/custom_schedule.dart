import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/error_handler.dart';

class ClassSchedulePage extends StatefulWidget {
  const ClassSchedulePage({super.key});

  @override
  State<ClassSchedulePage> createState() => _ClassSchedulePageState();
}

class _ClassSchedulePageState extends State<ClassSchedulePage> {
  DateTime? selectedDate;
  final TextEditingController dateController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _scheduleData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Default to today
    selectedDate = DateTime.now();
    dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
    _loadCachedData();
    _fetchDatewiseSchedule();
  }

  Future<void> _loadCachedData() async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    final cachedData = await CacheService.getData('student_schedule_$formattedDate');
    if (cachedData != null && mounted) {
      setState(() {
        _scheduleData = cachedData;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDatewiseSchedule() async {
    if (selectedDate == null) return;

    setState(() {
      _isLoading = true;
    });
    _errorMessage = null;

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final data = await ApiService.getStudentDateWiseRoutine(formattedDate);
      if (mounted) {
        setState(() {
          _scheduleData = data;
          _isLoading = false;
        });
        await CacheService.saveData('student_schedule_$formattedDate', data);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          ErrorHandler.showError(context, e);
          if (_scheduleData == null) {
            _errorMessage = ErrorHandler.getMessage(e);
          }
        });
      }
    }
  }

  Future pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
        dateController.text = DateFormat('yyyy-MM-dd').format(date);
        _scheduleData = null;
      });
      _fetchDatewiseSchedule();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final schedules = _scheduleData?['schedules'] as List? ?? [];
    final overrides = _scheduleData?['overrides'] as List? ?? [];
    final student = _scheduleData?['student'];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Class Schedule"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDatewiseSchedule,
        color: colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// COURSE / STUDENT INFO CARD
                  if (student != null)
                    Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(context.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${student['first_name']} ${student['last_name'] ?? ''}",
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: context.xs),
                            Text(
                              "Roll No: ${student['student_roll_no'] ?? 'N/A'}",
                              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                            SizedBox(height: context.md),
                            Row(
                              children: [
                                statusBox("Regular: ${schedules.length}"),
                                SizedBox(width: context.md),
                                statusBox("Overrides: ${overrides.length}"),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: context.lg),

                  /// SELECT DATE CARD
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Date",
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: context.md),
                          TextField(
                            controller: dateController,
                            readOnly: true,
                            onTap: pickDate,
                            style: theme.textTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: "yyyy-mm-dd",
                              suffixIcon: Icon(Icons.calendar_today, color: colorScheme.primary, size: 20),
                            ),
                          ),
                          SizedBox(height: context.lg),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: context.scale(48),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    onPressed: _isLoading ? null : _fetchDatewiseSchedule,
                                    child: _isLoading 
                                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2))
                                      : const Text("SHOW SCHEDULE", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                              SizedBox(width: context.md),
                              Expanded(
                                child: SizedBox(
                                  height: context.scale(48),
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: colorScheme.primary),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedDate = DateTime.now();
                                        dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
                                      });
                                      _fetchDatewiseSchedule();
                                    },
                                    child: const Text("TODAY", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: context.lg),

                  /// SCHEDULE RESULT CARD
                  LoadingWrapper(
                    isLoading: _isLoading,
                    hasData: _scheduleData != null,
                    error: _errorMessage,
                    skeleton: const _ScheduleSkeleton(),
                    onRetry: _fetchDatewiseSchedule,
                    child: _scheduleData == null ? const SizedBox.shrink() : Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(context.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.list, color: colorScheme.primary, size: 22),
                                SizedBox(width: context.sm),
                                Expanded(
                                  child: Text(
                                    "Schedule for ${DateFormat('EEEE, d MMM yyyy').format(selectedDate ?? DateTime.now())}",
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.xs),
                            Text(
                              "Total classes: ${schedules.length + overrides.length}",
                              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                            SizedBox(height: context.lg),

                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: schedules.length + overrides.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: context.responsive(1, tablet: 2, desktop: 2),
                                crossAxisSpacing: context.md,
                                mainAxisSpacing: context.md,
                                mainAxisExtent: context.scale(140),
                              ),
                              itemBuilder: (context, index) {
                                if (index < schedules.length) {
                                  return classCard(schedules[index], isOverride: false);
                                } else {
                                  return classCard(overrides[index - schedules.length], isOverride: true);
                                }
                              },
                            ),

                            if (schedules.isEmpty && overrides.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: context.xl),
                                  child: Text("No classes scheduled for this date", style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget classCard(dynamic schedule, {required bool isOverride}) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final classSchedule = isOverride ? schedule['class_schedule'] : null;
    final subject = isOverride
        ? (classSchedule != null ? classSchedule['subject'] : null)
        : schedule['subject'];

    final startTime = schedule['start_time'] ?? 'N/A';
    final endTime = schedule['end_time'] ?? 'N/A';

    final teacher = isOverride
        ? (schedule['teacher'] != null ? schedule['teacher']['name'] : 'N/A')
        : (schedule['teacher_name'] ?? 'N/A');

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isOverride
                ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                : colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showClassDetails(schedule, isOverride),
          child: Padding(
            padding: EdgeInsets.all(context.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        subject != null ? (subject['name'] ?? 'Subject N/A') : 'Subject N/A',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOverride)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.5))),
                        child: const Text("OVERRIDE",
                            style: TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      )
                    else
                      Icon(Icons.chevron_right,
                          size: 20, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                  ],
                ),
                SizedBox(height: context.xs),
                Row(
                  children: [
                    Icon(Icons.person, color: colorScheme.onSurfaceVariant, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        teacher ?? 'N/A',
                        style:
                            theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$startTime - $endTime",
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    if (!isOverride)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF10B981).withValues(alpha: 0.5))),
                        child: const Text("REGULAR",
                            style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClassDetails(dynamic schedule, bool isOverride) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final classSchedule = isOverride ? schedule['class_schedule'] : null;
    final subject = isOverride
        ? (classSchedule != null ? classSchedule['subject'] : null)
        : schedule['subject'];

    final teacher = isOverride
        ? (schedule['teacher'] != null ? schedule['teacher']['name'] : 'N/A')
        : (schedule['teacher_name'] ?? 'N/A');

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
              subject?['name'] ?? 'Class Details',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.person, "Teacher", teacher),
            _buildDetailRow(Icons.access_time, "Time",
                "${schedule['start_time']} - ${schedule['end_time']}"),
            if (schedule['room'] != null) _buildDetailRow(Icons.location_on, "Room", schedule['room'].toString()),
            if (schedule['note'] != null && schedule['note'].toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text("Notes", style: theme.textTheme.titleSmall),
              Text(schedule['note'], style: theme.textTheme.bodyMedium),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: context.scale(20), color: theme.colorScheme.primary),
          SizedBox(width: context.scale(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11))),
                Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontSize: context.font(14))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget statusBox(String text) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.sm),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(text, style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _ScheduleSkeleton extends StatelessWidget {
  const _ScheduleSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: 22, height: 22, borderRadius: BorderRadius.circular(4)),
                SizedBox(width: context.sm),
                SkeletonBox(width: 200, height: 20, borderRadius: BorderRadius.circular(4)),
              ],
            ),
            SizedBox(height: context.xs),
            SkeletonBox(width: 100, height: 16, borderRadius: BorderRadius.circular(4)),
            SizedBox(height: context.lg),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: context.responsive(1, tablet: 2, desktop: 2),
                crossAxisSpacing: context.md,
                mainAxisSpacing: context.md,
                mainAxisExtent: context.scale(140),
              ),
              itemBuilder: (context, index) => Container(
                padding: EdgeInsets.all(context.md),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SkeletonBox(width: 150, height: 18, borderRadius: BorderRadius.circular(4)),
                    SizedBox(height: context.xs),
                    SkeletonBox(width: 100, height: 14, borderRadius: BorderRadius.circular(4)),
                    SizedBox(height: context.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonBox(width: 80, height: 16, borderRadius: BorderRadius.circular(4)),
                        SkeletonBox(width: 60, height: 20, borderRadius: BorderRadius.circular(20)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
