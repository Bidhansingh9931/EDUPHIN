import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'librarian_models.dart';
import 'exam_schedule_management.dart';

class ExaminationListPage extends StatefulWidget {
  const ExaminationListPage({super.key});

  @override
  State<ExaminationListPage> createState() => _ExaminationListPageState();
}

class _ExaminationListPageState extends State<ExaminationListPage> {
  bool _isLoading = true;
  List<ExamType> _exams = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchExams() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final exams = await ApiService.getLibrarianExams();
      if (mounted) {
        setState(() {
          _exams = exams;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching exams: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Examination List"),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchExams,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Search Active Exams", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _searchController,
                                  onChanged: (v) => setState(() {}),
                                  decoration: const InputDecoration(
                                    hintText: "Search by exam name...",
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text("Available Exams", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        if (_exams.isEmpty)
                          const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text("No exams found")))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _exams.where((e) => e.name.toLowerCase().contains(_searchController.text.toLowerCase())).length,
                            itemBuilder: (context, index) {
                              final filteredExams = _exams.where((e) => e.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
                              final exam = filteredExams[index];
                              return _buildExamCard(context, exam);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildExamCard(BuildContext context, ExamType exam) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Icon(Icons.assignment_outlined, color: theme.colorScheme.primary),
        ),
        title: Text(exam.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("ID: ${exam.id}", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          const Divider(),
          const SizedBox(height: 12),
          _buildInfoRow(context, "Status", exam.status ?? "Active"),
          const SizedBox(height: 8),
          _buildInfoRow(context, "Description", "Examination Type: ${exam.name}"),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
              child: const Text("VIEW SCHEDULE"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text("$label:", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor)),
        ),
        Expanded(
          child: Text(value, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
