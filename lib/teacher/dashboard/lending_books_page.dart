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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.book_outlined, size: 20),
            SizedBox(width: 12),
            Text("My Lending Books"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFilterSection(),
            _buildLendingTable(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return buildFilterCard(
      context,
      children: [
        Row(
          children: [
            const Icon(Icons.filter_alt_outlined, size: 18),
            const SizedBox(width: 8),
            Text("Filter Books", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        _fieldLabel("Book Title"),
        buildTextField(context, _titleController, "e.g. Math, Physics"),
        _fieldLabel("Due Date From"),
        buildDateField(context, _fromDateController, "dd-mm-yyyy"),
        _fieldLabel("Due Date To"),
        buildDateField(context, _toDateController, "dd-mm-yyyy"),

        const SizedBox(height: 20),
        buildActionButton(context, "FILTER", () => setState(() => _listKey = UniqueKey())),
        const SizedBox(height: 10),
        buildActionButton(
          context, 
          "RESET", 
          () => setState(() {
            _titleController.clear();
            _fromDateController.clear();
            _toDateController.clear();
            _listKey = UniqueKey();
          }),
          isPrimary: false
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLendingTable() {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text("Show Entries", style: theme.textTheme.labelMedium),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, size: 14),
                const Spacer(),
                Container(
                  width: 120,
                  height: 32,
                  child: buildTextField(context, TextEditingController(), "search"),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          _buildTableHeader(),
          const Divider(height: 1),
          _buildLendingRow(1, "2", "4", "Advanced Taxation Concepts"),
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
          Expanded(child: Text("Issue No.", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          Expanded(child: Text("Book ID", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text("Book Title", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildLendingRow(int id, String issueNo, String bookId, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text("$id")),
          Expanded(child: Text(issueNo, textAlign: TextAlign.center)),
          Expanded(child: Text(bookId, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(title, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
