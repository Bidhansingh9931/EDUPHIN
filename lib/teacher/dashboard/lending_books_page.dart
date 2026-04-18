import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart';
import 'package:intl/intl.dart';
import 'common_widgets.dart';

class LendingBooksPage extends StatefulWidget {
  const LendingBooksPage({super.key});

  @override
  State<LendingBooksPage> createState() => _LendingBooksPageState();
}

class _LendingBooksPageState extends State<LendingBooksPage> {
  final Map<String, String?> _filters = {
    'book_title': '', 'due_date_from': '', 'due_date_to': ''
  };
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  Key _listKey = UniqueKey();

  @override
  void dispose() {
    _titleController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.book_outlined, size: context.scale(20)),
            SizedBox(width: context.scale(12)),
            const Text("My Lending Books"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                _buildFilterSection(),
                _buildLendingTable(),
                SizedBox(height: context.scale(32)),
              ],
            ),
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
        Row(
          children: [
            Icon(Icons.filter_alt_outlined, size: context.scale(18), color: theme.colorScheme.primary),
            SizedBox(width: context.scale(8)),
            Text(
              "Filter Books",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.font(16),
              ),
            ),
          ],
        ),
        SizedBox(height: context.spacing),
        buildResponsiveRow(context, [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel("Book Title"),
              buildTextField(context, _titleController, "e.g. Math, Physics"),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel("Due Date From"),
              buildDateField(context, _fromDateController, "dd-mm-yyyy"),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel("Due Date To"),
              buildDateField(context, _toDateController, "dd-mm-yyyy"),
            ],
          ),
        ]),
        SizedBox(height: context.scale(24)),
        Row(
          children: [
            const Spacer(),
            SizedBox(
              width: context.scale(120),
              child: buildActionButton(
                context,
                "RESET",
                () => setState(() {
                  _titleController.clear();
                  _fromDateController.clear();
                  _toDateController.clear();
                  _listKey = UniqueKey();
                }),
                isPrimary: false,
              ),
            ),
            SizedBox(width: context.scale(12)),
            SizedBox(
              width: context.scale(120),
              child: buildActionButton(
                context,
                "FILTER",
                () => setState(() => _listKey = UniqueKey()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(top: context.spacing / 2, bottom: context.spacing / 4),
      child: Text(
        text,
        style: context.theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: context.font(12),
        ),
      ),
    );
  }

  Widget _buildLendingTable() {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: context.pagePadding,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.spacing),
            child: buildResponsiveRow(context, [
              Row(
                children: [
                  Text("Show Entries", style: theme.textTheme.labelMedium?.copyWith(fontSize: context.font(12), color: theme.colorScheme.onSurfaceVariant)),
                  SizedBox(width: context.scale(8)),
                  Icon(Icons.keyboard_arrow_down, size: context.scale(14), color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
              buildTextField(context, TextEditingController(), "Search...", prefixIcon: Icons.search),
            ]),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: context.scale(24),
                headingRowHeight: context.scale(56),
                dataRowMinHeight: context.scale(56),
                dataRowMaxHeight: context.scale(56),
                headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                columns: [
                  DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                  DataColumn(label: Text("Issue No.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                  DataColumn(label: Text("Book ID", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                  DataColumn(label: Text("Book Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Text("1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13)))),
                    DataCell(Text("2", style: TextStyle(fontSize: context.font(13)))),
                    DataCell(Text("4", style: TextStyle(fontSize: context.font(13)))),
                    DataCell(Text("Advanced Taxation Concepts", style: TextStyle(fontWeight: FontWeight.w500, fontSize: context.font(13)))),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
