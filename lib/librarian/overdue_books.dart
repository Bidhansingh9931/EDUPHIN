import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/librarian/librarian_skeleton_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'librarian_models.dart';
import 'package:intl/intl.dart';

class OverdueBooksPage extends StatefulWidget {
  const OverdueBooksPage({super.key});

  @override
  State<OverdueBooksPage> createState() => _OverdueBooksPageState();
}

class _OverdueBooksPageState extends State<OverdueBooksPage> {
  Stream<List<IssuedBook>>? _overdueBooksStream;

  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshStream();
  }

  void _refreshStream() {
    final Map<String, String> filters = {};
    if (_bookTitleController.text.isNotEmpty) filters['book_title'] = _bookTitleController.text;
    if (_userNameController.text.isNotEmpty) filters['user_name'] = _userNameController.text;
    if (_dateFromController.text.isNotEmpty) filters['due_from'] = _dateFromController.text;
    if (_dateToController.text.isNotEmpty) filters['due_to'] = _dateToController.text;
    if (_searchController.text.isNotEmpty) filters['search'] = _searchController.text;

    setState(() {
      _overdueBooksStream = ApiService.getLibrarianOverdueBooksStream(filters).asBroadcastStream();
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Overdue Books"),
        centerTitle: false,
      ),
      body: StreamBuilder<List<IssuedBook>>(
        stream: _overdueBooksStream,
        builder: (context, snapshot) {
          return RefreshIndicator(
            onRefresh: () async => _refreshStream(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: LoadingWrapper<List<IssuedBook>>(
                  snapshot: snapshot,
                  skeleton: const TableSkeleton(),
                  onRetry: _refreshStream,
                  builder: (overdueBooks) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: context.pagePadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// FILTER SECTION
                          Card(
                            elevation: 0,
                            color: colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.scale(20)),
                              side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(context.scale(16)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Filter Overdue Books",
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: context.scale(16)),
                                  _buildResponsiveRow(context, [
                                    _buildInputField(context, "Book Title", "e.g Math, Physics", _bookTitleController),
                                    _buildInputField(context, "User Name", "e.g John, Ayesha", _userNameController),
                                  ]),
                                  _buildResponsiveRow(context, [
                                    _buildDateField(context, "Due Date From", _dateFromController),
                                    _buildDateField(context, "Due Date To", _dateToController),
                                  ]),
                                  SizedBox(height: context.scale(12)),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton(
                                          onPressed: _refreshStream,
                                          style: FilledButton.styleFrom(
                                            padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                          ),
                                          child: const Text("APPLY FILTERS"),
                                        ),
                                      ),
                                      SizedBox(width: context.scale(12)),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              _bookTitleController.clear();
                                              _userNameController.clear();
                                              _dateFromController.clear();
                                              _dateToController.clear();
                                            });
                                            _refreshStream();
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                          ),
                                          child: const Text("RESET"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: context.scale(24)),

                          /// OVERDUE RECORDS SECTION
                          Card(
                            elevation: 0,
                            color: colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.scale(20)),
                              side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(context.scale(16)),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Overdue Records",
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      _exportIcon(context, Icons.picture_as_pdf, Colors.red),
                                      _exportIcon(context, Icons.table_chart, Colors.green),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: context.scale(16)),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (v) => _refreshStream(),
                                    style: TextStyle(fontSize: context.font(14)),
                                    decoration: InputDecoration(
                                      hintText: "Search books...",
                                      prefixIcon: const Icon(Icons.search),
                                      filled: true,
                                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(context.scale(12)),
                                        borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(context.scale(12)),
                                        borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(context.scale(12)),
                                        borderSide: BorderSide(color: colorScheme.primary, width: 1),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16)),
                                    ),
                                  ),
                                ),
                                SizedBox(height: context.scale(16)),
                                if (overdueBooks.isEmpty)
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: context.scale(40)),
                                      child: const Text("No overdue records found"),
                                    ),
                                  )
                                else
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(minWidth: 800),
                                      child: DataTable(
                                        headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
                                        dataRowMinHeight: context.scale(60),
                                        dataRowMaxHeight: context.scale(70),
                                        columnSpacing: context.scale(24),
                                        columns: [
                                          DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                          DataColumn(label: Text("ISSUE ID", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                          DataColumn(label: Text("BOOK TITLE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                          DataColumn(label: Text("LENDER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                          DataColumn(label: Text("DUE DATE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                          DataColumn(label: Text("ACTION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                        ],
                                        rows: overdueBooks.asMap().entries.map((entry) {
                                          int index = entry.key + 1;
                                          IssuedBook ib = entry.value;
                                          return _buildDataRow(context, index.toString(), ib);
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) {
      return Column(
        children: children.map((c) => Padding(padding: EdgeInsets.only(bottom: context.scale(12)), child: c)).toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .asMap()
          .entries
          .map((entry) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: entry.key < children.length - 1 ? context.scale(12) : 0),
                  child: entry.value,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildInputField(BuildContext context, String label, String hint, TextEditingController controller) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: context.scale(8)),
        TextField(
          controller: controller,
          style: TextStyle(fontSize: context.font(14)),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            contentPadding: EdgeInsets.all(context.scale(12)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(12)),
              borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(12)),
              borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.scale(12)),
              borderSide: BorderSide(color: colorScheme.primary, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: context.scale(8)),
        InkWell(
          onTap: () => _selectDate(context, controller),
          borderRadius: BorderRadius.circular(context.scale(12)),
          child: IgnorePointer(
            child: TextField(
              controller: controller,
              style: TextStyle(fontSize: context.font(14)),
              decoration: InputDecoration(
                hintText: "yyyy-mm-dd",
                suffixIcon: Icon(Icons.calendar_month, size: context.scale(18)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                contentPadding: EdgeInsets.all(context.scale(12)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.scale(12)),
                  borderSide: BorderSide(color: colorScheme.primary, width: 1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _exportIcon(BuildContext context, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(left: context.scale(8)),
      padding: EdgeInsets.all(context.scale(8)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(8)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: color, size: context.scale(16)),
    );
  }

  DataRow _buildDataRow(BuildContext context, String hash, IssuedBook ib) {
    final theme = context.theme;
    return DataRow(cells: [
      DataCell(Text(hash, style: TextStyle(fontSize: context.font(14)))),
      DataCell(Text(ib.id.toString(), style: TextStyle(fontSize: context.font(14)))),
      DataCell(Text(ib.bookTitle ?? "N/A", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
      DataCell(Text(ib.lenderName ?? "N/A", style: TextStyle(fontSize: context.font(14)))),
      DataCell(Text(ib.dueDate ?? "N/A", style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14)))),
      DataCell(IconButton(
        icon: Icon(Icons.check_circle_outline, color: Colors.green, size: context.scale(18)),
        onPressed: () async {
          try {
            await ApiService.returnIssuedBook(ib.id.toString());
            _refreshStream();
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Book returned successfully")));
          } catch (e) {
            if (context.mounted) ErrorHandler.showError(context, e);
          }
        },
      )),
    ]);
  }
}
