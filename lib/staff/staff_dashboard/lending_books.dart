import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eduphin/services/responsive_helper.dart';
import '../../librarian/librarian_models.dart';
import '../../services/api_service.dart';
import '../../teacher/dashboard/common_widgets.dart';

class MyLendingBooksPage extends StatefulWidget {
  const MyLendingBooksPage({super.key});

  @override
  State<MyLendingBooksPage> createState() => _MyLendingBooksPageState();
}

class _MyLendingBooksPageState extends State<MyLendingBooksPage> {
  bool _isLoading = true;
  List<IssuedBook> _lendingBooks = [];

  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLendingBooks();
  }

  Future<void> _fetchLendingBooks() async {
    setState(() => _isLoading = true);
    try {
      final Map<String, String> filters = {};
      if (_bookTitleController.text.isNotEmpty) filters['book_title'] = _bookTitleController.text;
      
      // The API likely expects yyyy-MM-dd. We should ensure conversion if needed, 
      // but buildDateField in common_widgets uses dd-MM-yyyy.
      // For consistency with existing logic, let's handle the format.
      if (_dateFromController.text.isNotEmpty) {
        try {
          DateTime dt = DateFormat('dd-MM-yyyy').parse(_dateFromController.text);
          filters['issued_from'] = DateFormat('yyyy-MM-dd').format(dt);
        } catch (_) {
          filters['issued_from'] = _dateFromController.text;
        }
      }
      if (_dateToController.text.isNotEmpty) {
        try {
          DateTime dt = DateFormat('dd-MM-yyyy').parse(_dateToController.text);
          filters['due_to'] = DateFormat('yyyy-MM-dd').format(dt);
        } catch (_) {
          filters['due_to'] = _dateToController.text;
        }
      }
      if (_searchController.text.isNotEmpty) filters['search'] = _searchController.text;

      final books = await ApiService.getStaffIssuedBooks(filters);
      if (!mounted) return;
      setState(() {
        _lendingBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching books: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("My Lending Books"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchLendingBooks,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      children: [
                        _buildFilterCard(context),
                        SizedBox(height: context.spacing),
                        _buildRecordsCard(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.scale(20)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list_rounded, color: theme.colorScheme.primary, size: context.scale(20)),
              SizedBox(width: context.scale(8)),
              Text("Filter Books",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
            ],
          ),
          SizedBox(height: context.spacing),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildInputGroup("Book Title", _bookTitleController, "e.g. Math, Physics")),
                        SizedBox(width: context.spacing),
                        Expanded(child: _buildDateInputGroup("Due Date From", _dateFromController)),
                        SizedBox(width: context.spacing),
                        Expanded(child: _buildDateInputGroup("Due Date To", _dateToController)),
                      ],
                    ),
                    SizedBox(height: context.spacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildResetButton(),
                        SizedBox(width: context.spacing),
                        _buildApplyButton(),
                      ],
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputGroup("Book Title", _bookTitleController, "e.g. Math, Physics"),
                  SizedBox(height: context.spacing),
                  Row(
                    children: [
                      Expanded(child: _buildDateInputGroup("Due Date From", _dateFromController)),
                      SizedBox(width: context.spacing),
                      Expanded(child: _buildDateInputGroup("Due Date To", _dateToController)),
                    ],
                  ),
                  SizedBox(height: context.spacing),
                  Row(
                    children: [
                      Expanded(child: _buildResetButton()),
                      SizedBox(width: context.spacing),
                      Expanded(child: _buildApplyButton()),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputGroup(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(context, label),
        buildTextField(context, controller, hint),
      ],
    );
  }

  Widget _buildDateInputGroup(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(context, label),
        buildDateField(context, controller, "dd-mm-yyyy"),
      ],
    );
  }

  Widget _buildApplyButton() {
    return FilledButton.icon(
      onPressed: _fetchLendingBooks,
      icon: const Icon(Icons.search_rounded, size: 18),
      label: const Text("APPLY FILTERS"),
    );
  }

  Widget _buildResetButton() {
    return FilledButton.tonal(
      onPressed: () {
        setState(() {
          _bookTitleController.clear();
          _dateFromController.clear();
          _dateToController.clear();
        });
        _fetchLendingBooks();
      },
      child: const Text("RESET"),
    );
  }

  Widget _buildRecordsCard(BuildContext context) {
    final theme = context.theme;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.scale(20)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Current Lending Records",
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                      Text("Detailed view of issued books and status",
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                    ],
                  ),
                ),
                SizedBox(width: context.spacing),
                SizedBox(
                  width: context.responsive(context.scale(200), tablet: context.scale(250)),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => _fetchLendingBooks(),
                    style: TextStyle(fontSize: context.font(14)),
                    decoration: InputDecoration(
                      hintText: "Search records...",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(8)),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_lendingBooks.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: context.scale(64)),
                child: Column(
                  children: [
                    Icon(Icons.library_books_outlined, size: context.scale(48), color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    SizedBox(height: context.scale(16)),
                    Text("No lending records found", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else
            _buildLendingTable(context),
          SizedBox(height: context.spacing),
        ],
      ),
    );
  }

  Widget _buildLendingTable(BuildContext context) {
    final theme = context.theme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(theme.colorScheme.primaryContainer.withValues(alpha: 0.3)),
        columnSpacing: context.scale(24),
        dividerThickness: 0.5,
        horizontalMargin: context.spacing,
        columns: [
          DataColumn(label: _tableHeader(context, "#")),
          DataColumn(label: _tableHeader(context, "Issue No.")),
          DataColumn(label: _tableHeader(context, "Book ID")),
          DataColumn(label: _tableHeader(context, "Book Title")),
          DataColumn(label: _tableHeader(context, "Issued At")),
          DataColumn(label: _tableHeader(context, "Due Date")),
          DataColumn(label: _tableHeader(context, "Days Overdue")),
          DataColumn(label: _tableHeader(context, "Return At")),
        ],
        rows: _lendingBooks.asMap().entries.map((entry) {
          int index = entry.key + 1;
          IssuedBook ib = entry.value;
          return _buildDataRow(context, index.toString(), ib);
        }).toList(),
      ),
    );
  }

  Widget _tableHeader(BuildContext context, String label) {
    return Text(
      label,
      style: context.theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.theme.colorScheme.primary,
        fontSize: context.font(13),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, String hash, IssuedBook ib) {
    final theme = context.theme;
    String overdueText = "0 days";
    Color overdueBg = theme.colorScheme.surfaceContainerHighest;
    Color overdueTextColor = theme.colorScheme.onSurfaceVariant;
    
    if (ib.dueDate != null) {
      try {
        DateTime dueDate = DateTime.parse(ib.dueDate!);
        if (DateTime.now().isAfter(dueDate) && (ib.returnedAt == null || ib.returnedAt!.isEmpty)) {
          int diff = DateTime.now().difference(dueDate).inDays;
          overdueText = "$diff days";
          // Semantic Red: 0xFFEF4444
          overdueBg = const Color(0xFFEF4444).withValues(alpha: 0.1);
          overdueTextColor = const Color(0xFFEF4444);
        }
      } catch (_) {}
    }

    return DataRow(cells: [
      DataCell(Text(hash, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13)))),
      DataCell(Text(ib.id.toString(), style: TextStyle(fontSize: context.font(13)))),
      DataCell(Text(ib.bookId.toString(), style: TextStyle(fontSize: context.font(13)))),
      DataCell(SizedBox(
        width: context.scale(150),
        child: Text(ib.bookTitle ?? "N/A", 
          style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.w500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      )),
      DataCell(Text(_formatDate(ib.issuedAt), style: TextStyle(fontSize: context.font(13)))),
      DataCell(Text(_formatDate(ib.dueDate), style: TextStyle(fontSize: context.font(13)))),
      DataCell(Container(
        padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
        decoration: BoxDecoration(
          color: overdueBg,
          borderRadius: BorderRadius.circular(context.scale(4)),
        ),
        child: Text(overdueText, 
          style: TextStyle(
            fontSize: context.font(12), 
            color: overdueTextColor,
            fontWeight: FontWeight.bold,
          )),
      )),
      DataCell(Text(_formatDate(ib.returnedAt), style: TextStyle(fontSize: context.font(13)))),
    ]);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }
}
