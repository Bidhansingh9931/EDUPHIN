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
  bool _isLoading = true;
  List<IssuedBook> _overdueBooks = [];

  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOverdueBooks();
  }

  Future<void> _fetchOverdueBooks() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final Map<String, String> filters = {'overdue': '1'}; 
      if (_bookTitleController.text.isNotEmpty) filters['book_title'] = _bookTitleController.text;
      if (_userNameController.text.isNotEmpty) filters['user_name'] = _userNameController.text;
      if (_dateFromController.text.isNotEmpty) filters['due_from'] = _dateFromController.text;
      if (_dateToController.text.isNotEmpty) filters['due_to'] = _dateToController.text;
      if (_searchController.text.isNotEmpty) filters['search'] = _searchController.text;

      final books = await ApiService.getLibrarianIssuedBooks(filters);
      if (mounted) {
        setState(() {
          _overdueBooks = books;
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
        title: const Text("Overdue Books"),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchOverdueBooks,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: context.pagePadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      children: [
                        /// FILTER SECTION
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Filter Overdue Books", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                _buildResponsiveRow(context, [
                                  _buildInputField(context, "Book Title", "e.g Math, Physics", _bookTitleController),
                                  _buildInputField(context, "User Name", "e.g John, Ayesha", _userNameController),
                                ]),
                                _buildResponsiveRow(context, [
                                  _buildDateField(context, "Due Date From", _dateFromController),
                                  _buildDateField(context, "Due Date To", _dateToController),
                                ]),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _fetchOverdueBooks,
                                        child: const Text("APPLY FILTERS"),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _bookTitleController.clear();
                                            _userNameController.clear();
                                            _dateFromController.clear();
                                            _dateToController.clear();
                                          });
                                          _fetchOverdueBooks();
                                        },
                                        child: const Text("RESET"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// OVERDUE RECORDS SECTION
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Text("Overdue Records", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    _exportIcon(Icons.picture_as_pdf, Colors.red),
                                    _exportIcon(Icons.table_chart, Colors.green),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (v) => _fetchOverdueBooks(),
                                  decoration: const InputDecoration(
                                    hintText: "Search books...",
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                              ),

                              if (_overdueBooks.isEmpty)
                                const Center(child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text("No overdue records found"),
                                ))
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withOpacity(0.05)),
                                    columnSpacing: 30,
                                    columns: const [
                                      DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("ISSUE ID", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("BOOK TITLE", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("LENDER", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("DUE DATE", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("ACTION", style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                    rows: _overdueBooks.asMap().entries.map((entry) {
                                      int index = entry.key + 1;
                                      IssuedBook ib = entry.value;
                                      return _buildDataRow(context, index.toString(), ib);
                                    }).toList(),
                                  ),
                                ),
                              const SizedBox(height: 16),
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

  Widget _buildInputField(BuildContext context, String label, String hint, TextEditingController controller) {
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
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
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
                decoration: const InputDecoration(
                  hintText: "yyyy-mm-dd",
                  suffixIcon: Icon(Icons.calendar_month, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exportIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }

  DataRow _buildDataRow(BuildContext context, String hash, IssuedBook ib) {
    final theme = Theme.of(context);
    return DataRow(cells: [
      DataCell(Text(hash)),
      DataCell(Text(ib.id.toString())),
      DataCell(Text(ib.bookTitle ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(ib.lenderName ?? "N/A")),
      DataCell(Text(ib.dueDate ?? "N/A", style: TextStyle(color: theme.colorScheme.error))),
      DataCell(IconButton(
        icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
        onPressed: () async {
          try {
            await ApiService.returnIssuedBook(ib.id.toString());
            _fetchOverdueBooks();
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Book returned successfully")));
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
        },
      )),
    ]);
  }
}
