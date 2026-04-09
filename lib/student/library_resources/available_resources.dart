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

  // Theme Colors
  final Color _bg = const Color(0xff0B1220);
  final Color _card = const Color(0xff1E2746);
  final Color _primary = const Color(0xff3366FF);
  final Color _secondary = const Color(0xff3E4764);

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
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Available Resources",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// FILTER CARD
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
                        "Search Resources",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

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

            /// RESULTS TABLE
            Container(
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Available Books",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_isLoading)
                    Center(child: Padding(padding: const EdgeInsets.all(40.0), child: CircularProgressIndicator(color: _primary)))
                  else if (_errorMessage != null)
                    Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent))))
                  else if (_books.isEmpty)
                    const Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Text("No books found", style: TextStyle(color: Colors.white70))))
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFF2A3450)),
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text("#", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("TITLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("AUTHOR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("ISBN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("COPIES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ],
                        rows: _books.asMap().entries.map((entry) {
                          int index = entry.key;
                          var book = entry.value;
                          return DataRow(cells: [
                            DataCell(Text((index + 1).toString(), style: const TextStyle(color: Colors.white70))),
                            DataCell(Text(book['title'] ?? 'N/A', style: const TextStyle(color: Colors.white))),
                            DataCell(Text(book['author'] ?? 'N/A', style: const TextStyle(color: Colors.white70))),
                            DataCell(Text(book['isbn'] ?? 'N/A', style: const TextStyle(color: Colors.white70))),
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

  Widget buildDropdown(List<String> items, String filterKey) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: _card,
          value: _filters[filterKey],
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
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
