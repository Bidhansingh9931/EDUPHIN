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
  bool _isLoading = true;
  List<Exam> _exams = [];

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  Future<void> _fetchExams() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final examsData = await ApiService.getAccountantExams();
      if (mounted) {
        setState(() {
          _exams = (examsData as List).map((e) => Exam.fromJson(e)).toList();
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching exams: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Examinations"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchExams,
              child: _exams.isEmpty
                  ? _buildEmptyState(context)
                  : GridView.builder(
                      padding: context.pagePadding,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.isTablet ? 2 : 1,
                        mainAxisExtent: 220,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _exams.length,
                      itemBuilder: (context, index) {
                        return _buildExamCard(context, _exams[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, color: Theme.of(context).hintColor.withValues(alpha: 0.3), size: 64),
          const SizedBox(height: 16),
          Text("No examinations found", style: TextStyle(color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, Exam exam) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.description_rounded, color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exam.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text("Code: EXAM${exam.id}", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                _buildDateInfo(context, "START", exam.startDate ?? 'N/A'),
                const Spacer(),
                _buildDateInfo(context, "END", exam.endDate ?? 'N/A', alignRight: true),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final targetId = exam.encryptedId ?? exam.id.toString();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExamPaperSchedulePage(examId: targetId)));
                },
                child: const Text("VIEW SCHEDULE"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(BuildContext context, String label, String date, {bool alignRight = false}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
