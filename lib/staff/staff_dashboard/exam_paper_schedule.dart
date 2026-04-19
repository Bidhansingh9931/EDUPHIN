import 'package:flutter/material.dart';
import 'package:eduphin/services/responsive_helper.dart';
import '../../services/api_service.dart';
import 'staff_models.dart';

class StaffExamPaperSchedulePage extends StatefulWidget {
  final String examId;
  final String examName;
  const StaffExamPaperSchedulePage({super.key, required this.examId, required this.examName});

  @override
  State<StaffExamPaperSchedulePage> createState() => _StaffExamPaperSchedulePageState();
}

class _StaffExamPaperSchedulePageState extends State<StaffExamPaperSchedulePage> {
  late Future<Map<String, dynamic>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  void _loadSchedule() {
    setState(() {
      _scheduleFuture = ApiService.getStaffExamSchedule(widget.examId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Examination Schedule"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData) {
            return Center(child: Text("No schedule found", style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)));
          }

          final data = snapshot.data!;
          final schedules = (data['schedules'] as List).map((s) => ExamPaperSchedule.fromJson(s)).toList();

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(context),
                    SizedBox(height: context.spacing * 2),
                    Text(
                      "Examination Papers",
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
                    ),
                    SizedBox(height: context.spacing),
                    if (schedules.isEmpty)
                      _buildEmptyState(context)
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: schedules.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: context.spacing,
                              mainAxisSpacing: context.spacing,
                              mainAxisExtent: context.scale(160),
                            ),
                            itemBuilder: (context, index) => _buildPaperCard(context, schedules[index]),
                          );
                        },
                      ),
                    SizedBox(height: context.spacing * 2),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.spacing * 1.5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(context.scale(24)),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.event_note_rounded, color: theme.colorScheme.primary, size: context.scale(48)),
          SizedBox(height: context.spacing),
          Text(
            widget.examName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer, fontSize: context.font(22)),
          ),
          SizedBox(height: context.scale(4)),
          Text(
            "Full Schedule Overview",
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperCard(BuildContext context, ExamPaperSchedule paper) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.scale(20)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paper.subject,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: context.font(16)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: context.scale(12)),
          _buildInfoRow(context, Icons.calendar_today_outlined, paper.date),
          SizedBox(height: context.scale(8)),
          _buildInfoRow(context, Icons.access_time_rounded, "${paper.startTime} - ${paper.endTime}"),
          if (paper.venue != null && paper.venue!.isNotEmpty) ...[
            SizedBox(height: context.scale(8)),
            _buildInfoRow(context, Icons.location_on_outlined, paper.venue!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: context.scale(14)),
        SizedBox(width: context.scale(10)),
        Expanded(
          child: Text(
            text, 
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.spacing * 2),
        child: Column(
          children: [
            Icon(Icons.event_busy_outlined, color: context.theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), size: context.scale(64)),
            SizedBox(height: context.spacing),
            Text("No papers scheduled for this exam yet.", style: context.theme.textTheme.bodyMedium?.copyWith(color: context.theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: context.scale(60)),
            SizedBox(height: context.spacing * 1.5),
            Text(
              "Failed to load schedule",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: context.scale(12)),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            ),
            SizedBox(height: context.spacing * 2),
            FilledButton.tonal(
              onPressed: _loadSchedule,
              child: const Text("RETRY"),
            ),
          ],
        ),
      ),
    );
  }
}
