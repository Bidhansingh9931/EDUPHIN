import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';

class MyLendingBooksPage extends StatefulWidget {
  const MyLendingBooksPage({super.key});

  @override
  State<MyLendingBooksPage> createState() => _MyLendingBooksPageState();
}

class _MyLendingBooksPageState extends State<MyLendingBooksPage> {
  List<dynamic> _issuedBooks = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Filters
  final Map<String, String> _filters = {
    'book_title': '',
    'due_from': '',
    'due_to': '',
  };

  @override
  void initState() {
    super.initState();
    _fetchLendingBooks();
  }

  Future<void> _fetchLendingBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getStudentLendingBooks(_filters, 1);
      setState(() {
        _issuedBooks = response['data']['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> pickDate(TextEditingController controller, String filterKey) async {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: colorScheme.copyWith(
              surface: colorScheme.surfaceContainerLow,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String formattedDate = DateFormat("yyyy-MM-dd").format(picked);
      setState(() {
        controller.text = DateFormat("dd-MM-yyyy").format(picked);
        _filters[filterKey] = formattedDate;
      });
    }
  }

  void _applyFilters() {
    _filters['book_title'] = _titleController.text;
    _fetchLendingBooks();
  }

  void _resetFilters() {
    _titleController.clear();
    _fromDateController.clear();
    _toDateController.clear();
    _searchController.clear();
    setState(() {
      _filters['book_title'] = '';
      _filters['due_from'] = '';
      _filters['due_to'] = '';
    });
    _fetchLendingBooks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Lending Books"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLendingBooks,
        color: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerLow,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ================= FILTER CARD =================
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(16)),
                      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(context.scale(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.filter_list, color: colorScheme.primary, size: context.scale(24)),
                              SizedBox(width: context.scale(12)),
                              Text("Filter Lending History", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(18))),
                            ],
                          ),
                          SizedBox(height: context.scale(24)),
                          LayoutBuilder(builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 600;
                            final isExtraWide = constraints.maxWidth > 900;
                            return Wrap(
                              spacing: context.scale(20),
                              runSpacing: context.scale(16),
                              children: [
                                SizedBox(
                                  width: isExtraWide ? (constraints.maxWidth - context.scale(40)) / 3 : (isWide ? (constraints.maxWidth - context.scale(20)) / 2 : double.infinity),
                                  child: _buildFilterItem(context, "Book Title", buildTextField(context, _titleController, "Search by title...")),
                                ),
                                SizedBox(
                                  width: isExtraWide ? (constraints.maxWidth - context.scale(40)) / 3 : (isWide ? (constraints.maxWidth - context.scale(20)) / 2 : double.infinity),
                                  child: _buildFilterItem(context, "Due Date From", buildDateField(context, _fromDateController, "due_from")),
                                ),
                                SizedBox(
                                  width: isExtraWide ? (constraints.maxWidth - context.scale(40)) / 3 : (isWide ? (constraints.maxWidth - context.scale(20)) / 2 : double.infinity),
                                  child: _buildFilterItem(context, "Due Date To", buildDateField(context, _toDateController, "due_to")),
                                ),
                              ],
                            );
                          }),
                          SizedBox(height: context.scale(24)),
                          Row(
                            children: [
                              const Spacer(flex: 2),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _resetFilters,
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                    padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                                  ),
                                  child: Text("RESET", style: TextStyle(fontSize: context.font(14))),
                                ),
                              ),
                              SizedBox(width: context.scale(16)),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _applyFilters,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                    padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                                    elevation: 0,
                                  ),
                                  child: Text("APPLY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14))),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: context.scale(32)),

                  /// ================= RESULTS TABLE =================
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(16)),
                      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(context.scale(24.0)),
                          child: Text("Lending Records", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(18))),
                        ),
                        if (_isLoading)
                          Center(child: Padding(padding: EdgeInsets.all(context.scale(40.0)), child: CircularProgressIndicator(color: colorScheme.primary)))
                        else if (_errorMessage != null)
                          Center(child: Padding(padding: EdgeInsets.all(context.scale(40.0)), child: Text(_errorMessage!, style: TextStyle(color: colorScheme.error, fontSize: context.font(14)))))
                        else if (_issuedBooks.isEmpty)
                          _buildEmptyState()
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Theme(
                              data: theme.copyWith(dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                                columnSpacing: context.responsive(24.0, tablet: 48.0, desktop: 64.0),
                                columns: [
                                  DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                  DataColumn(label: Text("BOOK TITLE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                  DataColumn(label: Text("ISSUED AT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                  DataColumn(label: Text("DUE DATE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                  DataColumn(label: Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                  DataColumn(label: Text("RETURNED", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                ],
                                rows: _issuedBooks.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  var record = entry.value;
                                  
                                  // Calculate overdue
                                  DateTime now = DateTime.now();
                                  DateTime? dueDate = record['due_date'] != null ? DateTime.tryParse(record['due_date']) : null;
                                  String statusText = "N/A";
                                  Color statusColor = Colors.grey;

                                  if (dueDate != null) {
                                    int diff = dueDate.difference(now).inDays;
                                    statusText = diff < 0 ? "${diff.abs()} days overdue" : "$diff days left";
                                    statusColor = diff < 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981); // Red : Emerald
                                  }

                                  return DataRow(cells: [
                                    DataCell(Text((index + 1).toString(), style: theme.textTheme.bodySmall?.copyWith(fontSize: context.font(12)))),
                                    DataCell(Text(record['book']?['title'] ?? 'N/A', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: context.font(12)))),
                                    DataCell(Text(record['issued_at'] ?? 'N/A', style: theme.textTheme.bodySmall?.copyWith(fontSize: context.font(12)))),
                                    DataCell(Text(record['due_date'] ?? 'N/A', style: theme.textTheme.bodySmall?.copyWith(fontSize: context.font(12)))),
                                    DataCell(Container(
                                      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(context.scale(6)),
                                        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                                      ),
                                      child: Text(statusText, style: TextStyle(color: statusColor, fontSize: context.font(10), fontWeight: FontWeight.w800)),
                                    )),
                                    DataCell(Text(
                                      record['returned_at'] ?? 'Pending', 
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: record['returned_at'] != null ? colorScheme.onSurfaceVariant : const Color(0xFFF59E0B), // Amber
                                        fontWeight: record['returned_at'] == null ? FontWeight.bold : FontWeight.normal,
                                        fontSize: context.font(12),
                                      )
                                    )),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        SizedBox(height: context.scale(24)),
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

  Widget _buildEmptyState() {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.scale(80)),
        child: Column(
          children: [
            Icon(Icons.library_books_outlined, size: context.scale(64), color: colorScheme.outlineVariant),
            SizedBox(height: context.scale(16)),
            Text("No lending history found", style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: context.font(18))),
            SizedBox(height: context.scale(8)),
            Text("Books you borrow will appear here", style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: context.font(12))),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterItem(BuildContext context, String label, Widget child) {
    final colorScheme = context.theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: context.font(12))),
        SizedBox(height: context.scale(8)),
        child,
      ],
    );
  }

  /// ================= COMMON WIDGETS =================

  Widget buildTextField(BuildContext context, TextEditingController controller, String hint) {
    final colorScheme = context.theme.colorScheme;
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: context.font(14)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: context.font(14), color: colorScheme.onSurfaceVariant),
        isDense: true,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(context.scale(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(context.scale(12)),
        ),
      ),
    );
  }

  Widget buildDateField(BuildContext context, TextEditingController controller, String filterKey) {
    final colorScheme = context.theme.colorScheme;
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => pickDate(controller, filterKey),
      style: TextStyle(fontSize: context.font(14)),
      decoration: InputDecoration(
        hintText: "DD-MM-YYYY",
        hintStyle: TextStyle(fontSize: context.font(14), color: colorScheme.onSurfaceVariant),
        suffixIcon: Icon(Icons.calendar_today, size: context.scale(18), color: colorScheme.primary),
        isDense: true,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(context.scale(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(context.scale(12)),
        ),
      ),
    );
  }
}
