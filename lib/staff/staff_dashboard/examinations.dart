import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import 'staff_models.dart';
import 'exam_paper_schedule.dart';

class StaffExaminationsPage extends StatefulWidget {
  const StaffExaminationsPage({super.key});

  @override
  State<StaffExaminationsPage> createState() => _StaffExaminationsPageState();
}

class _StaffExaminationsPageState extends State<StaffExaminationsPage> {
  late Stream<List<Exam>> _examsStream;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  void _loadExams() {
    setState(() {
      _examsStream = ApiService.getStaffExamsStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Examinations", style: TextStyle(fontSize: context.font(20))),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadExams(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: StreamBuilder<List<Exam>>(
                stream: _examsStream,
                builder: (context, snapshot) {
                  return LoadingWrapper<List<Exam>>(
                    snapshot: snapshot,
                    skeleton: _buildSkeleton(context),
                    onRetry: _loadExams,
                    builder: (exams) {
                      if (exams.isEmpty) return _buildEmptyState(context);

                      return GridView.builder(
                        padding: context.pagePadding,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                          crossAxisSpacing: context.spacing,
                          mainAxisSpacing: context.spacing,
                          mainAxisExtent: context.scale(240),
                        ),
                        itemCount: exams.length,
                        itemBuilder: (context, index) => _buildExamCard(context, exams[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Padding(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.only(top: context.scale(40)),
            color: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.scale(24)),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.scale(60), horizontal: context.scale(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: context.scale(80), color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
                  SizedBox(height: context.scale(24)),
                  Text(
                    "No exams available",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: context.font(20),
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: context.scale(12)),
                  Text(
                    "Currently, there are no examination schedules published for your department.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.font(14),
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, Exam exam) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scale(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: context.scale(44),
                  height: context.scale(44),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.scale(12)),
                  ),
                  child: Icon(Icons.assignment_outlined, color: colorScheme.primary, size: context.scale(22)),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.scale(6)),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    exam.status?.toUpperCase() ?? 'ACTIVE', 
                    style: TextStyle(color: Colors.green, fontSize: context.font(10), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.scale(16)),
            Expanded(
              child: Text(
                exam.name, 
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold, 
                  fontSize: context.font(16),
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: context.scale(20)),
            SizedBox(
              width: double.infinity,
              height: context.scale(44),
              child: FilledButton.tonal(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffExamPaperSchedulePage(
                        examId: exam.encryptedId ?? exam.id.toString(), 
                        examName: exam.name,
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                ),
                child: Text("VIEW FULL SCHEDULE", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return GridView.builder(
      padding: context.pagePadding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
        crossAxisSpacing: context.spacing,
        mainAxisSpacing: context.spacing,
        mainAxisExtent: context.scale(240),
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: context.theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.scale(20)),
          side: BorderSide(color: context.theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.scale(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Skeleton(width: context.scale(44), height: context.scale(44), borderRadius: context.scale(12)),
                  const Spacer(),
                  Skeleton(width: context.scale(60), height: context.scale(20), borderRadius: context.scale(6)),
                ],
              ),
              SizedBox(height: context.scale(16)),
              Skeleton(width: double.infinity, height: context.scale(18)),
              SizedBox(height: context.scale(8)),
              Skeleton(width: context.scale(150), height: context.scale(18)),
              const Spacer(),
              Skeleton(width: double.infinity, height: context.scale(44), borderRadius: context.scale(12)),
            ],
          ),
        ),
      ),
    );
  }
}
