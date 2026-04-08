import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart';

class LibraryBooksPage extends StatefulWidget {
  const LibraryBooksPage({super.key});

  @override
  State<LibraryBooksPage> createState() => _LibraryBooksPageState();
}

class _LibraryBooksPageState extends State<LibraryBooksPage> {
  bool _isLoading = false;
  List<Book> _books = [];
  BookFilters? _filterOptions;
  int _currentPage = 1;
  int _totalPages = 1;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedLanguage = 'All';
  String _selectedFormat = 'All';
  String _selectedYear = 'All';
  String _selectedAvailability = 'All';

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _fetchBooks({int page = 1}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final filters = {
        'title': _titleController.text,
        'author': _authorController.text,
        'isbn': _isbnController.text,
        'page': page.toString(),
        if (_selectedCategory != 'All') 'category': _selectedCategory,
        if (_selectedLanguage != 'All') 'language': _selectedLanguage,
        if (_selectedFormat != 'All') 'format': _selectedFormat,
        if (_selectedYear != 'All') 'publication_year': _selectedYear,
        if (_selectedAvailability == 'Available') 'availability': '1',
        if (_selectedAvailability == 'Out of Stock') 'availability': '0',
      };
      
      final response = await ApiService.get('accountants/library/books', filters);
      
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final json = body['data'] ?? body;
        final booksPagination = json['books'] is Map ? json['books'] : json;
        
        List _parseList(dynamic val) {
          if (val is List) return val;
          if (val is Map) return val.values.toList();
          return [];
        }

        final List booksData = _parseList(booksPagination['data']);
        final List<Book> booksList = booksData.map((b) => Book.fromJson(b)).toList();
        final rawFilters = json['filters'] ?? {};
        
        List<String> _parseFilterList(dynamic val) {
          if (val is List) return val.map((e) => e.toString()).toList();
          if (val is Map) return val.values.map((e) => e.toString()).toList();
          return [];
        }

        if (mounted) {
          setState(() {
            _books = booksList;
            _filterOptions = BookFilters(
              categories: _parseFilterList(rawFilters['categories']),
              languages: _parseFilterList(rawFilters['languages']),
              formats: _parseFilterList(rawFilters['formats']),
              years: _parseFilterList(rawFilters['years']),
            );
            _currentPage = booksPagination['current_page'] ?? 1;
            _totalPages = booksPagination['last_page'] ?? 1;
          });
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library Books"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    _buildFilterCard(context),
                    const SizedBox(height: 24),
                    _buildBookList(context),
                    const SizedBox(height: 24),
                    _buildPagination(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text("Search Books", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            _buildResponsiveRow(context, [
              TextField(controller: _titleController, decoration: const InputDecoration(hintText: "Book Title", prefixIcon: Icon(Icons.book, size: 18))),
              TextField(controller: _authorController, decoration: const InputDecoration(hintText: "Author Name", prefixIcon: Icon(Icons.person, size: 18))),
            ]),
            const SizedBox(height: 16),
            _buildResponsiveRow(context, [
              _buildDropdown(context, "Category", _selectedCategory, _filterOptions?.categories ?? [], (v) => setState(() => _selectedCategory = v!)),
              _buildDropdown(context, "Language", _selectedLanguage, _filterOptions?.languages ?? [], (v) => setState(() => _selectedLanguage = v!)),
            ]),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: () => _fetchBooks(), child: const Text("SEARCH"))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(
                  onPressed: () {
                    _titleController.clear();
                    _authorController.clear();
                    setState(() => _selectedCategory = 'All');
                    _fetchBooks();
                  },
                  child: const Text("RESET"),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) return Column(children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList());
    return Row(children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList());
  }

  Widget _buildDropdown(BuildContext context, String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: options.contains(value) ? value : 'All',
      items: ['All', ...options].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, contentPadding: const EdgeInsets.symmetric(horizontal: 12)),
    );
  }

  Widget _buildBookList(BuildContext context) {
    if (_books.isEmpty && !_isLoading) {
      return Center(child: Padding(padding: const EdgeInsets.all(40), child: Text("No books found", style: TextStyle(color: Theme.of(context).hintColor))));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isTablet ? 3 : 1,
        mainAxisExtent: 160,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        final theme = Theme.of(context);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text("by ${book.author}", style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor), maxLines: 1),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("ISBN: ${book.isbn ?? 'N/A'}", style: const TextStyle(fontSize: 10)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (book.availableCopies > 0 ? Colors.green : Colors.red).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text("${book.availableCopies} available", 
                        style: TextStyle(color: book.availableCopies > 0 ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPagination(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: _currentPage > 1 ? () => _fetchBooks(page: _currentPage - 1) : null, icon: const Icon(Icons.chevron_left)),
        Text("$_currentPage / $_totalPages", style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(onPressed: _currentPage < _totalPages ? () => _fetchBooks(page: _currentPage + 1) : null, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}
