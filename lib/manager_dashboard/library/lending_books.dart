import 'dart:convert';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart';
import 'package:flutter/material.dart';

class LendingBooksScreen extends StatefulWidget {
  const LendingBooksScreen({super.key});

  @override
  State<LendingBooksScreen> createState() => _LendingBooksScreenState();
}

class _LendingBooksScreenState extends State<LendingBooksScreen> {
  bool _isLoading = true;
  Object? _error;
  List<IssuedBook> _issuedBooks = [];

  @override
  void initState() {
    super.initState();
    _loadCachedData().then((_) => _fetchIssuedBooks());
  }

  Future<void> _loadCachedData() async {
    final cache = await CacheService.getCache('lending_books');
    if (cache != null && mounted) {
      final List<dynamic> data = cache;
      setState(() {
        _issuedBooks = data.map((json) => IssuedBook.fromJson(json)).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchIssuedBooks() async {
    if (mounted) {
      setState(() {
        _isLoading = _issuedBooks.isEmpty;
        _error = null;
      });
    }
    try {
      final response = await ApiService.get('manager/books/issued');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == true) {
          final List<dynamic> data = body['data'] is List ? body['data'] : (body['data']['data'] ?? []);
          await CacheService.setCache('lending_books', data);
          if (mounted) {
            setState(() {
              _issuedBooks = data.map((json) => IssuedBook.fromJson(json)).toList();
              _isLoading = false;
            });
          }
        } else {
          throw Exception(body['message'] ?? 'Failed to load lending books');
        }
      } else {
        throw Exception('Failed to load lending books. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
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
            Text("Track issued and overdue library books", style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor, fontSize: context.font(11))),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _fetchIssuedBooks,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh",
          ),
          SizedBox(width: context.xs),
        ],
      ),
      body: LoadingWrapper(
        isLoading: _isLoading,
        hasData: _issuedBooks.isNotEmpty,
        error: _error,
        onRetry: _fetchIssuedBooks,
        skeleton: _buildSkeleton(context),
        child: _issuedBooks.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.library_books_outlined, size: context.scale(64), color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    SizedBox(height: context.scale(16)),
                    Text("No books currently lent out.", style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16))),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchIssuedBooks,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: context.responsive(
                      _buildListView(),
                      tablet: _buildGridView(2),
                      desktop: _buildGridView(3),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        elevation: 0,
        margin: EdgeInsets.only(bottom: context.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(16))),
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(context.spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonBox(width: context.scale(150), height: context.scale(20)),
                  SkeletonBox(width: context.scale(60), height: context.scale(20)),
                ],
              ),
              SizedBox(height: context.scale(8)),
              SkeletonBox(width: context.scale(100), height: context.scale(14)),
              SizedBox(height: context.scale(16)),
              Row(
                children: [
                  Expanded(child: SkeletonBox(height: context.scale(40))),
                  SizedBox(width: context.scale(16)),
                  Expanded(child: SkeletonBox(height: context.scale(40))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: context.pagePadding,
      itemCount: _issuedBooks.length,
      itemBuilder: (context, index) => _LendingCard(issuedBook: _issuedBooks[index]),
    );
  }

  Widget _buildGridView(int crossAxisCount) {
    return GridView.builder(
      padding: context.pagePadding,
      itemCount: _issuedBooks.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: context.md,
        crossAxisSpacing: context.md,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) => _LendingCard(issuedBook: _issuedBooks[index]),
    );
  }
}

class _LendingCard extends StatelessWidget {
  final IssuedBook issuedBook;

  const _LendingCard({required this.issuedBook});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isOverdue = issuedBook.daysOverdue != null && issuedBook.daysOverdue! > 0;

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: context.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: EdgeInsets.all(context.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(issuedBook.book.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                      Text("Issue No: ${issuedBook.issueNo}", style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (isOverdue)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(4)),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(context.scale(6)),
                    ),
                    child: Text(
                      "${issuedBook.daysOverdue} DAYS OVERDUE",
                      style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold, fontSize: context.font(10)),
                    ),
                  ),
              ],
            ),
            SizedBox(height: context.md),
            Row(
              children: [
                _LendingInfoItem(icon: Icons.calendar_today_outlined, label: "Issued Date", value: issuedBook.issuedAt),
                SizedBox(width: context.lg),
                _LendingInfoItem(
                  icon: Icons.event_busy_outlined,
                  label: "Due Date",
                  value: issuedBook.dueDate,
                  valueColor: isOverdue ? theme.colorScheme.error : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LendingInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _LendingInfoItem({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      children: [
        Icon(icon, size: context.scale(16), color: theme.colorScheme.primary),
        SizedBox(width: context.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: context.font(9), color: theme.hintColor)),
            Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: context.font(12), color: valueColor)),
          ],
        ),
      ],
    );
  }
}
