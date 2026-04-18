import 'dart:convert';

import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:flutter/material.dart';

class LendingBooksScreen extends StatefulWidget {
  const LendingBooksScreen({super.key});

  @override
  State<LendingBooksScreen> createState() => _LendingBooksScreenState();
}

class _LendingBooksScreenState extends State<LendingBooksScreen> {
  List<LendingBook> lendingBooks = [];
  bool _isLoading = true; // To show a loader while fetching data

  @override
  void initState() {
    super.initState();
    _fetchLendingBooks();
  }

  Future<void> _fetchLendingBooks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.get('manager/lending');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        if (body['status'] == true &&
            body['data'] != null &&
            body['data']['data'] != null) {
          final List<dynamic> data = body['data']['data'];
          if (mounted) {
            setState(() {
              lendingBooks =
                  data.map((json) => LendingBook.fromJson(json)).toList();
              _isLoading = false;
            });
          }
        } else {
          throw Exception(body['message'] ?? 'Failed to parse lending books data');
        }
      } else {
        throw Exception(
            'Failed to load lending books. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
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
            Text("Lending Books", style: theme.appBarTheme.titleTextStyle?.copyWith(fontSize: context.font(18))),
            Text("Track issued books and overdue status", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
          ],
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : lendingBooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.library_books_outlined, size: context.scale(64), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      SizedBox(height: context.scale(16)),
                      Text("No lending records found.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16))),
                    ],
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: context.responsive(
                      _buildListView(lendingBooks),
                      tablet: _buildGridView(lendingBooks, crossAxisCount: 2),
                      desktop: _buildGridView(lendingBooks, crossAxisCount: 3),
                    ),
                  ),
                ),
    );
  }

  Widget _buildListView(List<LendingBook> books) {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: books.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: context.md),
          child: _LendingBookCard(book: books[index], index: index),
        );
      },
    );
  }

  Widget _buildGridView(List<LendingBook> books, {required int crossAxisCount}) {
    return GridView.builder(
      padding: context.pagePadding,
      itemCount: books.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: context.md,
        crossAxisSpacing: context.md,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        return _LendingBookCard(book: books[index], index: index);
      },
    );
  }
}

class _LendingBookCard extends StatelessWidget {
  final LendingBook book;
  final int index;

  const _LendingBookCard({required this.book, required this.index});

  Color _getStatusColor(BuildContext context, String status) {
    final theme = context.theme;
    switch (status) {
      case "Pending":
        return theme.colorScheme.secondary;
      case "Overdue":
        return theme.colorScheme.error;
      case "Returned":
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final statusColor = _getStatusColor(context, book.status);
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
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
                          fontSize: context.font(15),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.scale(8)),
                ),
                child: Text(
                  book.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: context.font(10),
                    letterSpacing: 0.5,
                  ),
                ),
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
                    _buildInfoField(context, "Issue Number", book.issueNo),
                    _buildInfoField(context, "Due Date", book.dueDate),
                  ],
                ),
              ),
              SizedBox(width: context.scale(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoField(context, "Issued At", book.issuedAt),
                    _buildInfoField(
                      context,
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

  Widget _buildInfoField(BuildContext context, String label, String value,
      {bool highlight = false}) {
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
              color: highlight ? theme.colorScheme.error : theme.colorScheme.onSurface,
              fontSize: context.font(13),
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
    final dueDateString = json['due_date'] as String?;
    final returnedAt = json['returned_at'];
    DateTime? dueDate;
    if (dueDateString != null) {
      dueDate = DateTime.tryParse(dueDateString);
    }

    int overdueDays = 0;
    if (returnedAt == null && dueDate != null && DateTime.now().isAfter(dueDate)) {
      overdueDays = DateTime.now().difference(dueDate).inDays;
    }

    String status;
    if (returnedAt != null) {
      status = "Returned";
    } else if (overdueDays > 0) {
      status = "Overdue";
    } else {
      status = "Pending";
    }

    String formatDate(String? dateString) {
      if (dateString == null) return 'N/A';
      try {
        final date = DateTime.parse(dateString);
        return date.toIso8601String().substring(0, 10);
      } catch (e) {
        return dateString;
      }
    }

    return LendingBook(
      title: json['book']?['title'] ?? 'N/A',
      issueNo: json['id']?.toString() ?? 'N/A',
      issuedAt: formatDate(json['issued_at'] as String?),
      dueDate: formatDate(dueDateString),
      overdueDays: overdueDays,
      status: status,
    );
  }
}
