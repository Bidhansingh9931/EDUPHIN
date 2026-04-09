import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eduphin/services/api_service.dart';

class MyLendingBooksPage extends StatefulWidget {
  const MyLendingBooksPage({super.key});

  @override
  State<MyLendingBooksPage> createState() => _MyLendingBooksPageState();
}

class _MyLendingBooksPageState extends State<MyLendingBooksPage> {
  List<dynamic> _issuedBooks = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Theme Colors
  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);

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
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _primary,
              onPrimary: Colors.white,
              surface: _card,
              onSurface: Colors.white,
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
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Lending Books",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLendingBooks,
        color: _primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= FILTER CARD =================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.filter_list, color: Colors.white70, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Filter Lending History",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    buildLabel("Book Title"),
                    buildTextField(_titleController, "Search by title..."),

                    buildLabel("Due Date From"),
                    buildDateField(_fromDateController, "due_from"),

                    buildLabel("Due Date To"),
                    buildDateField(_toDateController, "due_to"),

                    const SizedBox(height: 24),

                    /// Apply & Reset
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              onPressed: _applyFilters,
                              child: const Text("APPLY FILTERS", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _secondary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              onPressed: _resetFilters,
                              child: const Text("RESET", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ================= RESULTS TABLE =================
              Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "Lending Records",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_isLoading)
                      Center(child: Padding(padding: const EdgeInsets.all(40.0), child: CircularProgressIndicator(color: _primary)))
                    else if (_errorMessage != null)
                      Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent))))
                    else if (_issuedBooks.isEmpty)
                      const Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Text("No lending history found", style: TextStyle(color: Colors.white70))))
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(const Color(0xFF2A3450)),
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text("#", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("BOOK TITLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("ISSUED AT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("DUE DATE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("STATUS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("RETURNED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
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
                              statusColor = diff < 0 ? Colors.redAccent : Colors.greenAccent;
                            }

                            return DataRow(cells: [
                              DataCell(Text((index + 1).toString(), style: const TextStyle(color: Colors.white70))),
                              DataCell(Text(record['book']?['title'] ?? 'N/A', style: const TextStyle(color: Colors.white))),
                              DataCell(Text(record['issued_at'] ?? 'N/A', style: const TextStyle(color: Colors.white70))),
                              DataCell(Text(record['due_date'] ?? 'N/A', style: const TextStyle(color: Colors.white70))),
                              DataCell(Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                                ),
                                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                              )),
                              DataCell(Text(
                                record['returned_at'] ?? 'Pending', 
                                style: TextStyle(
                                  color: record['returned_at'] != null ? Colors.white70 : Colors.orangeAccent,
                                  fontWeight: record['returned_at'] == null ? FontWeight.bold : FontWeight.normal,
                                )
                              )),
                            ]);
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
    );
  }

  /// ================= COMMON WIDGETS =================

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.white70),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        filled: true,
        fillColor: _secondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }

  Widget buildDateField(TextEditingController controller, String filterKey) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => pickDate(controller, filterKey),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "DD-MM-YYYY",
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        filled: true,
        fillColor: _secondary,
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }
}
