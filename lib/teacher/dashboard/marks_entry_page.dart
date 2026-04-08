import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/marks_entry_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/exam_models.dart';
import 'common_widgets.dart';

class MarksEntryPage extends StatefulWidget {
  const MarksEntryPage({super.key});

  @override
  State<MarksEntryPage> createState() => _MarksEntryPageState();
}

class _MarksEntryPageState extends State<MarksEntryPage> {
  late Future<List<ExamPaper>> _papersFuture;
  final Map<String, String?> _filters = {'class': 'All Classes'};
  Key _listKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _papersFuture = ApiService.getExamPapers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Fees"), // Matching design 28 title
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _buildStudentsTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return buildFilterCard(
      context, 
      children: [
        Text("Filter by Class", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        buildDropdown(context, ['All Classes', 'Class 10A', 'Class 12B'], _filters['class'], (val) => setState(() => _filters['class'] = val)),
        const SizedBox(height: 16),
        buildActionButton(context, "APPLY FILTERS", () => setState(() => _listKey = UniqueKey())),
      ]
    );
  }

  Widget _buildStudentsTable() {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text("Student List", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text("Show entries", style: theme.textTheme.labelMedium),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, size: 14),
                const Spacer(),
                Container(
                  width: 120,
                  height: 32,
                  child: buildTextField(context, TextEditingController(), "Search Students.."),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          _buildTableHeader(),
          const Divider(height: 1),
          _buildStudentRow(1, "Aarav Mehta", ""),
          const Divider(height: 1),
          _buildStudentRow(2, "Nisha Rao", ""),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text("NAME", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text("ROLL NO.", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildStudentRow(int id, String name, String roll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text("$id")),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(roll)),
        ],
      ),
    );
  }
}
