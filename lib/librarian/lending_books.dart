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
      final books = await ApiService.getLibrarianMyIssuedBooks();
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Lending Books"),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchMyIssuedBooks,
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
                                Text("Filter My Lending Books", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                _buildResponsiveRow(context, [
                                  _buildInputField(context, "Book Title", "e.g Math, Physics", _bookTitleController),
                                  _buildDateField(context, "Due Date From", _dateFromController),
                                ]),
                                _buildDateField(context, "Due Date To", _dateToController),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _fetchMyIssuedBooks,
                                        child: const Text("APPLY FILTERS"),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
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

                        /// RECORDS SECTION
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Text("Lending Records", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    _exportIcon(Icons.description, Colors.teal),
                                    _exportIcon(Icons.table_chart, Colors.green),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (v) => setState(() {}),
                                  decoration: const InputDecoration(
                                    hintText: "Quick search...",
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                              ),

                              if (_myIssuedBooks.isEmpty)
                                const Center(child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text("No lending records found"),
                                ))
                              else
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withOpacity(0.05)),
                                    columnSpacing: 25,
                                    columns: const [
                                      DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("ISSUE ID", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("BOOK TITLE", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("ISSUED AT", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("DUE DATE", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                    rows: _myIssuedBooks.where((ib) => 
                                      (ib.bookTitle ?? "").toLowerCase().contains(_searchController.text.toLowerCase())
                                    ).toList().asMap().entries.map((entry) {
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
    bool isOverdue = ib.returnedAt == null && ib.dueDate != null && DateTime.parse(ib.dueDate!).isBefore(DateTime.now());
    final statusColor = ib.returnedAt != null ? Colors.green : (isOverdue ? Colors.red : Colors.orange);
    
    return DataRow(cells: [
      DataCell(Text(hash)),
      DataCell(Text(ib.id.toString())),
      DataCell(Text(ib.bookTitle ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(ib.issuedAt ?? "N/A")),
      DataCell(Text(ib.dueDate ?? "N/A")),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: statusColor.withOpacity(0.5)),
        ),
        child: Text(
          ib.returnedAt != null ? "RETURNED" : (isOverdue ? "OVERDUE" : "PENDING"), 
          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)
        ),
      )),
    ]);
  }
}
