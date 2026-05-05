import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/librarian/librarian_skeleton_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/common_widgets.dart';
import 'librarian_models.dart';
import 'exam_schedule_management.dart';

class ExaminationListPage extends StatefulWidget {
  const ExaminationListPage({super.key});

  @override
  State<ExaminationListPage> createState() => _ExaminationListPageState();
}

class _ExaminationListPageState extends State<ExaminationListPage> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<ExamType>> _examsStream;

  @override
  void initState() {
    super.initState();
    _examsStream = ApiService.getLibrarianExamsStream().asBroadcastStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshExams() {
    setState(() {
      _examsStream = ApiService.getLibrarianExamsStream().asBroadcastStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Examination List"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ExamType>>(
        stream: _examsStream,
        builder: (context, snapshot) {
          return LoadingWrapper<List<ExamType>>(
            snapshot: snapshot,
            skeleton: const TicketSkeleton(),
            onRetry: _refreshExams,
            builder: (exams) {
              return RefreshIndicator(
                onRefresh: () async => _refreshExams(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: context.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: context.responsive(800.0, tablet: 1000.0, desktop: 1200.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// SEARCH CARD
                          Card(
                            elevation: 0,
                            color: colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.scale(20)),
                              side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(context.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.search, color: colorScheme.primary, size: context.scale(20)),
                                      SizedBox(width: context.sm),
                                      Text(
                                        "Search Active Exams",
                                        style: TextStyle(
                                          fontSize: context.font(16),
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: context.md),
                                  TextField(
                                    controller: _searchController,
                                    onChanged: (v) => setState(() {}),
                                    style: TextStyle(fontSize: context.font(14)),
                                    decoration: InputDecoration(
                                      hintText: "Search by exam name...",
                                      filled: true,
                                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                      prefixIcon: Icon(Icons.manage_search, size: context.scale(22)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(context.scale(12)),
                                        borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(context.scale(12)),
                                        borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(context.scale(12)),
                                        borderSide: BorderSide(color: colorScheme.primary, width: 1),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.sm),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: context.xl),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: context.xs),
                            child: Text(
                              "Available Exams",
                              style: TextStyle(
                                fontSize: context.font(16),
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          SizedBox(height: context.md),

                          _buildExamList(colorScheme, exams),
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

  Widget _buildExamList(ColorScheme colorScheme, List<ExamType> exams) {
    final filteredExams = exams.where((e) => e.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();

    if (filteredExams.isEmpty) {
      return Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.scale(20)),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.scale(40)),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.assignment_late_outlined, size: context.scale(48), color: colorScheme.outline),
                SizedBox(height: context.scale(16)),
                Text(
                  "No exams found",
                  style: TextStyle(fontSize: context.font(14), color: colorScheme.outline),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredExams.length,
      itemBuilder: (context, index) {
        final exam = filteredExams[index];
        return _buildExamCard(context, exam, colorScheme);
      },
    );
  }

  Widget _buildExamCard(BuildContext context, ExamType exam, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: context.md),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        iconColor: colorScheme.primary,
        collapsedIconColor: colorScheme.outline,
        leading: Container(
          padding: EdgeInsets.all(context.sm),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(context.scale(8)),
          ),
          child: Icon(Icons.assignment_outlined, color: colorScheme.primary, size: context.scale(20)),
        ),
        title: Text(
          exam.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: context.font(16),
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          "ID: ${exam.id}",
          style: TextStyle(fontSize: context.font(12), color: colorScheme.outline),
        ),
        childrenPadding: EdgeInsets.all(context.md),
        children: [
          const Divider(),
          SizedBox(height: context.sm),
          _buildInfoRow(context, "Status", exam.status ?? "Active", colorScheme),
          SizedBox(height: context.sm),
          _buildInfoRow(context, "Description", "Examination Type: ${exam.name}", colorScheme),
          SizedBox(height: context.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExamScheduleManagementPage(
                      examId: exam.id,
                      examTitle: exam.name,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month, size: 18),
              label: const Text("VIEW SCHEDULE"),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: context.md),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.scale(100),
          child: Text(
            "$label:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.outline,
              fontSize: context.font(13),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: context.font(14),
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
