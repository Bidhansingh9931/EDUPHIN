import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';

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
        if (_selectedCategory != 'All') 'category': _selectedCategory,
        if (_selectedLanguage != 'All') 'language': _selectedLanguage,
      };
      
      final booksPagination = await ApiService.getAccountantLibraryBooks(filters, page);
      
      if (mounted) {
        setState(() {
          _books = booksPagination.books;
          _filterOptions = booksPagination.filters;
          _currentPage = booksPagination.currentPage;
          _totalPages = booksPagination.lastPage;
        });
      }
    } catch (e) {
      debugPrint("Library Fetch Error: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library Inventory"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: context.spacing),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.scale(1000)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(context),
                    SizedBox(height: context.spacing * 1.5),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.pagePadding.left),
                      child: Text(
                        "Books Found (${_books.length})",
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: context.spacing),
                    _buildBookList(context),
                    SizedBox(height: context.spacing * 2),
                    _buildPagination(context),
                    SizedBox(height: context.spacing * 2),
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

  Widget _buildFilterSection(BuildContext context) {
    final theme = context.theme;
    return buildFilterCard(
      context,
      children: [
        Row(
          children: [
            Icon(Icons.search_rounded, color: theme.colorScheme.primary, size: context.scale(20)),
            SizedBox(width: context.scale(8)),
            Text("Search Inventory", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: context.spacing),
        buildResponsiveRow(context, [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel(context, "Book Title"),
              buildTextField(context, _titleController, "Search by title...", prefixIcon: Icons.book_outlined),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel(context, "Author"),
              buildTextField(context, _authorController, "Search by author...", prefixIcon: Icons.person_outline),
            ],
          ),
        ]),
        SizedBox(height: context.spacing),
        buildResponsiveRow(context, [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel(context, "Category"),
              buildDropdown(
                context, 
                ['All', ...(_filterOptions?.categories ?? [])], 
                _selectedCategory, 
                (v) => setState(() => _selectedCategory = v ?? 'All'),
                hint: "Select Category",
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel(context, "Language"),
              buildDropdown(
                context, 
                ['All', ...(_filterOptions?.languages ?? [])], 
                _selectedLanguage, 
                (v) => setState(() => _selectedLanguage = v ?? 'All'),
                hint: "Select Language",
              ),
            ],
          ),
        ]),
        SizedBox(height: context.spacing * 1.5),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: buildActionButton(context, "SEARCH BOOKS", () => _fetchBooks()),
            ),
            SizedBox(width: context.spacing),
            Expanded(
              child: buildActionButton(
                context, 
                "RESET", 
                () {
                  _titleController.clear();
                  _authorController.clear();
                  setState(() {
                    _selectedCategory = 'All';
                    _selectedLanguage = 'All';
                  });
                  _fetchBooks();
                },
                isPrimary: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookList(BuildContext context) {
    final theme = context.theme;
    if (_books.isEmpty && !_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.scale(40)),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: context.scale(48), color: theme.hintColor),
              SizedBox(height: context.scale(16)),
              Text("No books found matching your criteria", style: TextStyle(color: theme.hintColor)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pagePadding.left),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.isDesktop ? 3 : (context.isTablet ? 2 : 1),
          mainAxisExtent: context.scale(180),
          crossAxisSpacing: context.spacing,
          mainAxisSpacing: context.spacing,
        ),
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          final isAvailable = book.availableCopies > 0;
          
          return Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.scale(16)),
              side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
            ),
            child: Padding(
              padding: EdgeInsets.all(context.spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(context.scale(10)),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(context.scale(10)),
                        ),
                        child: Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary, size: context.scale(20)),
                      ),
                      SizedBox(width: context.spacing / 2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title, 
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(15)), 
                              maxLines: 2, 
                              overflow: TextOverflow.ellipsis
                            ),
                            Text(
                              "by ${book.author}", 
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Divider(color: theme.colorScheme.outlineVariant, height: context.spacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ISBN", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
                          Text(book.isbn ?? 'N/A', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                        decoration: BoxDecoration(
                          color: (isAvailable ? Colors.green : Colors.red).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(context.scale(8)),
                        ),
                        child: Text(
                          isAvailable ? "${book.availableCopies} Available" : "Out of Stock", 
                          style: TextStyle(
                            color: isAvailable ? Colors.green : Colors.red, 
                            fontSize: context.font(11), 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
    final theme = context.theme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          onPressed: _currentPage > 1 ? () => _fetchBooks(page: _currentPage - 1) : null, 
          icon: const Icon(Icons.chevron_left)
        ),
        SizedBox(width: context.spacing),
        Text(
          "Page $_currentPage of $_totalPages", 
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
        ),
        SizedBox(width: context.spacing),
        IconButton.filledTonal(
          onPressed: _currentPage < _totalPages ? () => _fetchBooks(page: _currentPage + 1) : null, 
          icon: const Icon(Icons.chevron_right)
        ),
      ],
    );
  }
}
