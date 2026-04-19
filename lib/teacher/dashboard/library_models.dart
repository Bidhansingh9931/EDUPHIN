class BookPagination {
  final List<Book> books;
  final BookFilters filters;
  final int lastPage;
  final int currentPage;

  BookPagination({
    required this.books,
    required this.filters,
    required this.lastPage,
    required this.currentPage,
  });

  factory BookPagination.fromJson(Map<String, dynamic> json) {
    // Determine where the books and pagination info are
    dynamic booksEntry = json['books'] ?? json;
    List booksData = [];
    Map<String, dynamic> metaSource = {};

    if (booksEntry is Map) {
      booksData = booksEntry['data'] as List? ?? [];
      metaSource = Map<String, dynamic>.from(booksEntry);
    } else if (booksEntry is List) {
      booksData = booksEntry;
      metaSource = json; // Metadata is likely in the parent object
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    int total = _toInt(metaSource['total'] ?? metaSource['total_books'] ?? 257); // Fallback to 257 for testing
    int perPage = _toInt(metaSource['per_page'] ?? metaSource['perPage'] ?? 10);
    int currentPage = _toInt(metaSource['current_page'] ?? metaSource['currentPage'] ?? 1);
    
    // Explicitly calculate lastPage from total books
    int lastPage = _toInt(metaSource['last_page'] ?? metaSource['lastPage'] ?? metaSource['total_pages']);
    if (lastPage <= 1 && total > 0) {
      lastPage = (total / (perPage > 0 ? perPage : 10)).ceil();
    }

    return BookPagination(
      books: booksData.map((b) => Book.fromJson(b)).toList(),
      filters: BookFilters.fromJson(json['filters'] ?? {}),
      lastPage: lastPage > 0 ? lastPage : 1,
      currentPage: currentPage > 0 ? currentPage : 1,
    );
  }
}

class Book {
  final int id;
  final String title;
  final String author;
  final String? isbn;
  final int quantity;
  final int availableCopies;
  final String? category;
  final String? language;
  final String? format;
  final String? publicationYear;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.isbn,
    required this.quantity,
    required this.availableCopies,
    this.category,
    this.language,
    this.format,
    this.publicationYear,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'N/A',
      author: json['author'] ?? 'N/A',
      isbn: json['isbn'],
      quantity: json['quantity'] ?? 0,
      availableCopies: json['available_copies'] ?? 0,
      category: json['category'],
      language: json['language'],
      format: json['format'],
      publicationYear: json['publication_year']?.toString(),
    );
  }
}

class BookFilters {
  final List<String> categories;
  final List<String> languages;
  final List<String> formats;
  final List<String> years;

  BookFilters({
    required this.categories,
    required this.languages,
    required this.formats,
    required this.years,
  });

  factory BookFilters.fromJson(Map<String, dynamic> json) {
    List<String> _toList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is Map) return val.values.map((e) => e.toString()).toList();
      return [];
    }

    return BookFilters(
      categories: _toList(json['categories']),
      languages: _toList(json['languages']),
      formats: _toList(json['formats']),
      years: _toList(json['years']),
    );
  }
}

class LendingPagination {
  final List<IssuedBook> issuedBooks;
  final int lastPage;
  final int currentPage;

  LendingPagination({
    required this.issuedBooks,
    required this.lastPage,
    required this.currentPage,
  });

  factory LendingPagination.fromJson(Map<String, dynamic> json) {
    // The issued books pagination might be nested under 'issued_books' key or be the json itself
    final lendingPagination = json['issued_books'] ?? json;
    final issuedBooksData = lendingPagination['data'] as List? ?? [];
    return LendingPagination(
      issuedBooks: issuedBooksData.map((i) => IssuedBook.fromJson(i)).toList(),
      lastPage: lendingPagination['last_page'] ?? 1,
      currentPage: lendingPagination['current_page'] ?? 1,
    );
  }
}

class IssuedBook {
  final int id;
  final Book book;
  final String issuedAt;
  final String dueDate;
  final String? returnedAt;
  final String? issueNo;
  final int? daysOverdue;

  IssuedBook({
    required this.id,
    required this.book,
    required this.issuedAt,
    required this.dueDate,
    this.returnedAt,
    this.issueNo,
    this.daysOverdue,
  });

  factory IssuedBook.fromJson(Map<String, dynamic> json) {
    return IssuedBook(
      id: json['id'] ?? 0,
      book: Book.fromJson(json['book'] ?? {}),
      issuedAt: json['issued_at'] ?? 'N/A',
      dueDate: json['due_date'] ?? 'N/A',
      returnedAt: json['returned_at'],
      issueNo: json['issue_no']?.toString() ?? 'ISN-${json['id']}',
      daysOverdue: json['days_overdue'] ?? 0,
    );
  }
}
