import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/accountant/dashboard/accountant_dashboard_model.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';

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
        final currentTheme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: currentTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: "Retry",
              textColor: currentTheme.colorScheme.onError,
              onPressed: _fetchSchedule,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Exam Schedule", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20))),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSchedule,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.scale(1000)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_exam != null) _buildHeader(context),
                        SizedBox(height: context.spacing * 1.5),
                        Text(
                          "Paper Schedule",
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: context.spacing),
                        if (_schedules.isEmpty) 
                          _buildEmptyState(context)
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _schedules.length,
                            separatorBuilder: (context, index) => SizedBox(height: context.spacing),
                            itemBuilder: (context, index) => _buildScheduleCard(context, _schedules[index]),
                          ),
                        SizedBox(height: context.spacing * 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(context.scale(20)),
      ),
      padding: EdgeInsets.all(context.spacing * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.scale(10)),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: context.scale(24),
                ),
              ),
              SizedBox(width: context.spacing),
              Expanded(
                child: Text(
                  _exam?.name ?? "Examination",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: context.font(20),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing * 1.5),
          Row(
            children: [
              _buildHeaderStat(context, "TOTAL PAPERS", _schedules.length.toString()),
              SizedBox(width: context.spacing * 2),
              _buildHeaderStat(context, "STATUS", _exam?.status?.toUpperCase() ?? "ACTIVE"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(BuildContext context, String label, String value) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: context.font(10),
          ),
        ),
        SizedBox(height: context.scale(4)),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
            fontSize: context.font(14),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(BuildContext context, ExamPaperSchedule schedule) {
    final theme = context.theme;
    final subjectName = (schedule.subject is Map) 
        ? (schedule.subject?['name'] ?? 'Unknown Subject') 
        : (schedule.paperName ?? 'N/A');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: EdgeInsets.all(context.spacing),
      child: Row(
        children: [
          Container(
            width: context.scale(56),
            height: context.scale(56),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(context.scale(12)),
            ),
            child: Icon(
              Icons.menu_book,
              color: theme.colorScheme.onSecondaryContainer,
              size: context.scale(24),
            ),
          ),
          SizedBox(width: context.spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectName,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14)),
                ),
                SizedBox(height: context.scale(8)),
                Wrap(
                  spacing: context.spacing,
                  runSpacing: context.scale(4),
                  children: [
                    _buildInfoItem(context, Icons.calendar_today, schedule.date ?? 'N/A'),
                    _buildInfoItem(context, Icons.access_time, "${schedule.startTime ?? '--'} - ${schedule.endTime ?? '--'}"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    final theme = context.theme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: theme.colorScheme.secondary, size: context.scale(14)),
        SizedBox(width: context.scale(6)),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: context.font(12),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scale(60)),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.event_note_outlined,
              color: theme.colorScheme.outlineVariant,
              size: context.scale(64),
            ),
            SizedBox(height: context.spacing),
            Text(
              "No schedule details found",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: context.font(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
