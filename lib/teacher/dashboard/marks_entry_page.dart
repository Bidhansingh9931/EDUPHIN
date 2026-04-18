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
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Marks"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scale(1000)),
          child: Column(
            children: [
              _buildFilterSection(),
              Expanded(
                child: _buildStudentsTable(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final theme = context.theme;
    return buildFilterCard(
      context,
      children: [
        buildLabel(context, "Filter by Class"),
        buildDropdown(context, ['All Classes', 'Class 10A', 'Class 12B'], _filters['class'], (val) => setState(() => _filters['class'] = val)),
        SizedBox(height: context.scale(16)),
        SizedBox(
          width: double.infinity,
          child: buildActionButton(context, "APPLY FILTERS", () => setState(() => _listKey = UniqueKey())),
        ),
      ]
    );
  }

  Widget _buildStudentsTable() {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.all(context.spacing),
      color: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.scale(16)),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(context.scale(20))),
            ),
            child: Row(
              children: [
                Icon(Icons.list_alt, size: context.scale(20), color: theme.colorScheme.primary),
                SizedBox(width: context.scale(8)),
                Text("Student List", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16), color: theme.colorScheme.onSurface)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.spacing),
            child: buildResponsiveRow(context, [
              Padding(
                padding: EdgeInsets.only(bottom: context.spacing),
                child: Row(
                  children: [
                    Text("Show entries", style: theme.textTheme.labelMedium?.copyWith(fontSize: context.font(12), color: theme.colorScheme.onSurfaceVariant)),
                    SizedBox(width: context.scale(4)),
                    Icon(Icons.keyboard_arrow_down, size: context.scale(16), color: theme.colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
              buildTextField(context, TextEditingController(), "Search Students...", prefixIcon: Icons.search),
            ]),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), thickness: 0.5),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTableHeader(),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), thickness: 0.5),
                  _buildStudentRow(1, "Aarav Mehta", "101"),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), thickness: 0.5),
                  _buildStudentRow(2, "Nisha Rao", "102"),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), thickness: 0.5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.scale(12)),
      child: Row(
        children: [
          SizedBox(width: context.scale(40), child: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
          Expanded(child: Text("NAME", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
          Expanded(child: Text("ROLL NO.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
        ],
      ),
    );
  }

  Widget _buildStudentRow(int id, String name, String roll) {
    final theme = context.theme;
    return InkWell(
      onTap: () {
        // Navigate to details or open marks entry
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.spacing, vertical: context.scale(16)),
        child: Row(
          children: [
            SizedBox(width: context.scale(40), child: Text("$id", style: TextStyle(fontSize: context.font(13)))),
            Expanded(child: Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14), color: theme.colorScheme.onSurface))),
            Expanded(child: Text(roll, style: TextStyle(fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
          ],
        ),
      ),
    );
  }
}
