import 'dart:convert';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/manager_dashboard/library/add_book.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart';
import 'package:flutter/material.dart';

class AvailableBooksScreen extends StatefulWidget {
  const AvailableBooksScreen({super.key});

  @override
  State<AvailableBooksScreen> createState() => _AvailableBooksScreenState();
}

class _AvailableBooksScreenState extends State<AvailableBooksScreen> {
  final searchController = TextEditingController();
  bool _isLoading = true;
  Object? _error;

  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _loadCachedData().then((_) => _fetchBooks());
  }

  Future<void> _loadCachedData() async {
    final cache = await CacheService.getCache('available_books');
    if (cache != null && mounted) {
      final List<dynamic> bookData = cache;
      setState(() {
        _allBooks = bookData.map((data) => Book.fromJson(data)).toList();
        _filterBooks(searchController.text);
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBooks() async {
    if (mounted) {
      setState(() {
        _isLoading = _allBooks.isEmpty;
        _error = null;
      });
    }
    try {
      final response = await ApiService.get('manager/books');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true) {
          final List<dynamic> bookData = body['data']['data'];
          await CacheService.setCache('available_books', bookData);
          if (mounted) {
            setState(() {
              _allBooks = bookData.map((data) => Book.fromJson(data)).toList();
              _filterBooks(searchController.text);
              _isLoading = false;
            });
          }
        } else {
          throw Exception(body['message'] ?? 'Failed to load books');
        }
      } else {
        throw Exception('Failed to load books. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
        ErrorHandler.showError(context, e);
      }
    }
  }

  void _filterBooks(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _filteredBooks = _allBooks.where((book) {
        final titleMatch = book.title.toLowerCase().contains(lowerCaseQuery);
        final authorMatch = book.author.toLowerCase().contains(lowerCaseQuery);
        final categoryMatch = book.category?.toLowerCase().contains(lowerCaseQuery) ?? false;
        return titleMatch || authorMatch || categoryMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Available Books", style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: context.font(18))),
            Text("Browse and search library inventory", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _fetchBooks,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh List",
          ),
          SizedBox(width: context.xs),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBookScreen()),
          );
          if (result == true) _fetchBooks();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text("Add Book"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: context.pagePadding.copyWith(bottom: 0),
                child: TextField(
                  controller: searchController,
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: context.font(14)),
                  decoration: InputDecoration(
                    hintText: "Search by Title, Author, or Category...",
                    hintStyle: TextStyle(color: theme.hintColor, fontSize: context.font(14)),
                    prefixIcon: Icon(Icons.search, color: theme.hintColor, size: context.scale(20)),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.scale(28)),
                      borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.scale(28)),
                      borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(12)),
                  ),
                  onChanged: _filterBooks,
                ),
              ),
              SizedBox(height: context.md),
              Expanded(
                child: LoadingWrapper(
                  isLoading: _isLoading,
                  hasData: _allBooks.isNotEmpty,
                  error: _error,
                  onRetry: _fetchBooks,
                  skeleton: _buildSkeleton(context),
                  child: _filteredBooks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: context.scale(64), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                              SizedBox(height: context.scale(16)),
                              Text("No books found matching your search.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16))),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchBooks,
                          child: context.responsive(
                            _buildListView(_filteredBooks),
                            tablet: _buildGridView(_filteredBooks, crossAxisCount: 2),
                            desktop: _buildGridView(_filteredBooks, crossAxisCount: 3),
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: context.md),
        child: Container(
          padding: EdgeInsets.all(context.spacing),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.scale(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(width: context.scale(30), height: context.scale(20)),
                  SizedBox(width: context.scale(12)),
                  Expanded(child: SkeletonBox(height: context.scale(20))),
                ],
              ),
              SizedBox(height: context.scale(16)),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(height: context.scale(12), width: context.scale(60)),
                        SizedBox(height: context.scale(4)),
                        SkeletonBox(height: context.scale(16)),
                      ],
                    ),
                  ),
                  SizedBox(width: context.scale(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(height: context.scale(12), width: context.scale(60)),
                        SizedBox(height: context.scale(4)),
                        SkeletonBox(height: context.scale(16)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<Book> books) {
    return ListView.builder(
      padding: context.pagePadding.copyWith(bottom: context.xl * 2),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: context.md),
          child: _BookCard(
            book: books[index],
            index: index,
            onEdit: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddBookScreen(book: books[index])),
              );
              if (result == true) _fetchBooks();
            },
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Book> books, {required int crossAxisCount}) {
    return GridView.builder(
      padding: context.pagePadding.copyWith(bottom: context.xl * 2),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: books.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: context.md,
        crossAxisSpacing: context.md,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        return _BookCard(
          book: books[index],
          index: index,
          onEdit: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddBookScreen(book: books[index])),
            );
            if (result == true) _fetchBooks();
          },
        );
      },
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final int index;
  final VoidCallback onEdit;

  const _BookCard({required this.book, required this.index, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(context.spacing),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(context.scale(6)),
                ),
                child: Text(
                  (index + 1).toString(),
                  style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: context.font(12)),
                ),
              ),
              SizedBox(width: context.scale(12)),
              Expanded(
                child: Text(
                  book.title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: context.font(16),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, size: context.scale(20), color: theme.colorScheme.primary),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          SizedBox(height: context.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoField(context, "Author", book.author),
                    _buildInfoField(context, "Year", book.publicationYear ?? '-'),
                    _buildInfoField(context, "ISBN", book.isbn ?? '-'),
                  ],
                ),
              ),
              SizedBox(width: context.scale(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoField(context, "Category", book.category ?? '-'),
                    _buildInfoField(context, "Format", book.format ?? '-'),
                    _buildInfoField(context, "Available", book.availableCopies?.toString() ?? '0', isHighlight: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(BuildContext context, String label, String value, {bool isHighlight = false}) {
    final theme = context.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.scale(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontSize: context.font(9),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              fontSize: context.font(13),
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
