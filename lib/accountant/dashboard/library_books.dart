import 'package:eduphin/services/common_widgets.dart';
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
  late Stream<BookPagination> _booksStream;
  BookFilters? _filterOptions;
  int _currentPage = 1;

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

  void _fetchBooks({int page = 1}) {
    final filters = {
      'title': _titleController.text,
      'author': _authorController.text,
      'isbn': _isbnController.text,
      if (_selectedCategory != 'All') 'category': _selectedCategory,
      if (_selectedLanguage != 'All') 'language': _selectedLanguage,
    };
    setState(() {
      _currentPage = page;
      _booksStream = ApiService.getAccountantLibraryBooksStream(filters, page);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Library Inventory"),
        centerTitle: true,
      ),
      body: StreamBuilder<BookPagination>(
        stream: _booksStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _filterOptions = snapshot.data!.filters;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: context.spacing),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.scale(1000)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(context),
                    SizedBox(height: context.spacing * 1.5),
                    LoadingWrapper<BookPagination>(
                      snapshot: snapshot,
                      onRetry: () => _fetchBooks(page: _currentPage),
                      skeleton: _buildSkeleton(),
                      builder: (pagination) {
                        final books = pagination.books;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: context.pagePadding.left),
                              child: Text(
                                "Books Found (${books.length})",
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: context.spacing),
                            _buildBookList(context, books),
                            SizedBox(height: context.spacing * 2),
                            _buildPagination(context, pagination.currentPage, pagination.lastPage),
                            SizedBox(height: context.spacing * 2),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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

  Widget _buildBookList(BuildContext context, List<Book> books) {
    final theme = context.theme;
    if (books.isEmpty) {
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
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
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

  Widget _buildPagination(BuildContext context, int currentPage, int totalPages) {
    final theme = context.theme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          onPressed: currentPage > 1 ? () => _fetchBooks(page: currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left)
        ),
        SizedBox(width: context.spacing),
        Text(
          "Page $currentPage of $totalPages",
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
        ),
        SizedBox(width: context.spacing),
        IconButton.filledTonal(
          onPressed: currentPage < totalPages ? () => _fetchBooks(page: currentPage + 1) : null,
          icon: const Icon(Icons.chevron_right)
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding.left),
          child: Skeleton(height: context.font(16), width: context.scale(150)),
        ),
        SizedBox(height: context.spacing),
        Padding(
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
            itemCount: 6,
            itemBuilder: (context, index) => Card(
              elevation: 0,
              color: context.theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.scale(16)),
                side: BorderSide(color: context.theme.colorScheme.outlineVariant, width: 0.5),
              ),
              child: Padding(
                padding: EdgeInsets.all(context.spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(width: context.scale(40), height: context.scale(40), borderRadius: context.scale(10)),
                        SizedBox(width: context.spacing / 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Skeleton(height: context.font(15), width: context.scale(150)),
                              SizedBox(height: context.scale(4)),
                              Skeleton(height: context.font(12), width: context.scale(100)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Divider(color: context.theme.colorScheme.outlineVariant, height: context.spacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Skeleton(height: context.font(10), width: context.scale(30)),
                            SizedBox(height: context.scale(2)),
                            Skeleton(height: context.font(12), width: context.scale(80)),
                          ],
                        ),
                        Skeleton(height: context.scale(20), width: context.scale(80), borderRadius: context.scale(8)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
