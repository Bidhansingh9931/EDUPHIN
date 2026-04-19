import '../../services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../teacher/dashboard/app_drawer.dart';
import '../librarian_models.dart';
import 'edit_issue.dart';
import 'issue_books.dart';
import 'package:intl/intl.dart';

class IssuedBooksListPage extends StatefulWidget {
  const IssuedBooksListPage({super.key});

  @override
  State<IssuedBooksListPage> createState() => _IssuedBooksListPageState();
}

class _IssuedBooksListPageState extends State<IssuedBooksListPage> {
  bool _isLoading = true;
  List<IssuedBook> _issuedBooks = [];
  String selectedReturned = "All";

  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _issuedFromController = TextEditingController();
  final TextEditingController _dueFromController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchIssuedBooks();
  }

  Future<void> _fetchIssuedBooks() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final Map<String, String> filters = {};
      if (_bookTitleController.text.isNotEmpty) filters['book_title'] = _bookTitleController.text;
      if (_userNameController.text.isNotEmpty) filters['user_name'] = _userNameController.text;
      if (_issuedFromController.text.isNotEmpty) filters['issued_from'] = _issuedFromController.text;
      if (_dueFromController.text.isNotEmpty) filters['due_from'] = _dueFromController.text;
      if (selectedReturned != "All") {
        filters['returned_status'] = selectedReturned == "Yes" ? "returned" : "not_returned";
      }
      if (_searchController.text.isNotEmpty) filters['search'] = _searchController.text;

      final books = await ApiService.getLibrarianIssuedBooks(filters);
      if (mounted) {
        setState(() {
          _issuedBooks = books;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Issued Books"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: context.scale(8)),
            child: IconButton.filledTonal(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IssueBookPage()),
                ).then((value) {
                  if (value == true) _fetchIssuedBooks();
                });
              },
              icon: const Icon(Icons.add_rounded),
              tooltip: "Issue New Book",
            ),
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchIssuedBooks,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// FILTER SECTION
                        Card(
                          elevation: 0,
                          color: theme.colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.scale(20)),
                            side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(context.spacing),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.filter_list_rounded, color: theme.colorScheme.primary, size: context.scale(20)),
                                    SizedBox(width: context.xs),
                                    Text(
                                      "Filter Records",
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: context.md),
                                _buildResponsiveRow(context, [
                                  _buildInputField(context, "Book Title", "Search Book", _bookTitleController),
                                  _buildInputField(context, "User Name", "Search User", _userNameController),
                                ]),
                                _buildResponsiveRow(context, [
                                  _buildDateField(context, "Issued From", _issuedFromController),
                                  _buildDateField(context, "Due From", _dueFromController),
                                  _buildDropdownField(context, "Returned Status", selectedReturned, ["All", "Yes", "No"], (val) {
                                    setState(() => selectedReturned = val!);
                                  }),
                                ]),
                                SizedBox(height: context.sm),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: _fetchIssuedBooks,
                                        icon: const Icon(Icons.search_rounded),
                                        label: const Text("APPLY FILTERS"),
                                        style: FilledButton.styleFrom(
                                          minimumSize: Size(0, context.scale(48)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: context.md),
                                    Expanded(
                                      child: FilledButton.tonalIcon(
                                        onPressed: () {
                                          setState(() {
                                            _bookTitleController.clear();
                                            _userNameController.clear();
                                            _issuedFromController.clear();
                                            _dueFromController.clear();
                                            selectedReturned = "All";
                                          });
                                          _fetchIssuedBooks();
                                        },
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: const Text("RESET"),
                                        style: FilledButton.styleFrom(
                                          minimumSize: Size(0, context.scale(48)),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: context.lg),

                        /// RESULTS TABLE
                        Card(
                          elevation: 0,
                          clipBehavior: Clip.antiAlias,
                          color: theme.colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.scale(20)),
                            side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(context.spacing),
                                child: SearchBar(
                                  controller: _searchController,
                                  hintText: "Quick search by title or lender...",
                                  onChanged: (val) => _fetchIssuedBooks(),
                                  leading: const Icon(Icons.search_rounded),
                                  elevation: WidgetStateProperty.all(0),
                                  backgroundColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                                  padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: context.md)),
                                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(context.scale(12)),
                                    side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                  )),
                                ),
                              ),
                              if (_issuedBooks.isEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: context.xl),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.library_books_rounded, size: context.scale(48), color: theme.colorScheme.outlineVariant),
                                        SizedBox(height: context.sm),
                                        Text("No issued books found", style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline, fontSize: context.font(16))),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: context.md,
                                    headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                                    dataRowMinHeight: context.scale(60),
                                    dataRowMaxHeight: context.scale(70),
                                    columns: [
                                      DataColumn(label: Text("#", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                      DataColumn(label: Text("TITLE", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                      DataColumn(label: Text("LENDER", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                      DataColumn(label: Text("DUE DATE", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                      DataColumn(label: Text("STATUS", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                      DataColumn(label: Text("ACTIONS", style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                    ],
                                    rows: _issuedBooks.asMap().entries.map((entry) {
                                      int index = entry.key + 1;
                                      IssuedBook ib = entry.value;
                                      bool isReturned = ib.returnedAt != null;
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(index.toString(), style: TextStyle(fontSize: context.font(14)))),
                                          DataCell(
                                            SizedBox(
                                              width: context.scale(200),
                                              child: Text(
                                                ib.bookTitle ?? "N/A",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(ib.lenderName ?? "N/A", style: TextStyle(fontSize: context.font(14)))),
                                          DataCell(Text(ib.dueDate ?? "N/A", style: TextStyle(fontSize: context.font(14)))),
                                          DataCell(_buildStatusBadge(context, isReturned)),
                                          DataCell(Row(
                                            children: [
                                              if (!isReturned)
                                                IconButton.filledTonal(
                                                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                                                  color: Colors.green,
                                                  onPressed: () => _confirmReturn(ib),
                                                  tooltip: "Mark as Returned",
                                                ),
                                              SizedBox(width: context.xs),
                                              IconButton.filledTonal(
                                                icon: const Icon(Icons.edit_rounded, size: 20),
                                                color: theme.colorScheme.primary,
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (_) => EditIssuePage(issuedBook: ib)),
                                                  ).then((value) {
                                                    if (value == true) _fetchIssuedBooks();
                                                  });
                                                },
                                              ),
                                              SizedBox(width: context.xs),
                                              IconButton.filledTonal(
                                                icon: const Icon(Icons.delete_rounded, size: 20),
                                                color: theme.colorScheme.error,
                                                onPressed: () => _deleteIssuedBook(ib.id),
                                              ),
                                            ],
                                          )),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: context.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isReturned) {
    final theme = context.theme;
    final color = isReturned ? Colors.green : Colors.orange;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.sm),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        isReturned ? "RETURNED" : "ISSUED",
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          fontSize: context.font(10),
        ),
      ),
    );
  }

  Future<void> _confirmReturn(IssuedBook ib) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Return Book"),
        content: Text("Are you sure you want to mark '${ib.bookTitle}' as returned?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("CONFIRM RETURN")),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.returnIssuedBook(ib.id.toString());
        _fetchIssuedBooks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Book returned successfully")));
        }
      } catch (e) {
        if (mounted) {
          final theme = context.theme;
          String errorMsg = e.toString().replaceFirst('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMsg),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: "Retry",
              textColor: theme.colorScheme.onError,
              onPressed: () => _confirmReturn(ib),
            ),
          ));
        }
      }
    }
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet && !context.isDesktop) return Column(children: children);
    return Padding(
      padding: EdgeInsets.only(bottom: context.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .asMap()
            .entries
            .map((entry) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: entry.key != children.length - 1 ? context.md : 0,
                    ),
                    child: entry.value,
                  ),
                ))
            .toList(),
      ),
    );
  }

  Future<void> _deleteIssuedBook(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to delete this issue record? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: context.theme.colorScheme.error),
            child: const Text("DELETE"),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ApiService.deleteIssuedBook(id.toString());
        _fetchIssuedBooks();
      } catch (e) {
        if (mounted) {
          final theme = context.theme;
          String errorMsg = e.toString().replaceFirst('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMsg),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(seconds: 5),
          ));
        }
      }
    }
  }

  Widget _buildInputField(BuildContext context, String label, String hint, TextEditingController controller) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
              fontSize: context.font(12),
            ),
          ),
          SizedBox(height: context.xs),
          TextField(
            controller: controller,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)),
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              hintText: hint,
              contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.md),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
              fontSize: context.font(12),
            ),
          ),
          SizedBox(height: context.xs),
          InkWell(
            onTap: () => _selectDate(context, controller),
            borderRadius: BorderRadius.circular(context.scale(12)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.scale(12)),
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.text.isEmpty ? "yyyy-mm-dd" : controller.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: controller.text.isEmpty ? theme.colorScheme.outline : null,
                        fontSize: context.font(14),
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today_rounded, size: context.scale(18), color: theme.colorScheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context, String label, String value, List<String> items, Function(String?) onChanged) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.bold,
              fontSize: context.font(12),
            ),
          ),
          SizedBox(height: context.xs),
          DropdownButtonFormField<String>(
            value: items.contains(value) ? value : items.first,
            isExpanded: true,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: context.font(14)),
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: EdgeInsets.symmetric(horizontal: context.md),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.scale(12)),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
            ),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
