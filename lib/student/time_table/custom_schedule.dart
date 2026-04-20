import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eduphin/services/api_service.dart';

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
    _fetchDatewiseSchedule();
  }

  Future<void> _fetchDatewiseSchedule() async {
    if (selectedDate == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final data = await ApiService.getStudentDateWiseRoutine(formattedDate);
      setState(() {
        _scheduleData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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
      });
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
                  if (_errorMessage != null)
                    Center(child: Text(_errorMessage!.toString(), style: TextStyle(color: theme.colorScheme.error)))
                  else if (_scheduleData != null)
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
      padding: EdgeInsets.all(context.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOverride ? const Color(0xFFF59E0B).withValues(alpha: 0.5) : colorScheme.outlineVariant),
      ),
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
                  decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5))),
                  child: const Text("OVERRIDE", style: TextStyle(color: Color(0xFFF59E0B), fontSize: 9, fontWeight: FontWeight.bold)),
                ),
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
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
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
              Text("$startTime - $endTime", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              if (!isOverride)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5))),
                  child: const Text("REGULAR", style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
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
