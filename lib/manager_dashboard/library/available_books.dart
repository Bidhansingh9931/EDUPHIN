import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:flutter/material.dart';

class Book {
  final String title;
  final String author;
  final String? isbn;
  final String? publicationYear;
  final String? category;
  final String? language;
  final String? format;
  final int? availableCopies;

  Book({
    required this.title,
    required this.author,
    this.isbn,
    this.publicationYear,
    this.category,
    this.language,
    this.format,
    this.availableCopies,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      isbn: map['isbn'],
      publicationYear: map['publication_year']?.toString(),
      category: map['category'],
      language: map['language'],
      format: map['format'],
      availableCopies: map['available_copies'],
    );
  }
}

class AvailableBooksScreen extends StatefulWidget {
  const AvailableBooksScreen({super.key});

  @override
  State<AvailableBooksScreen> createState() => _AvailableBooksScreenState();
}

class _AvailableBooksScreenState extends State<AvailableBooksScreen> {
  final searchController = TextEditingController();
  bool _isLoading = true;
  String _error = '';

  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      final response = await ApiService.get('manager/books');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true) {
          final List<dynamic> bookData = body['data']['data'];
          if (mounted) {
            setState(() {
              _allBooks = bookData.map((data) => Book.fromMap(data)).toList();
              _filteredBooks = _allBooks;
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _error = 'Failed to load books: ${body['message']}';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load books. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'An error occurred: $e';
          _isLoading = false;
        });
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
        title: Text(
          "Available Books",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "Search by Title, Author, or Category...",
                hintStyle: TextStyle(color: theme.hintColor),
                prefixIcon: Icon(Icons.search, color: theme.hintColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterBooks,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(child: Text(_error, style: TextStyle(color: theme.colorScheme.error)))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              return _buildGridView(_filteredBooks);
                            } else {
                              return _buildListView(_filteredBooks);
                            }
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<Book> books) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _BookCard(book: books[index], index: index),
        );
      },
    );
  }

  Widget _buildGridView(List<Book> books) {
    return GridView.builder(
      itemCount: books.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.2, // Adjust for content
      ),
      itemBuilder: (context, index) {
        return _BookCard(book: books[index], index: index);
      },
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;
  final int index;

  const _BookCard({required this.book, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${index + 1}.  ${book.title}",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoField(theme, "Author", book.author),
                    _buildInfoField(theme, "Year", book.publicationYear ?? '-'),
                    _buildInfoField(theme, "ISBN", book.isbn ?? '-'),
                    _buildInfoField(theme, "Format", book.format ?? '-'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoField(theme, "Category", book.category ?? '-'),
                    _buildInfoField(theme, "Language", book.language ?? '-'),
                    _buildInfoField(theme, "Available Copies", book.availableCopies?.toString() ?? '-'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
