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

    setState(() {
      _allBooks = bookData.map((data) => Book.fromMap(data)).toList();
      _filteredBooks = _allBooks;
      _isLoading = false;
    });
  }

  void _filterBooks(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _filteredBooks = _allBooks.where((book) {
        final titleMatch = book.title.toLowerCase().contains(lowerCaseQuery);
        final authorMatch = book.author.toLowerCase().contains(lowerCaseQuery);
        return titleMatch || authorMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Available Books",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search by Title, Author...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xff101820),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _filterBooks,
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _filteredBooks.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final book = _filteredBooks[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xff0F1A2B),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Index + Title
                              Text(
                                "${index + 1}.  ${book.title}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        info("Author", book.author),
                                        info("Year", book.year),
                                        info("Volume", book.volume),
                                        info("Format", book.format),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        info("Publisher", book.publisher),
                                        info("Edition", book.edition),
                                        info("Category", book.category),
                                        info("Language", book.language),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label\n",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
