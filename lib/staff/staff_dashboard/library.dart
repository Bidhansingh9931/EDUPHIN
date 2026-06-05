import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../services/responsive_helper.dart';
import '../../services/common_widgets.dart';
import '../../teacher/dashboard/library_models.dart';

class StaffLibraryPage extends StatefulWidget {
  const StaffLibraryPage({super.key});

  @override
  State<StaffLibraryPage> createState() => _StaffLibraryPageState();
}

class _StaffLibraryPageState extends State<StaffLibraryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  
  final List<Book> _books = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  Stream<BookPagination>? _libraryStream;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  void _fetchBooks({bool refresh = false}) {
    if (_isLoading && !refresh) return;
    
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _books.clear();
        _hasMore = true;
      });
    }

    if (!_hasMore && !refresh) return;

    final filters = {
      'title': _titleController.text.trim(),
      'author': _authorController.text.trim(),
    };
    
    setState(() {
      _libraryStream = ApiService.getStaffLibraryBooksStream(filters, _currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Library", style: TextStyle(fontSize: context.font(20))),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                _buildSearchCard(context),
                Padding(
                  padding: context.pagePadding,
                  child: _buildBookList(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: context.pagePadding.copyWith(bottom: 0),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.scale(20)),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.scale(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Search Books",
                style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: context.font(16))),
              SizedBox(height: context.scale(16)),
              context.responsive(
                Column(
                  children: [
                    _buildTextField(context, "Search Title...", Icons.search, _titleController),
                    SizedBox(height: context.scale(12)),
                    _buildTextField(context, "Search Author...", Icons.person_search_outlined, _authorController),
                  ],
                ),
                tablet: Row(
                  children: [
                    Expanded(child: _buildTextField(context, "Search Title...", Icons.search, _titleController)),
                    SizedBox(width: context.scale(16)),
                    Expanded(child: _buildTextField(context, "Search Author...", Icons.person_search_outlined, _authorController)),
                    SizedBox(width: context.scale(16)),
                    Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: FilledButton(
                        onPressed: () => _fetchBooks(refresh: true),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: context.scale(24), vertical: context.scale(16)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                        ),
                        child: const Text("SEARCH", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              if (context.isMobile) ...[
                SizedBox(height: context.scale(16)),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _fetchBooks(refresh: true),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                    ),
                    child: const Text("SEARCH", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String hint, IconData icon, TextEditingController controller) {
    final theme = context.theme;
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: context.font(14)),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: context.scale(20)),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(12)),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.scale(12)),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      onSubmitted: (_) => _fetchBooks(refresh: true),
    );
  }

  Widget _buildBookList(BuildContext context) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(20)),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.scale(20)),
            child: Text("Library Collection",
              style: GoogleFonts.roboto(fontSize: context.font(16), fontWeight: FontWeight.bold)),
          ),
          Divider(color: theme.colorScheme.outlineVariant, height: 1),
          StreamBuilder<BookPagination>(
            stream: _libraryStream,
            builder: (context, snapshot) {
              return LoadingWrapper<BookPagination>(
                snapshot: snapshot,
                skeleton: _buildSkeleton(context),
                onRetry: () => _fetchBooks(refresh: true),
                builder: (pagination) {
                  // Only update the list if it's the current page's data
                  if (pagination.currentPage == _currentPage || _currentPage == 1) {
                    final newBooks = pagination.books;
                    
                    // If it's the first page and we're receiving new data, 
                    // we might be transitioning from cache to network or just refreshing.
                    if (_currentPage == 1 && pagination.currentPage == 1) {
                      // Check if the data is different from what we have to avoid unnecessary UI jumps,
                      // but for simplicity and correctness with "Cache-then-Network", 
                      // we clear and re-populate if it's the first page refresh/load.
                      _books.clear();
                    }

                    // Prevent duplicates
                    for (var book in newBooks) {
                      if (!_books.any((b) => b.id == book.id)) {
                        _books.add(book);
                      }
                    }
                    _hasMore = pagination.currentPage < pagination.lastPage;
                  }

                  if (_books.isEmpty) return _buildEmptyState(context);

                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!_isLoading && _hasMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                        _isLoading = true;
                        _currentPage++;
                        _fetchBooks();
                      }
                      return true;
                    },
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: _books.length + (_hasMore ? 1 : 0),
                      separatorBuilder: (context, index) => Divider(color: theme.colorScheme.outlineVariant, height: 1),
                      itemBuilder: (context, index) {
                        if (index == _books.length) {
                          _isLoading = false; // Reset loading state when reaching the end
                          return Padding(
                            padding: EdgeInsets.all(context.scale(24)),
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        }

                        final book = _books[index];
                        return _buildBookItem(context, book);
                      },
                    ),
                  );
                },
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(BuildContext context, Book book) {
    final theme = context.theme;
    final isAvailable = book.availableCopies > 0;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(12)),
      leading: Container(
        width: context.scale(44),
        height: context.scale(44),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(context.scale(12)),
        ),
        child: Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary, size: context.scale(22)),
      ),
      title: Text(book.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(14))),
      subtitle: Padding(
        padding: EdgeInsets.only(top: context.scale(4)),
        child: Text(book.author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(12))),
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
        decoration: BoxDecoration(
          color: (isAvailable ? Colors.green : Colors.orange).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(context.scale(6)),
          border: Border.all(color: (isAvailable ? Colors.green : Colors.orange).withValues(alpha: 0.3)),
        ),
        child: Text(
          isAvailable ? "Available" : "Out of Stock",
          style: TextStyle(
            color: isAvailable ? Colors.green : Colors.orange,
            fontSize: context.font(10),
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 5,
      separatorBuilder: (context, index) => Divider(color: context.theme.colorScheme.outlineVariant, height: 1),
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(12)),
        child: Row(
          children: [
            Skeleton(width: context.scale(44), height: context.scale(44), borderRadius: context.scale(12)),
            SizedBox(width: context.scale(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: context.scale(150), height: context.scale(14)),
                  SizedBox(height: context.scale(8)),
                  Skeleton(width: context.scale(100), height: context.scale(12)),
                ],
              ),
            ),
            Skeleton(width: context.scale(70), height: context.scale(20), borderRadius: context.scale(6)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Padding(
      padding: EdgeInsets.all(context.scale(48)),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.library_books_rounded, size: context.scale(64), color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
            SizedBox(height: context.scale(16)),
            Text("No books found", 
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(16), fontWeight: FontWeight.bold)),
            SizedBox(height: context.scale(8)),
            Text("Try adjusting your search terms.", 
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: context.font(14))),
          ],
        ),
      ),
    );
  }
}
