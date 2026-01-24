import 'package:flutter/material.dart';

class LendingBooksScreen extends StatefulWidget {
  const LendingBooksScreen({super.key});

  @override
  State<LendingBooksScreen> createState() => _LendingBooksScreenState();
}

class _LendingBooksScreenState extends State<LendingBooksScreen> {
  List<LendingBook> lendingBooks = [];
  bool isLoading = true; // To show a loader while fetching data

  @override
  void initState() {
    super.initState();
    _fetchLendingBooks();
  }

  // TODO: Replace this with your actual API call
  Future<void> _fetchLendingBooks() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final List<Map<String, dynamic>> dummyData = [
      {
        "title": "The Principles of Quantum Mechanics",
        "issueNo": "B00123",
        "issuedAt": "15 Jul 2024",
        "dueDate": "30 Jul 2024",
        "overdueDays": 0,
        "status": "Pending"
      },
      {
        "title": "Introduction to Algorithms",
        "issueNo": "B00124",
        "issuedAt": "01 Jul 2024",
        "dueDate": "16 Jul 2024",
        "overdueDays": 10,
        "status": "Overdue"
      },
      {
        "title": "The Art of Computer Programming",
        "issueNo": "B00125",
        "issuedAt": "20 Jun 2024",
        "dueDate": "05 Jul 2024",
        "overdueDays": 0,
        "status": "Returned"
      },
      {
        "title": "Cosmos",
        "issueNo": "B00126",
        "issuedAt": "10 Jul 2024",
        "dueDate": "25 Jul 2024",
        "overdueDays": 0,
        "status": "Pending"
      },
    ];

    if (mounted) {
      setState(() {
        lendingBooks =
            dummyData.map((data) => LendingBook.fromJson(data)).toList();
        isLoading = false;
      });
    }
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
          "Lending Books",
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return _buildGridView(lendingBooks);
                } else {
                  return _buildListView(lendingBooks);
                }
              },
            ),
    );
  }

  Widget _buildListView(List<LendingBook> books) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _LendingBookCard(book: book, index: index),
        );
      },
    );
  }

  Widget _buildGridView(List<LendingBook> books) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 50),
      itemCount: books.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500, // Adjust as needed
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2, // Adjust for content
      ),
      itemBuilder: (context, index) {
        final book = books[index];
        return _LendingBookCard(book: book, index: index);
      },
    );
  }
}

class _LendingBookCard extends StatelessWidget {
  final LendingBook book;
  final int index;

  const _LendingBookCard({required this.book, required this.index});

  Color _getStatusColor(BuildContext context, String status) {
    final theme = Theme.of(context);
    switch (status) {
      case "Pending":
        return Colors.amber.shade600;
      case "Overdue":
        return theme.colorScheme.error;
      case "Returned":
        return Colors.green.shade600;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // For GridView
        children: [
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "${index + 1}.  ${book.title}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                book.status,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _getStatusColor(context, book.status),
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          const SizedBox(height: 14),
          // Details Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoField(theme, "Book Issue Number", book.issueNo),
                    const SizedBox(height: 10),
                    _buildInfoField(theme, "Due Date", book.dueDate),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoField(theme, "Issued At", book.issuedAt),
                    const SizedBox(height: 10),
                    _buildInfoField(
                      theme,
                      "Days Overdue",
                      book.overdueDays.toString(),
                      highlight: book.overdueDays > 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(ThemeData theme, String label, String value,
      {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: highlight
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class LendingBook {
  final String title;
  final String issueNo;
  final String issuedAt;
  final String dueDate;
  final int overdueDays;
  final String status;

  LendingBook({
    required this.title,
    required this.issueNo,
    required this.issuedAt,
    required this.dueDate,
    required this.overdueDays,
    required this.status,
  });

  factory LendingBook.fromJson(Map<String, dynamic> json) {
    return LendingBook(
      title: json['title'] as String,
      issueNo: json['issueNo'] as String,
      issuedAt: json['issuedAt'] as String,
      dueDate: json['dueDate'] as String,
      overdueDays: json['overdueDays'] as int,
      status: json['status'] as String,
    );
  }
}
