import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/accountant/dashboard/accountant_dashboard_model.dart';
import 'exam_paper_schedule.dart';

class ExamListPage extends StatefulWidget {
  const ExamListPage({super.key});

  @override
  State<ExamListPage> createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage> {
  late Stream<List<Exam>> _examsStream;

  @override
  void initState() {
    super.initState();
    _examsStream = ApiService.getAccountantExamsStream();
  }

  void _refreshExams() {
    setState(() {
      _examsStream = ApiService.getAccountantExamsStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("Examinations", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20))),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _refreshExams),
        ],
      ),
      body: StreamBuilder<List<Exam>>(
        stream: _examsStream,
        builder: (context, snapshot) {
          return LoadingWrapper<List<Exam>>(
            snapshot: snapshot,
            skeleton: _buildSkeleton(context),
            onRetry: _refreshExams,
            builder: (exams) {
              return RefreshIndicator(
                onRefresh: () async => _refreshExams(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: ListView(
                      padding: context.pagePadding,
                      children: [
                        _buildSectionHeader("Active Examinations", Icons.assignment_outlined),
                        SizedBox(height: context.md),
                        exams.isEmpty
                            ? _buildEmptyState(context)
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                                  mainAxisExtent: context.scale(230),
                                  crossAxisSpacing: context.spacing,
                                  mainAxisSpacing: context.spacing,
                                ),
                                itemCount: exams.length,
                                itemBuilder: (context, index) {
                                  return _buildExamCard(context, exams[index]);
                                },
                              ),
                      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Skeleton(width: 20, height: 20, borderRadius: 4),
            SizedBox(width: context.scale(8)),
            const Skeleton(width: 150, height: 20, borderRadius: 4),
          ]),
          SizedBox(height: context.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
              mainAxisExtent: context.scale(230),
              crossAxisSpacing: context.spacing,
              mainAxisSpacing: context.spacing,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
              child: Padding(
                padding: EdgeInsets.all(context.md),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Skeleton(width: 40, height: 40, borderRadius: context.scale(12)),
                    SizedBox(width: context.md),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Skeleton(width: 120, height: 16, borderRadius: 4),
                      const SizedBox(height: 4),
                      Skeleton(width: 80, height: 12, borderRadius: 4),
                    ]),
                  ]),
                  const Spacer(),
                  Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Skeleton(width: 60, height: 10, borderRadius: 2),
                      const SizedBox(height: 4),
                      Skeleton(width: 80, height: 14, borderRadius: 4),
                    ]),
                    const Spacer(),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Skeleton(width: 60, height: 10, borderRadius: 2),
                      const SizedBox(height: 4),
                      Skeleton(width: 80, height: 14, borderRadius: 4),
                    ]),
                  ]),
                  const Spacer(),
                  Skeleton(width: double.infinity, height: context.scale(44), borderRadius: context.scale(12)),
                ]),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            color: theme.colorScheme.outlineVariant,
            size: context.scale(64),
          ),
          SizedBox(height: context.md),
          Text(
            "No examinations found",
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          SizedBox(height: context.md),
          TextButton.icon(
            onPressed: _refreshExams,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, Exam exam) {
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
        padding: EdgeInsets.all(context.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.scale(8)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(context.scale(12)),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: context.scale(24),
                  ),
                ),
                SizedBox(width: context.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: context.font(15),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Exam ID: EXAM${exam.id}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontSize: context.font(11),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                _buildDateInfo(context, "START DATE", exam.startDate ?? 'N/A'),
                const Spacer(),
                _buildDateInfo(context, "END DATE", exam.endDate ?? 'N/A', alignRight: true),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: context.scale(44),
              child: FilledButton.tonal(
                onPressed: () {
                  final targetId = exam.encryptedId ?? exam.id.toString();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExamPaperSchedulePage(examId: targetId)),
                  );
                },
                style: FilledButton.styleFrom(
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

  Widget _buildDateInfo(BuildContext context, String label, String date, {bool alignRight = false}) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: context.font(10),
          ),
        ),
        SizedBox(height: context.scale(4)),
        Text(
          date,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12)),
        ),
      ],
    );
  }
}
