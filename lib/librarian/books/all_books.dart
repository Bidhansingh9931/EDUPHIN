import 'package:eduphin/librarian/librarian_skeleton_widgets.dart';
import 'package:eduphin/services/common_widgets.dart';
import '../../services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../teacher/dashboard/app_drawer.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart' as teacher_library;
import 'add_new_books.dart';

class AllBooksPage extends StatefulWidget {
  const AllBooksPage({super.key});

  @override
  State<AllBooksPage> createState() => _AllBooksPageState();
}

class _AllBooksPageState extends State<AllBooksPage> {
  List<teacher_library.Book> _books = [];
  int _currentPage = 1;
  int _totalPages = 1;
  late Stream<teacher_library.BookPagination> _booksStream;

  final Map<String, String> _filters = {
    'title': '',
    'author': '',
    'isbn': '',
    'category': 'All',
    'language': 'All',
    'format': 'All',
    'year': 'All',
    'availability': 'All',
  };

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    _booksStream = ApiService.getLibrarianBooksStream(_filters, _currentPage).asBroadcastStream();
    setState(() {});
  }

  Future<void> _fetchBooks() async {
    _refreshData();
  }

  Future<void> _deleteBook(int bookId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Book"),
        content: const Text("Are you sure you want to delete this book? This action is permanent."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text("DELETE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteLibrarianBook(bookId.toString());
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Book deleted successfully")));
        _fetchBooks();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Books Collection"),
        actions: [
          IconButton.filledTonal(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddNewBookPage()),
              );
              if (result == true) _fetchBooks();
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Add Book",
          ),
          SizedBox(width: context.scale(16)),
        ],
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<teacher_library.BookPagination>(
        stream: _booksStream,
        builder: (context, snapshot) {
          return LoadingWrapper<teacher_library.BookPagination>(
            snapshot: snapshot,
            skeleton: const GridSkeleton(),
            onRetry: _refreshData,
            builder: (pagination) {
              final books = pagination.books;
              _totalPages = pagination.lastPage;

              return RefreshIndicator(
                onRefresh: () async => _refreshData(),
                child: SingleChildScrollView(
                  padding: context.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterCard(context),
                          SizedBox(height: context.lg),
                          if (books.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(context.xl),
                                child: Column(
                                  children: [
                                    Icon(Icons.search_off_rounded, size: context.scale(64), color: context.theme.colorScheme.outlineVariant),
                                    SizedBox(height: context.md),
                                    Text(
                                      "No books found matching your criteria.",
                                      style: context.theme.textTheme.bodyLarge?.copyWith(color: context.theme.colorScheme.outline),
                                    ),
                                    SizedBox(height: context.sm),
                                    FilledButton.tonal(onPressed: _fetchBooks, child: const Text("Reset Filters"))
                                  ],
                                ),
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: context.responsive<int>(1, tablet: 2, desktop: 3),
                                mainAxisExtent: context.scale(260),
                                crossAxisSpacing: context.md,
                                mainAxisSpacing: context.md,
                              ),
                              itemCount: books.length,
                              itemBuilder: (context, index) => _buildBookCard(context, books[index]),
                            ),
                          SizedBox(height: context.lg),
                          _buildPagination(context, books.isNotEmpty),
                          SizedBox(height: context.xl),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


  Widget _buildFilterCard(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => _filters['title'] = val,
                    decoration: InputDecoration(
                      hintText: "Search Title",
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                if (context.isTablet || context.isDesktop) ...[
                  SizedBox(width: context.md),
                  Expanded(
                    child: TextField(
                      onChanged: (val) => _filters['author'] = val,
                      decoration: InputDecoration(
                        hintText: "Author",
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ]
              ],
            ),
            if (!(context.isTablet || context.isDesktop)) ...[
              SizedBox(height: context.sm),
              TextField(
                onChanged: (val) => _filters['author'] = val,
                decoration: InputDecoration(
                  hintText: "Author",
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
              ),
            ],
            SizedBox(height: context.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _fetchBooks,
                    icon: const Icon(Icons.filter_list_rounded),
                    label: const Text("APPLY FILTERS"),
                  ),
                ),
                SizedBox(width: context.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _filters.updateAll((k, v) => k == 'category' || k == 'language' || k == 'format' || k == 'year' || k == 'availability' ? 'All' : '');
                        _currentPage = 1;
                      });
                      _fetchBooks();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("RESET"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, teacher_library.Book book) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(24)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: context.font(16), color: theme.colorScheme.onSurface),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: context.xs),
                      Text(
                        "by ${book.author}",
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: context.font(12)),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: context.xs),
                _availabilityBadge(context, book.availableCopies),
              ],
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.all(context.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(context.scale(16)),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), width: 0.5),
              ),
              child: Column(
                children: [
                  _infoRow(context, "ISBN", book.isbn ?? "N/A"),
                  SizedBox(height: context.xs),
                  _infoRow(context, "Category", book.category ?? "N/A"),
                  SizedBox(height: context.xs),
                  _infoRow(context, "Inventory", "${book.availableCopies} / ${book.quantity}"),
                ],
              ),
            ),
            SizedBox(height: context.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton.filledTonal(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddNewBookPage(book: book)),
                    );
                    if (result == true) _fetchBooks();
                  },
                  icon: Icon(Icons.edit_document, size: context.scale(18)),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
                  ),
                ),
                SizedBox(width: context.sm),
                IconButton.filledTonal(
                  onPressed: () => _deleteBook(book.id),
                  icon: Icon(Icons.delete_sweep_outlined, size: context.scale(18)),
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _availabilityBadge(BuildContext context, int count) {
    final isAvailable = count > 0;
    final color = isAvailable ? Colors.green : context.theme.colorScheme.error;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.scale(6)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(context.scale(10)),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Text(
        isAvailable ? "AVAILABLE" : "OUT OF STOCK",
        style: TextStyle(
          color: color,
          fontSize: context.font(10),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.theme.textTheme.labelSmall?.copyWith(color: context.theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: context.theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800, color: context.theme.colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildPagination(BuildContext context, bool hasData) {
    if (!hasData) return const SizedBox.shrink();
    final theme = context.theme;

    return Center(
      child: Container(
        margin: EdgeInsets.only(top: context.md),
        padding: EdgeInsets.symmetric(horizontal: context.sm, vertical: context.scale(4)),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(context.scale(30)),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left_rounded, size: context.scale(24)),
              onPressed: _currentPage > 1
                  ? () {
                      setState(() {
                        _currentPage--;
                        _fetchBooks();
                      });
                    }
                  : null,
              style: IconButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.md),
              child: Text(
                "Page $_currentPage of ${_totalPages > 0 ? _totalPages : 1}",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: context.font(15),
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right_rounded, size: context.scale(24)),
              onPressed: (_totalPages == 0 || _currentPage < _totalPages)
                  ? () {
                      setState(() {
                        _currentPage++;
                        _fetchBooks();
                      });
                    }
                  : null,
              style: IconButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
