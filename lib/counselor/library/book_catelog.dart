import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../counselor_models.dart';

class BookCatelogPage extends StatefulWidget {
  const BookCatelogPage({super.key});

  @override
  State<BookCatelogPage> createState() => _BookCatelogPageState();
}

class _BookCatelogPageState extends State<BookCatelogPage> {
  bool _isLoading = true;
  List<Book> _books = [];
  List<String> _categories = ["All"];
  List<String> _languages = ["All"];
  List<String> _formats = ["All"];
  List<String> _years = ["All"];

  String _selectedCategory = "All";
  String _selectedLanguage = "All";
  String _selectedFormat = "All";
  String _selectedYear = "All";

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final Map<String, String> queryParams = {};
      if (_titleController.text.isNotEmpty) queryParams['title'] = _titleController.text;
      if (_authorController.text.isNotEmpty) queryParams['author'] = _authorController.text;
      if (_isbnController.text.isNotEmpty) queryParams['isbn'] = _isbnController.text;
      if (_selectedCategory != "All") queryParams['category'] = _selectedCategory;
      if (_selectedLanguage != "All") queryParams['language'] = _selectedLanguage;
      if (_selectedFormat != "All") queryParams['format'] = _selectedFormat;
      if (_selectedYear != "All") queryParams['publication_year'] = _selectedYear;
      if (_searchController.text.isNotEmpty) queryParams['title'] = _searchController.text;

      final response = await ApiService.get('counselor/library/books', queryParams);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            final booksWrapper = data['books'];
            if (booksWrapper != null && booksWrapper['data'] != null) {
              final booksData = booksWrapper['data'] as List;
              _books = booksData.map((json) => Book.fromJson(json)).toList();
            } else {
              _books = [];
            }

            if (data['categories'] != null) {
              _categories = ["All", ...(data['categories'] as List).cast<String>()];
            }
            if (data['languages'] != null) {
              _languages = ["All", ...(data['languages'] as List).cast<String>()];
            }
            if (data['formats'] != null) {
              _formats = ["All", ...(data['formats'] as List).cast<String>()];
            }
            if (data['years'] != null) {
              _years = ["All", ...(data['years'] as List).map((e) => e.toString())];
            }
            
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetFilters() {
    _titleController.clear();
    _authorController.clear();
    _isbnController.clear();
    _searchController.clear();
    setState(() {
      _selectedCategory = "All";
      _selectedLanguage = "All";
      _selectedFormat = "All";
      _selectedYear = "All";
    });
    _fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Catalog"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBooks,
        child: SingleChildScrollView(
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Search Filters", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          _buildResponsiveRow(context, [
                            _buildTextField(context, "Title", "Search Title", _titleController),
                            _buildTextField(context, "Author", "Search Author", _authorController),
                          ]),
                          _buildResponsiveRow(context, [
                            _buildTextField(context, "ISBN", "Search ISBN", _isbnController),
                            _buildDropdown(context, "Category", _categories, _selectedCategory, (val) => setState(() => _selectedCategory = val!)),
                          ]),
                          _buildResponsiveRow(context, [
                            _buildDropdown(context, "Language", _languages, _selectedLanguage, (val) => setState(() => _selectedLanguage = val!)),
                            _buildDropdown(context, "Year", _years, _selectedYear, (val) => setState(() => _selectedYear = val!)),
                          ]),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _fetchBooks,
                                  child: const Text("APPLY FILTERS"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _resetFilters,
                                  child: const Text("RESET"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text("Books Collection", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => _fetchBooks(),
                            decoration: const InputDecoration(
                              hintText: "Quick search by title...",
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        if (_isLoading)
                          const Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator())
                        else if (_books.isEmpty)
                          const Padding(padding: EdgeInsets.all(40.0), child: Center(child: Text("No books found")))
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 24,
                              headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withValues(alpha: 0.05)),
                              columns: const [
                                DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Title", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Author", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Category", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Copies", style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _books.asMap().entries.map((entry) {
                                int idx = entry.key;
                                Book book = entry.value;
                                return DataRow(cells: [
                                  DataCell(Text("${idx + 1}")),
                                  DataCell(SizedBox(width: 150, child: Text(book.title, style: const TextStyle(fontWeight: FontWeight.w500)))),
                                  DataCell(Text(book.author ?? "-")),
                                  DataCell(Text(book.category ?? "-")),
                                  DataCell(Text("${book.availableCopies}")),
                                ]);
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
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

  Widget _buildTextField(BuildContext context, String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String label, List<String> items, String value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: items.contains(value) ? value : items.first,
            isExpanded: true,
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            items: items.map((String item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
