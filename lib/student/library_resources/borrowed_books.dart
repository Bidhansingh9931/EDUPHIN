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
      backgroundColor: const Color(0xFF0B102A),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFF3E466A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Row(
            children: [
              Icon(Icons.menu_book_outlined, size: 28),
              SizedBox(width: 10),
              Text(
                "My Lending Books",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLendingBooks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// ================= FILTER CARD =================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF3E466A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildLabel("Book Title"),
                    buildTextField(_titleController, "e.g. Math, Physics"),

                    buildLabel("Due Date From"),
                    buildDateField(_fromDateController, "due_from"),

                    buildLabel("Due Date To"),
                    buildDateField(_toDateController, "due_to"),

                    const SizedBox(height: 20),

                    /// Apply Reset
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4361EE),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _applyFilters,
                            child: const Text("APPLY", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E6A75),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _resetFilters,
                            child: const Text("RESET", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// ================= SHOW ENTRIES =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF3E466A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Show Entries",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 15),

                    buildTextField(_searchController, "search"),

                    const SizedBox(height: 20),

                    if (_isLoading)
                      const Center(child: CircularProgressIndicator(color: Colors.white))
                    else if (_errorMessage != null)
                      Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)))
                    else if (_issuedBooks.isEmpty)
                      const Center(child: Text("No lending history found", style: TextStyle(color: Colors.white70)))
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor:
                              WidgetStateProperty.all(const Color(0xFF4B557D)),
                          columns: const [
                            DataColumn(label: Text("#", style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text("Book Title", style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text("Issued At", style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text("Due Date", style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text("Days Status", style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text("Return At", style: TextStyle(color: Colors.white))),
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
                              DataCell(Text(record['issued_at'] ?? 'N/A', style: const TextStyle(color: Colors.white))),
                              DataCell(Text(record['due_date'] ?? 'N/A', style: const TextStyle(color: Colors.white))),
                              DataCell(Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                              )),
                              DataCell(Text(record['returned_at'] ?? 'Not Returned', style: TextStyle(color: record['returned_at'] != null ? Colors.white : Colors.orangeAccent))),
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
      padding: const EdgeInsets.only(top: 15, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF5E6A75),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
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
        hintText: "dd-mm-yyyy",
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF5E6A75),
        suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }
}
