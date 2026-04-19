import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart' as teacher_library;
import 'package:eduphin/teacher/dashboard/common_widgets.dart';
import 'package:intl/intl.dart';

class LibraryLendingPage extends StatefulWidget {
  const LibraryLendingPage({super.key});

  @override
  State<LibraryLendingPage> createState() => _LibraryLendingPageState();
}

class _LibraryLendingPageState extends State<LibraryLendingPage> {
  bool _isLoading = false;
  List<teacher_library.IssuedBook> _issuedBooks = [];
  int _currentPage = 1;
  int _totalPages = 1;

  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _issuedFromController = TextEditingController();
  final TextEditingController _dueFromController = TextEditingController();
  final TextEditingController _dueToController = TextEditingController();
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _fetchLendingRecords();
  }

  @override
  void dispose() {
    _bookTitleController.dispose();
    _issuedFromController.dispose();
    _dueFromController.dispose();
    _dueToController.dispose();
    super.dispose();
  }

  Future<void> _fetchLendingRecords({int page = 1}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final filters = {
        'book_title': _bookTitleController.text,
        'issued_from': _issuedFromController.text,
        'due_from': _dueFromController.text,
        'due_to': _dueToController.text,
        if (_selectedStatus != 'all') 'returned_status': _selectedStatus,
      };
      final result = await ApiService.getAccountantLendingBooks(filters, page);
      if (mounted) {
        setState(() {
          _issuedBooks = result.issuedBooks;
          _currentPage = result.currentPage;
          _totalPages = result.lastPage;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetFilters() {
    _bookTitleController.clear();
    _issuedFromController.clear();
    _dueFromController.clear();
    _dueToController.clear();
    setState(() {
      _selectedStatus = 'all';
    });
    _fetchLendingRecords();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Lending History"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _fetchLendingRecords(page: 1),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: context.scale(1200)),
                  child: Column(
                    children: [
                      _buildFilterSection(context),
                      Padding(
                        padding: context.pagePadding,
                        child: Column(
                          children: [
                            _buildLendingList(context),
                            SizedBox(height: context.spacing * 2),
                            if (_totalPages > 1) _buildPagination(context),
                            SizedBox(height: context.spacing * 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final theme = context.theme;
    return buildFilterCard(
      context,
      children: [
        Row(
          children: [
            Icon(Icons.filter_list, color: theme.colorScheme.primary, size: context.scale(20)),
            SizedBox(width: context.scale(8)),
            Text(
              "Filter Records",
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: context.spacing),
        buildResponsiveRow(context, [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel(context, "Book Title"),
              buildTextField(context, _bookTitleController, "Enter title", prefixIcon: Icons.book),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel(context, "Issued From"),
              buildDateField(context, _issuedFromController, "Select date"),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLabel(context, "Status"),
              _buildStatusDropdown(context),
            ],
          ),
        ]),
        SizedBox(height: context.spacing * 1.5),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _fetchLendingRecords(page: 1),
                icon: Icon(Icons.search, size: context.scale(18)),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                ),
                label: const Text("Apply Filters"),
              ),
            ),
            SizedBox(width: context.spacing),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _resetFilters,
                icon: Icon(Icons.refresh, size: context.scale(18)),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: context.scale(14)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                ),
                label: const Text("Reset"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return buildDropdown(
      context,
      ['all', 'returned', 'issued'],
      _selectedStatus,
      (val) => setState(() => _selectedStatus = val!),
      hint: "Select Status",
    );
  }

  Widget _buildLendingList(BuildContext context) {
    final theme = context.theme;
    if (_issuedBooks.isEmpty && !_isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.scale(60)),
        child: Column(
          children: [
            Icon(Icons.library_books_outlined, size: context.scale(64), color: theme.colorScheme.outlineVariant),
            SizedBox(height: context.scale(16)),
            Text(
              "No records found",
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isDesktop ? 3 : (context.isTablet ? 2 : 1),
        mainAxisExtent: context.scale(180),
        crossAxisSpacing: context.spacing,
        mainAxisSpacing: context.spacing,
      ),
      itemCount: _issuedBooks.length,
      itemBuilder: (context, index) {
        final record = _issuedBooks[index];
        return _buildLendingCard(context, record);
      },
    );
  }

  Widget _buildLendingCard(BuildContext context, teacher_library.IssuedBook record) {
    final theme = context.theme;
    final isReturned = record.returnedAt != null;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.scale(16)),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      padding: EdgeInsets.all(context.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.book.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Book ID: ${record.book.id}",
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary, fontSize: context.font(12)),
                    ),
                  ],
                ),
              ),
              _statusBadge(context, isReturned),
            ],
          ),
          const Spacer(),
          Divider(color: theme.colorScheme.outlineVariant, height: context.scale(24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoCol(context, "ISSUED", record.issuedAt),
              _infoCol(context, "DUE DATE", record.dueDate, isEnd: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(BuildContext context, bool isReturned) {
    final theme = context.theme;
    final color = isReturned ? Colors.green : Colors.orange;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scale(20)),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        isReturned ? "RETURNED" : "ISSUED",
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          fontSize: context.font(10),
        ),
      ),
    );
  }

  Widget _infoCol(BuildContext context, String label, String value, {bool isEnd = false}) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
            fontWeight: FontWeight.bold,
            fontSize: context.font(10),
          ),
        ),
        SizedBox(height: context.scale(2)),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(13)),
        ),
      ],
    );
  }

  Widget _buildPagination(BuildContext context) {
    final theme = context.theme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          onPressed: _currentPage > 1 ? () => _fetchLendingRecords(page: _currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing * 1.5),
          child: Text(
            "Page $_currentPage of $_totalPages",
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton.filledTonal(
          onPressed: _currentPage < _totalPages ? () => _fetchLendingRecords(page: _currentPage + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
