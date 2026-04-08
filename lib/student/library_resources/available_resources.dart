import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';

class LibraryBooksPage extends StatefulWidget {
  const LibraryBooksPage({super.key});

  @override
  State<LibraryBooksPage> createState() => _LibraryBooksPageState();
}

class _LibraryBooksPageState extends State<LibraryBooksPage> {
  List<dynamic> _books = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filters
  Map<String, String> _filters = {
    'title': '',
    'author': '',
    'isbn': '',
    'category': 'All',
    'language': 'All',
    'format': 'All',
    'publication_year': 'All',
  };

  // Dropdown data
  List<String> _categories = ['All'];
  List<String> _languages = ['All'];
  List<String> _formats = ['All'];
  List<String> _years = ['All'];

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getStudentLibraryBooks(_filters, 1);
      setState(() {
        _books = response['data']['books']['data'] ?? [];
        
        // Update filter options if they are empty (only once)
        if (_categories.length == 1) {
          _categories.addAll(List<String>.from(response['data']['filters']['categories'] ?? []));
          _languages.addAll(List<String>.from(response['data']['filters']['languages'] ?? []));
          _formats.addAll(List<String>.from(response['data']['filters']['formats'] ?? []));
          _years.addAll(List<String>.from(response['data']['filters']['years']?.map((e) => e.toString()) ?? []));
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _applyFilters() {
    _filters['title'] = _titleController.text;
    _filters['author'] = _authorController.text;
    _filters['isbn'] = _isbnController.text;
    _fetchBooks();
  }

  void _resetFilters() {
    _titleController.clear();
    _authorController.clear();
    _isbnController.clear();
    setState(() {
      _filters = {
        'title': '',
        'author': '',
        'isbn': '',
        'category': 'All',
        'language': 'All',
        'format': 'All',
        'publication_year': 'All',
      };
    });
    _fetchBooks();
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
                "Library Books",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// FILTER CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3E466A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLabel("Title"),
                  buildTextField(_titleController, "Search Title"),

                  buildLabel("Author"),
                  buildTextField(_authorController, "Search Author"),

                  buildLabel("ISBN"),
                  buildTextField(_isbnController, "Search ISBN"),

                  buildLabel("Category"),
                  buildDropdown(_categories, 'category'),

                  buildLabel("Language"),
                  buildDropdown(_languages, 'language'),

                  buildLabel("Format"),
                  buildDropdown(_formats, 'format'),

                  buildLabel("Year"),
                  buildDropdown(_years, 'publication_year'),

                  const SizedBox(height: 20),

                  /// Apply & Reset
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
                          child: const Text(
                            "APPLY",
                            style: TextStyle(fontSize: 16),
                          ),
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
                          child: const Text(
                            "RESET",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ================= SHOW ENTRIES CARD =================
            Container(
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

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: Colors.white))
                  else if (_errorMessage != null)
                    Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)))
                  else if (_books.isEmpty)
                    const Center(child: Text("No books found", style: TextStyle(color: Colors.white70)))
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            WidgetStateProperty.all(const Color(0xFF4B557D)),
                        columns: const [
                          DataColumn(label: Text("#", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("Title", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("Author", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("ISBN", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("Category", style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text("Copies", style: TextStyle(color: Colors.white))),
                        ],
                        rows: _books.asMap().entries.map((entry) {
                          int index = entry.key;
                          var book = entry.value;
                          return DataRow(cells: [
                            DataCell(Text((index + 1).toString(), style: const TextStyle(color: Colors.white70))),
                            DataCell(Text(book['title'] ?? 'N/A', style: const TextStyle(color: Colors.white))),
                            DataCell(Text(book['author'] ?? 'N/A', style: const TextStyle(color: Colors.white))),
                            DataCell(Text(book['isbn'] ?? 'N/A', style: const TextStyle(color: Colors.white))),
                            DataCell(Text(book['category'] ?? 'N/A', style: const TextStyle(color: Colors.white))),
                            DataCell(Text(book['available_copies']?.toString() ?? '0', style: const TextStyle(color: Colors.white))),
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
    );
  }

  /// ========== Common Widgets ==========

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

  Widget buildDropdown(List<String> items, String filterKey) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF5E6A75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: const Color(0xFF3E466A),
          value: _filters[filterKey],
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _filters[filterKey] = newValue!;
            });
          },
        ),
      ),
    );
  }
}
