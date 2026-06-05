import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/teacher/dashboard/exam_schedule_page.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/exam_models.dart';
import 'common_widgets.dart';
import 'app_drawer.dart';

class ExamListPage extends StatefulWidget {
  const ExamListPage({super.key});

  @override
  State<ExamListPage> createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage> {
  ExamPageData? _examData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final cachedData = await TeacherCacheService.load('exams');
    if (cachedData != null && mounted) {
      setState(() {
        _examData = ExamPageData.fromJson(cachedData);
        _isLoading = false;
      });
    }
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    if (!mounted) return;
    if (_examData == null) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await ApiService.getTeacherExams();
      if (mounted) {
        setState(() {
          _examData = data;
          _isLoading = false;
        });
        await TeacherCacheService.save('exams', data.toJson());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Examinations", 
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20))),
        centerTitle: false,
      ),
      drawer: const AppDrawer(),
      body: TeacherLoadingWrapper(
        isLoading: _isLoading,
        hasData: _examData != null,
        skeleton: _buildSkeleton(context),
        child: RefreshIndicator(
          onRefresh: _fetchExams,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.scale(1200)),
              child: _examData != null ? ListView(
                padding: context.pagePadding,
                children: [
                  _buildSectionHeader("Active Examinations", Icons.assignment_outlined),
                  SizedBox(height: context.md),
                  if (_examData!.exams.isEmpty)
                    _buildEmptyState()
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                        crossAxisSpacing: context.scale(16),
                        mainAxisSpacing: context.scale(16),
                        mainAxisExtent: context.scale(230),
                      ),
                      itemCount: _examData!.exams.length,
                      itemBuilder: (context, index) => _buildExamCard(_examData!.exams[index]),
                    ),
                ],
              ) : const Center(child: Text("No data available")),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView(
      padding: context.pagePadding,
      children: [
        const TeacherSkeleton(height: 25, width: 200),
        SizedBox(height: context.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
            crossAxisSpacing: context.scale(16),
            mainAxisSpacing: context.scale(16),
            mainAxisExtent: context.scale(230),
          ),
          itemCount: 6,
          itemBuilder: (context, index) => TeacherSkeleton(height: context.scale(230), borderRadius: BorderRadius.circular(16)),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, size: context.scale(20), color: theme.colorScheme.primary),
        SizedBox(width: context.scale(8)),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: context.font(18),
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.scale(24.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: context.scale(48), color: theme.colorScheme.error),
            SizedBox(height: context.scale(16)),
            Text("Failed to load exams", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
            SizedBox(height: context.scale(8)),
            Text(error, style: theme.textTheme.bodySmall?.copyWith(fontSize: context.font(12)), textAlign: TextAlign.center),
            SizedBox(height: context.scale(24)),
            ElevatedButton(
              onPressed: _fetchExams,
              child: const Text("Retry"),
            )
          ],
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
          Icon(Icons.assignment_outlined, size: context.scale(64), color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          SizedBox(height: context.scale(16)),
          Text("No exams found", style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline, fontWeight: FontWeight.bold, fontSize: context.font(16))),
        ],
      ),
    );
  }

  Widget _buildExamCard(TeacherExam exam) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(16.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(exam.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(15), color: theme.colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(context.scale(8)),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                  ),
                  child: Text(exam.code, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.1, fontSize: context.font(10), color: theme.colorScheme.onSurfaceVariant)),
                )
              ],
            ),
            SizedBox(height: context.scale(12)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(context.scale(6)),
              ),
              child: Text(exam.type.toUpperCase(), style: TextStyle(color: theme.colorScheme.primary, fontSize: context.font(10), fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            _infoRow("Start Date:", exam.startDate),
            _infoRow("End Date:", exam.endDate),
            SizedBox(height: context.scale(12)),
            SizedBox(
              width: double.infinity,
              height: context.scale(44),
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExamSchedulePage(examId: exam.id))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                ),
                child: Text("VIEW SCHEDULE", style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(6)),
      child: Row(
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(11))),
          SizedBox(width: context.scale(8)),
          Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(11), color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}
