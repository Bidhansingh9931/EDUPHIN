import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    _buildFilterSection(filters),
                    if (snapshot.hasError)
                      Center(child: Padding(padding: EdgeInsets.all(context.spacing), child: Text("Error: ${snapshot.error}", style: TextStyle(color: context.theme.colorScheme.error))))
                    else
                      _buildBooksTable(books, snapshot.data),
                    SizedBox(height: context.spacing * 2),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(BookFilters? availableFilters) {
    final theme = context.theme;
    return buildFilterCard(
      context,
      children: [
        Row(
          children: [
            Icon(Icons.filter_list, size: context.scale(18), color: theme.colorScheme.primary),
            SizedBox(width: context.scale(8)),
            Text(
              "Filter & Search",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.font(16),
              ),
            ),
          ],
        ),
        SizedBox(height: context.spacing),
        buildResponsiveRow(context, [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel("Title"),
              buildTextField(context, _titleController, "Search Title"),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel("Author"),
              buildTextField(context, _authorController, "Search Author"),
            ],
          ),
        ]),
        SizedBox(height: context.spacing / 2),
        buildResponsiveRow(context, [
          _dropdownGroup("Category", ['All', ...(availableFilters?.categories ?? [])], 'category'),
          _dropdownGroup("Language", ['All', ...(availableFilters?.languages ?? [])], 'language'),
        ]),
        SizedBox(height: context.spacing / 2),
        buildResponsiveRow(context, [
          _dropdownGroup("Format", ['All', ...(availableFilters?.formats ?? [])], 'format'),
          _dropdownGroup("Year", ['All', ...(availableFilters?.years ?? [])], 'year'),
        ]),
        SizedBox(height: context.scale(24)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: context.scale(120),
              child: buildActionButton(
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
                isPrimary: false,
              ),
            ),
            SizedBox(width: context.scale(12)),
            SizedBox(
              width: context.scale(120),
              child: buildActionButton(
                context,
                "SEARCH",
                () => setState(() {
                  _currentPage = 1;
                  _loadBooks();
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(top: context.spacing / 2, bottom: context.spacing / 4),
      child: Text(
        text,
        style: context.theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: context.font(12),
        ),
      ),
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
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      margin: context.pagePadding,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.spacing),
            child: Text(
              "${books.length} Books Found",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.font(14),
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: context.scale(24),
                headingRowHeight: context.scale(56),
                dataRowMinHeight: context.scale(56),
                dataRowMaxHeight: context.scale(64),
                headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                columns: [
                  DataColumn(label: Text("Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: colorScheme.onSurfaceVariant))),
                  DataColumn(label: Text("Author", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: colorScheme.onSurfaceVariant))),
                  DataColumn(label: Text("Qty (Avail)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: colorScheme.onSurfaceVariant))),
                ],
                rows: books.isEmpty 
                  ? []
                  : books.map((book) => DataRow(cells: [
                      DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(book.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: colorScheme.onSurface)),
                          if (book.category != null)
                            Text(book.category!, style: TextStyle(fontSize: context.font(11), color: colorScheme.onSurfaceVariant)),
                        ],
                      )),
                      DataCell(Text(book.author, style: TextStyle(fontSize: context.font(13), color: colorScheme.onSurface))),
                      DataCell(Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${book.availableCopies}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.font(13),
                                    color: book.availableCopies > 0 ? const Color(0xFF10B981) : colorScheme.error)),
                            Text("Avail", style: TextStyle(fontSize: context.font(10), color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      )),
                    ])).toList(),
              ),
            ),
          ),
          if (books.isEmpty)
            Padding(
              padding: EdgeInsets.all(context.spacing * 2),
              child: Center(child: Text("No books found", style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurfaceVariant))),
            ),
          if (pagination != null && pagination.lastPage > 1) _buildPagination(pagination),
        ],
      ),
    );
  }

  Widget _buildPagination(BookPagination pagination) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(context.spacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: pagination.currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                      _loadBooks();
                    });
                  }
                : null,
            icon: Icon(Icons.chevron_left, size: context.scale(24), color: colorScheme.primary),
          ),
          Text(
            "Page ${pagination.currentPage} of ${pagination.lastPage}",
            style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.w500, color: colorScheme.onSurface),
          ),
          IconButton(
            onPressed: pagination.currentPage < pagination.lastPage
                ? () {
                    setState(() {
                      _currentPage++;
                      _loadBooks();
                    });
                  }
                : null,
            icon: Icon(Icons.chevron_right, size: context.scale(24), color: colorScheme.primary),
          ),
        ],
      ),
    );
  }


}
