import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/exam_models.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'common_widgets.dart';
import 'exam_schedule_page.dart';

class ExamInformationPage extends StatefulWidget {
  const ExamInformationPage({super.key});

  @override
  State<ExamInformationPage> createState() => _ExamInformationPageState();
}

class _ExamInformationPageState extends State<ExamInformationPage> {
  ExamPageData? _examData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    const cacheKey = 'exam_information';

    // 1. Load from cache
    final cachedData = await TeacherCacheService.load(cacheKey);
    if (cachedData != null && mounted) {
      setState(() {
        _examData = ExamPageData.fromJson(cachedData);
        _isLoading = false;
      });
    }

    // 2. Fetch from API
    try {
      final data = await ApiService.getTeacherExams();
      if (mounted) {
        setState(() {
          _examData = data;
          _isLoading = false;
          _errorMessage = null;
        });
        // 3. Save to cache
        await TeacherCacheService.save(cacheKey, data.toJson());
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = ErrorHandler.getMessage(e);
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
        if (_examData != null) {
          ErrorHandler.showError(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Information"),
      ),
      body: TeacherLoadingWrapper(
        isLoading: _isLoading,
        hasData: _examData != null,
        skeleton: _buildSkeleton(),
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: _errorMessage != null && _examData == null
              ? Center(child: Text("Error: $_errorMessage", style: TextStyle(fontSize: context.font(14))))
              : (_examData == null || _examData!.exams.isEmpty)
                  ? Center(child: Text("No exams found.", style: TextStyle(fontSize: context.font(14))))
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: context.scale(20)),
        child: TeacherSkeleton(height: context.scale(180), borderRadius: BorderRadius.circular(context.scale(20))),
      ),
    );
  }

  Widget _buildContent() {
    final exams = _examData!.exams;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.responsive(800.0, tablet: 1000.0, desktop: 1200.0)),
        child: ListView.builder(
          padding: context.pagePadding,
          itemCount: exams.length,
          itemBuilder: (context, index) => _buildExamCard(exams[index]),
        ),
      ),
    );
  }

  Widget _buildExamCard(TeacherExam exam) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: context.scale(20)),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(20.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(exam.name, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: context.font(16),
                      color: colorScheme.onSurface,
                    )
                  )
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(context.scale(8))
                  ),
                  child: Text(exam.code, 
                    style: TextStyle(
                      color: colorScheme.primary, 
                      fontSize: context.font(10), 
                      fontWeight: FontWeight.bold
                    )
                  ),
                )
              ],
            ),
            SizedBox(height: context.scale(12)),
            Text(exam.description ?? "General examination information and instructions.", 
              style: TextStyle(
                fontSize: context.font(12),
                color: colorScheme.onSurfaceVariant,
              )
            ),
            Divider(height: context.scale(32), color: colorScheme.outlineVariant),
            Row(
              children: [
                _infoTile(Icons.calendar_today, "Starts", exam.startDate),
                SizedBox(width: context.scale(24)),
                _infoTile(Icons.event_available, "Ends", exam.endDate),
              ],
            ),
            SizedBox(height: context.scale(24)),
            buildActionButton(
              context, 
              "VIEW FULL SCHEDULE", 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExamSchedulePage(examId: exam.id))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String date) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: context.scale(14), color: colorScheme.primary),
            SizedBox(width: context.scale(6)),
            Text(label, style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: context.font(11),
              color: colorScheme.onSurfaceVariant,
            )),
          ],
        ),
        SizedBox(height: context.scale(4)),
        Text(date, style: TextStyle(
          fontSize: context.font(12),
          color: colorScheme.onSurface,
        )),
      ],
    );
  }
}

