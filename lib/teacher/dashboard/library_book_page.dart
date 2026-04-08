import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart';
import 'common_widgets.dart';

class LibraryBookPage extends StatefulWidget {
  const LibraryBookPage({super.key});

  @override
  State<LibraryBookPage> createState() => _LibraryBookPageState();
}

class _LibraryBookPageState extends State<LibraryBookPage> {
  final Map<String, String?> _filters = {
    'title': '', 'author': '', 'isbn': '', 
    'category': null, 'language': null, 'format': null, 'year': null
  };
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  
  late Future<BookPagination> _booksFuture;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  void _loadBooks() {
    final queryParams = <String, String>{
      if (_titleController.text.isNotEmpty) 'title': _titleController.text,
      if (_authorController.text.isNotEmpty) 'author': _authorController.text,
      if (_isbnController.text.isNotEmpty) 'isbn': _isbnController.text,
      if (_filters['category'] != null && _filters['category'] != 'All') 'category': _filters['category']!,
      if (_filters['language'] != null && _filters['language'] != 'All') 'language': _filters['language']!,
      if (_filters['format'] != null && _filters['format'] != 'All') 'format': _filters['format']!,
      if (_filters['year'] != null && _filters['year'] != 'All') 'publication_year': _filters['year']!,
    };
    _booksFuture = ApiService.getLibraryBooks(queryParams, _currentPage);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library Books"),
      ),
      body: FutureBuilder<BookPagination>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final filters = snapshot.hasData ? snapshot.data!.filters : null;
          final books = snapshot.hasData ? snapshot.data!.books : <Book>[];

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildFilterSection(filters),
                if (snapshot.hasError) 
                  Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("Error: ${snapshot.error}")))
                else
                  _buildBooksTable(books, snapshot.data),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(BookFilters? availableFilters) {
    return buildFilterCard(
      context,
      children: [
        Row(
          children: [
            const Icon(Icons.filter_list, size: 18),
            const SizedBox(width: 8),
            Text("Filter & Search", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        _fieldLabel("Title"),
        buildTextField(context, _titleController, "Search Title"),
        _fieldLabel("Author"),
        buildTextField(context, _authorController, "Search Author"),
        
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _dropdownGroup("Category", ['All', ...(availableFilters?.categories ?? [])], 'category')),
            const SizedBox(width: 12),
            Expanded(child: _dropdownGroup("Language", ['All', ...(availableFilters?.languages ?? [])], 'language')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _dropdownGroup("Format", ['All', ...(availableFilters?.formats ?? [])], 'format')),
            const SizedBox(width: 12),
            Expanded(child: _dropdownGroup("Year", ['All', ...(availableFilters?.years ?? [])], 'year')),
          ],
        ),

        const SizedBox(height: 20),
        buildActionButton(context, "SEARCH", () => setState(() { _currentPage = 1; _loadBooks(); })),
        const SizedBox(height: 10),
        buildActionButton(
          context, 
          "RESET", 
          () => setState(() {
            _titleController.clear();
            _authorController.clear();
            _isbnController.clear();
            _filters.updateAll((k, v) => null);
            _currentPage = 1;
            _loadBooks();
          }),
          isPrimary: false
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _dropdownGroup(String label, List<String> items, String filterKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        buildDropdown(context, items, _filters[filterKey] ?? 'All', (val) {
          setState(() => _filters[filterKey] = val);
        }),
      ],
    );
  }

  Widget _buildBooksTable(List<Book> books, BookPagination? pagination) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("${books.length} Books Found", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          _buildTableHeader(),
          const Divider(height: 1),
          if (books.isEmpty)
            const Padding(padding: EdgeInsets.all(32), child: Center(child: Text("No books found")))
          else
            ...books.map((book) => Column(
              children: [
                _buildBookRow(book),
                const Divider(height: 1),
              ],
            )),
          
          if (pagination != null && pagination.lastPage > 1)
            _buildPagination(pagination),
        ],
      ),
    );
  }

  Widget _buildPagination(BookPagination pagination) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: pagination.currentPage > 1 ? () { setState(() { _currentPage--; _loadBooks(); }); } : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text("Page ${pagination.currentPage} of ${pagination.lastPage}"),
          IconButton(
            onPressed: pagination.currentPage < pagination.lastPage ? () { setState(() { _currentPage++; _loadBooks(); }); } : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text("Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(child: Text("Author", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          SizedBox(width: 60, child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildBookRow(Book book) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                if (book.category != null) Text(book.category!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            )
          ),
          Expanded(child: Text(book.author, style: const TextStyle(fontSize: 12))),
          SizedBox(
            width: 60, 
            child: Column(
              children: [
                Text("${book.availableCopies}", style: TextStyle(fontWeight: FontWeight.bold, color: book.availableCopies > 0 ? Colors.green : Colors.red)),
                const Text("Avail", style: TextStyle(fontSize: 8, color: Colors.grey)),
              ],
            )
          ),
        ],
      ),
    );
  }
}
