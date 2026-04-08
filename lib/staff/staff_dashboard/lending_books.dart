import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../librarian/librarian_models.dart';
import '../../services/api_service.dart';

class MyLendingBooksPage extends StatefulWidget {
  const MyLendingBooksPage({super.key});

  @override
  State<MyLendingBooksPage> createState() => _MyLendingBooksPageState();
}

class _MyLendingBooksPageState extends State<MyLendingBooksPage> {
  static const Color bgColor = Color(0xFF161C3A);
  static const Color cardColor = Color(0xFF262F56);
  static const Color fieldColor = Color(0xFF434E72);
  static const Color accentBlue = Color(0xFF3B66F5);
  static const Color greyBtn = Color(0xFF5A6A85);
  static const Color headerColor = Color(0xFF343E63);
  static const Color dividerColor = Color(0xFF3D476B);

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
      if (_dateFromController.text.isNotEmpty) filters['issued_from'] = _dateFromController.text;
      if (_dateToController.text.isNotEmpty) filters['due_to'] = _dateToController.text;
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
      if (_lendingBooks.isEmpty) {
        _lendingBooks = [
          IssuedBook(
            id: 2,
            bookId: 4,
            bookTitle: "Advanced Taxation Concepts",
            issuedAt: "2025-10-30",
            dueDate: "2025-11-15",
            returnedAt: "2025-11-09",
          ),
        ];
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching books: $e")));
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: accentBlue,
              onPrimary: Colors.white,
              surface: cardColor,
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: bgColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Row(
          children: [
            Icon(Icons.menu_book_outlined, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text("My Lending Books",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: accentBlue))
          : RefreshIndicator(
              onRefresh: _fetchLendingBooks,
              color: accentBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.filter_alt, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text("Filter Books",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          buildLabel("Book Title"),
                          buildInputField("e.g. Math, Physics", _bookTitleController, null),
                          buildLabel("Due Date From"),
                          buildInputField("dd-mm-yyyy", _dateFromController, Icons.calendar_month_outlined, isDate: true),
                          buildLabel("Due Date To"),
                          buildInputField("dd-mm-yyyy", _dateToController, Icons.calendar_month_outlined, isDate: true),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _fetchLendingBooks,
                              icon: const Icon(Icons.search, size: 18, color: Colors.white),
                              label: const Text("APPLY FILTERS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentBlue,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _bookTitleController.clear();
                                  _dateFromController.clear();
                                  _dateToController.clear();
                                });
                                _fetchLendingBooks();
                              },
                              icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                              label: const Text("RESET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: greyBtn,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Current Lending Records",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 12),
                          const Text("Show Entries", style: TextStyle(color: Colors.white, fontSize: 15)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _searchController,
                            onChanged: (v) => _fetchLendingBooks(),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: "search",
                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
                              filled: true,
                              fillColor: fieldColor,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                exportIconBtn(Icons.copy, Colors.blue),
                                const SizedBox(width: 10),
                                exportIconBtn(Icons.description, Colors.teal),
                                const SizedBox(width: 10),
                                exportIconBtn(Icons.table_chart, Colors.green),
                                const SizedBox(width: 10),
                                exportIconBtn(Icons.picture_as_pdf, Colors.red),
                                const SizedBox(width: 10),
                                exportIconBtn(Icons.print, Colors.grey),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_lendingBooks.isEmpty)
                            const Center(child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text("No lending records found", style: TextStyle(color: Colors.white38)),
                            ))
                          else
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: dividerColor, width: 1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(headerColor),
                                  columnSpacing: 35,
                                  dividerThickness: 1,
                                  horizontalMargin: 15,
                                  dataRowMaxHeight: 80,
                                  columns: const [
                                    DataColumn(label: Text("#", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15))),
                                    DataColumn(label: Text("Issue No.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15))),
                                    DataColumn(label: Text("Book ID", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15))),
                                    DataColumn(label: Text("Book Title", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15))),
                                    DataColumn(label: Text("Issued At", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15))),
                                    DataColumn(label: Text("Due Date", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15))),
                                    DataColumn(label: Text("Days Overdue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15))),
                                    DataColumn(label: Text("Return At", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15))),
                                  ],
                                  rows: _lendingBooks.asMap().entries.map((entry) {
                                    int index = entry.key + 1;
                                    IssuedBook ib = entry.value;
                                    return buildDataRow(index.toString(), ib);
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
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  Widget buildInputField(String hint, TextEditingController controller, IconData? icon, {bool isDate = false}) {
    return InkWell(
      onTap: isDate ? () => _selectDate(context, controller) : null,
      child: IgnorePointer(
        ignoring: isDate,
        child: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
            filled: true,
            fillColor: fieldColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: icon != null ? Icon(icon, color: Colors.white54, size: 22) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  Widget exportIconBtn(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  DataRow buildDataRow(String hash, IssuedBook ib) {
    String overdueText = "0 days";
    if (ib.dueDate != null) {
      try {
        DateTime dueDate = DateTime.parse(ib.dueDate!);
        if (DateTime.now().isAfter(dueDate)) {
          int diff = DateTime.now().difference(dueDate).inDays;
          overdueText = "$diff days";
        }
      } catch (_) {}
    }

    return DataRow(cells: [
      DataCell(Text(hash, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
      DataCell(Text(ib.id.toString(), style: const TextStyle(color: Colors.white70, fontSize: 14))),
      DataCell(Text(ib.bookId.toString(), style: const TextStyle(color: Colors.white70, fontSize: 14))),
      DataCell(SizedBox(
        width: 140,
        child: Text(ib.bookTitle ?? "N/A", 
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      )),
      DataCell(Text(_formatDate(ib.issuedAt), style: const TextStyle(color: Colors.white, fontSize: 14))),
      DataCell(Text(_formatDate(ib.dueDate), style: const TextStyle(color: Colors.white, fontSize: 14))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF3F4A5E),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(overdueText, 
          style: const TextStyle(color: Colors.white, fontSize: 14)),
      )),
      DataCell(Text(_formatDate(ib.returnedAt), style: const TextStyle(color: Colors.white, fontSize: 14))),
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
