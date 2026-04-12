import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/accountant/dashboard/accountant_dashboard_model.dart';

class ExamPaperSchedulePage extends StatefulWidget {
  final String examId;
  const ExamPaperSchedulePage({super.key, required this.examId});

  @override
  State<ExamPaperSchedulePage> createState() => _ExamPaperSchedulePageState();
}

class _ExamPaperSchedulePageState extends State<ExamPaperSchedulePage> {
  bool _isLoading = true;
  Exam? _exam;
  List<ExamPaperSchedule> _schedules = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getAccountantExamSchedule(widget.examId);
      if (mounted) {
        setState(() {
          final examData = data['exam'] ?? data;
          _exam = (examData is Map<String, dynamic>) ? Exam.fromJson(examData) : null;
          
          final schedulesData = data['schedules'] ?? [];
          if (schedulesData is List) {
            _schedules = schedulesData
                .map((e) => ExamPaperSchedule.fromJson(e))
                .toList();
          } else {
            _schedules = [];
          }
        });
      }
    } catch (e) {
      debugPrint("Schedule Fetch Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: "Retry", textColor: Colors.white, onPressed: _fetchSchedule),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Schedule"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSchedule,
              child: SingleChildScrollView(
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        if (_exam != null) _buildHeader(context),
                        const SizedBox(height: 24),
                        if (_schedules.isEmpty) 
                          _buildEmptyState(context)
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _schedules.length,
                            itemBuilder: (context, index) => _buildScheduleCard(context, _schedules[index]),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: theme.colorScheme.onPrimaryContainer, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _exam?.name ?? "Examination",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildHeaderStat(context, "TOTAL PAPERS", _schedules.length.toString()),
                const SizedBox(width: 32),
                _buildHeaderStat(context, "STATUS", _exam?.status?.toUpperCase() ?? "ACTIVE"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7), fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
      ],
    );
  }

  Widget _buildScheduleCard(BuildContext context, ExamPaperSchedule schedule) {
    final theme = Theme.of(context);
    final subjectName = (schedule.subject is Map) 
        ? (schedule.subject?['name'] ?? 'Unknown Subject') 
        : (schedule.paperName ?? 'N/A');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.menu_book, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: theme.hintColor, size: 12),
                      const SizedBox(width: 6),
                      Text(schedule.date ?? 'N/A', style: TextStyle(color: theme.hintColor, fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, color: theme.hintColor, size: 12),
                      const SizedBox(width: 6),
                      Text("${schedule.startTime ?? '--'} - ${schedule.endTime ?? '--'}", style: TextStyle(color: theme.hintColor, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          Icon(Icons.event_note_outlined, color: Theme.of(context).hintColor.withValues(alpha: 0.3), size: 64),
          const SizedBox(height: 16),
          Text("No schedule details found", style: TextStyle(color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }
}
