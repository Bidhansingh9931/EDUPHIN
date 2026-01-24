import 'package:flutter/material.dart';

class Book {
  final String title;
  final String author;
  final String publisher;
  final String year;
  final String edition;
  final String volume;
  final String category;
  final String format;
  final String language;

  Book({
    required this.title,
    required this.author,
    required this.publisher,
    required this.year,
    required this.edition,
    required this.volume,
    required this.category,
    required this.format,
    required this.language,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      publisher: map['publisher'] ?? '',
      year: map['year'] ?? '',
      edition: map['edition'] ?? '',
      volume: map['volume'] ?? '',
      category: map['category'] ?? '',
      format: map['format'] ?? '',
      language: map['language'] ?? '',
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

  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final List<Map<String, dynamic>> bookData = [
      {
        "title": "The Principles of Quantum Mechanics",
        "author": "P.A.M. Dirac",
        "publisher": "Oxford University Press",
        "year": "1930",
        "edition": "4th",
        "volume": "1",
        "category": "Physics",
        "format": "Hardcover",
        "language": "English"
      },
      {
        "title": "Introduction to Algorithms",
        "author": "Thomas H. Cormen",
        "publisher": "MIT Press",
        "year": "2009",
        "edition": "3rd",
        "volume": "1",
        "category": "Computer Science",
        "format": "Paperback",
        "language": "English"
      },
      {
        "title": "The Art of Computer Programming",
        "author": "Donald E. Knuth",
        "publisher": "Addison-Wesley",
        "year": "1968",
        "edition": "1st",
        "volume": "2",
        "category": "Computer Science",
        "format": "eBook",
        "language": "English"
      },
      {
        "title": "Cosmos",
        "author": "Carl Sagan",
        "publisher": "Random House",
        "year": "1980",
        "edition": "1st",
        "volume": "1",
        "category": "Astronomy",
        "format": "Paperback",
        "language": "English"
      },
    ];

    if (mounted) {
      setState(() {
        _allBooks = bookData.map((data) => Book.fromMap(data)).toList();
        _filteredBooks = _allBooks;
        _isLoading = false;
      });
    }
  }

  void _filterBooks(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _filteredBooks = _allBooks.where((book) {
        final titleMatch = book.title.toLowerCase().contains(lowerCaseQuery);
        final authorMatch = book.author.toLowerCase().contains(lowerCaseQuery);
        final categoryMatch = book.category.toLowerCase().contains(lowerCaseQuery);
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
        childAspectRatio: 1.6, // Adjust for content
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
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${index + 1}.  ${book.title}",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
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
                    _buildInfoField(theme, "Year", book.year),
                    _buildInfoField(theme, "Volume", book.volume),
                    _buildInfoField(theme, "Format", book.format),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoField(theme, "Publisher", book.publisher),
                    _buildInfoField(theme, "Edition", book.edition),
                    _buildInfoField(theme, "Category", book.category),
                    _buildInfoField(theme, "Language", book.language),
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
                ?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.7)),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
