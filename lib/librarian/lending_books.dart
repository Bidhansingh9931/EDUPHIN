import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'librarian_models.dart';
import 'package:intl/intl.dart';

class MyLendingBooksPage extends StatefulWidget {
  const MyLendingBooksPage({super.key});

  @override
  State<MyLendingBooksPage> createState() => _MyLendingBooksPageState();
}

class _MyLendingBooksPageState extends State<MyLendingBooksPage> {
  bool _isLoading = true;
  List<IssuedBook> _myIssuedBooks = [];

  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMyIssuedBooks();
  }

  Future<void> _fetchMyIssuedBooks() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final filters = {
        'book_title': _bookTitleController.text,
        'date_from': _dateFromController.text,
        'date_to': _dateToController.text,
      };
      final books = await ApiService.getLibrarianMyIssuedBooks(filters);
      if (!mounted) return;
      setState(() {
        _myIssuedBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
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
        title: const Text("My Lending Books"),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchMyIssuedBooks,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: SingleChildScrollView(
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
                                  "Filter My Lending Books",
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: context.scale(16)),
                                _buildResponsiveRow(context, [
                                  _buildInputField(context, "Book Title", "e.g Math, Physics", _bookTitleController),
                                  _buildDateField(context, "Due Date From", _dateFromController),
                                ]),
                                SizedBox(height: context.isTablet ? 0 : context.scale(12)),
                                _buildResponsiveRow(context, [
                                  _buildDateField(context, "Due Date To", _dateToController),
                                  const SizedBox.shrink(), // Spacer for alignment in tablet mode if needed
                                ]),
                                SizedBox(height: context.scale(12)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: _fetchMyIssuedBooks,
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
                                            _dateFromController.clear();
                                            _dateToController.clear();
                                          });
                                          _fetchMyIssuedBooks();
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

                        /// RECORDS SECTION
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
                                      "Lending Records",
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    _exportIcon(context, Icons.description, Colors.teal),
                                    _exportIcon(context, Icons.table_chart, Colors.green),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: context.scale(16)),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (v) => setState(() {}),
                                  style: TextStyle(fontSize: context.font(14)),
                                  decoration: InputDecoration(
                                    hintText: "Quick search...",
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
                              if (_myIssuedBooks.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: context.scale(40)),
                                    child: const Text("No lending records found"),
                                  ),
                                )
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(minWidth: 900),
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
                                      dataRowMinHeight: context.scale(60),
                                      dataRowMaxHeight: context.scale(70),
                                      columnSpacing: context.scale(24),
                                      columns: [
                                        DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                        DataColumn(label: Text("ISSUE ID", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                        DataColumn(label: Text("BOOK TITLE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                        DataColumn(label: Text("ISSUED AT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                        DataColumn(label: Text("DUE DATE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                        DataColumn(label: Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                      ],
                                      rows: _myIssuedBooks
                                          .where((ib) => (ib.bookTitle ?? "").toLowerCase().contains(_searchController.text.toLowerCase()))
                                          .toList()
                                          .asMap()
                                          .entries
                                          .map((entry) {
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
                  ),
                ),
              ),
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
    bool isOverdue = false;
    try {
      if (ib.returnedAt == null && ib.dueDate != null && ib.dueDate!.isNotEmpty) {
        isOverdue = DateTime.parse(ib.dueDate!).isBefore(DateTime.now());
      }
    } catch (_) {}

    final statusColor = ib.returnedAt != null ? Colors.green : (isOverdue ? Colors.red : Colors.orange);

    return DataRow(cells: [
      DataCell(Text(hash, style: TextStyle(fontSize: context.font(14)))),
      DataCell(Text(ib.id.toString(), style: TextStyle(fontSize: context.font(14)))),
      DataCell(Text(ib.bookTitle ?? "N/A", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
      DataCell(Text(ib.issuedAt ?? "N/A", style: TextStyle(fontSize: context.font(14)))),
      DataCell(Text(ib.dueDate ?? "N/A", style: TextStyle(fontSize: context.font(14)))),
      DataCell(Container(
        padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(context.scale(20)),
          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        ),
        child: Text(
          ib.returnedAt != null ? "RETURNED" : (isOverdue ? "OVERDUE" : "PENDING"),
          style: TextStyle(color: statusColor, fontSize: context.font(10), fontWeight: FontWeight.bold),
        ),
      )),
    ]);
  }
}
