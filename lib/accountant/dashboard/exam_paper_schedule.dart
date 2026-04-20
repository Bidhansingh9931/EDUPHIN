import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
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
  late Stream<Map<String, dynamic>> _scheduleStream;

  @override
  void initState() {
    super.initState();
    _scheduleStream = ApiService.getAccountantExamScheduleStream(widget.examId);
  }

  void _refresh() {
    setState(() {
      _scheduleStream = ApiService.getAccountantExamScheduleStream(widget.examId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Exam Schedule",
            style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, fontSize: context.font(20))),
        centerTitle: false,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _scheduleStream,
        builder: (context, snapshot) {
          return LoadingWrapper<Map<String, dynamic>>(
            snapshot: snapshot,
            onRetry: _refresh,
            skeleton: _buildSkeleton(context),
            builder: (data) {
              final examData = data['exam'] ?? data;
              final exam = (examData is Map<String, dynamic>)
                  ? Exam.fromJson(examData)
                  : null;

              final schedulesData = data['schedules'] ?? [];
              final schedules = (schedulesData is List)
                  ? schedulesData
                      .map((e) => ExamPaperSchedule.fromJson(e))
                      .toList()
                  : <ExamPaperSchedule>[];

              return RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: context.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: context.scale(1000)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (exam != null) _buildHeader(context, exam, schedules.length),
                          SizedBox(height: context.spacing * 1.5),
                          Text(
                            "Paper Schedule",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: context.spacing),
                          if (schedules.isEmpty)
                            _buildEmptyState(context)
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: schedules.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: context.spacing),
                              itemBuilder: (context, index) =>
                                  _buildScheduleCard(context, schedules[index]),
                            ),
                          SizedBox(height: context.spacing * 2),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(1000)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(height: context.scale(120), borderRadius: context.scale(20)),
              SizedBox(height: context.spacing * 1.5),
              Skeleton(width: context.scale(150), height: context.scale(20)),
              SizedBox(height: context.spacing),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => SizedBox(height: context.spacing),
                itemBuilder: (_, __) => Skeleton(
                  height: context.scale(80),
                  borderRadius: context.scale(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Exam exam, int scheduleCount) {
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
                  exam.name,
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
              _buildHeaderStat(context, "TOTAL PAPERS", scheduleCount.toString()),
              SizedBox(width: context.spacing * 2),
              _buildHeaderStat(context, "STATUS", exam.status?.toUpperCase() ?? "ACTIVE"),
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
