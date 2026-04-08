import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Issued Books"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IssueBookPage()),
              ).then((value) {
                if (value == true) _fetchIssuedBooks();
              });
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Issue New Book",
          )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchIssuedBooks,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Filter Issued Books", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                _buildResponsiveRow(context, [
                                  buildInputField(context, "Book Title", "Search Book", _bookTitleController),
                                  buildInputField(context, "User Name", "Search User", _userNameController),
                                ]),
                                _buildResponsiveRow(context, [
                                  buildDateField(context, "Issued From", _issuedFromController),
                                  buildDateField(context, "Due From", _dueFromController),
                                ]),
                                buildDropdownField(context, "Returned?", selectedReturned, ["All", "Yes", "No"], (val) {
                                  setState(() => selectedReturned = val!);
                                }),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _fetchIssuedBooks,
                                        child: const Text("APPLY"),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
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
                                        child: const Text("RESET"),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) => _fetchIssuedBooks(),
                                  decoration: const InputDecoration(
                                    hintText: "Quick search...",
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                              ),
                              if (_issuedBooks.isEmpty)
                                const Center(child: Padding(
                                  padding: EdgeInsets.all(40.0),
                                  child: Text("No records found"),
                                ))
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: 24,
                                    headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withOpacity(0.05)),
                                    columns: const [
                                      DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Title", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Lender", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Due Date", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                    rows: _issuedBooks.asMap().entries.map((entry) {
                                      int index = entry.key + 1;
                                      IssuedBook ib = entry.value;
                                      bool isReturned = ib.returnedAt != null;
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(index.toString())),
                                          DataCell(SizedBox(width: 150, child: Text(ib.bookTitle ?? "N/A", style: const TextStyle(fontWeight: FontWeight.w500)))),
                                          DataCell(Text(ib.lenderName ?? "N/A")),
                                          DataCell(Text(ib.dueDate ?? "N/A")),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: (isReturned ? Colors.green : Colors.orange).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: (isReturned ? Colors.green : Colors.orange).withOpacity(0.5)),
                                              ),
                                              child: Text(isReturned ? "Returned" : "Issued", 
                                                style: TextStyle(color: isReturned ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                          DataCell(Row(
                                            children: [
                                              if (!isReturned)
                                                IconButton(
                                                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                                  onPressed: () async {
                                                    try {
                                                      await ApiService.returnIssuedBook(ib.id.toString());
                                                      _fetchIssuedBooks();
                                                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Book returned successfully")));
                                                    } catch (e) {
                                                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                                                    }
                                                  },
                                                ),
                                              IconButton(
                                                icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (_) => EditIssuePage(issuedBook: ib))).then((value) {
                                                    if (value == true) _fetchIssuedBooks();
                                                  });
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) return Column(children: children);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList(),
    );
  }

  Future<void> _deleteIssuedBook(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to delete this issue record?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text("DELETE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ApiService.deleteIssuedBook(id.toString());
        _fetchIssuedBooks();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Widget buildInputField(BuildContext context, String label, String hint, TextEditingController controller) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
        ],
      ),
    );
  }

  Widget buildDateField(BuildContext context, String label, TextEditingController controller) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context, controller),
            child: IgnorePointer(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "yyyy-mm-dd",
                  suffixIcon: const Icon(Icons.calendar_month, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdownField(BuildContext context, String label, String value, List<String> items, Function(String?) onChanged) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
