import 'dart:convert';
import 'package:eduphin/services/error_handler.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/teacher/dashboard/teacher_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/teacher/dashboard/library_models.dart';
import 'common_widgets.dart';

class LendingBooksPage extends StatefulWidget {
  const LendingBooksPage({super.key});

  @override
  State<LendingBooksPage> createState() => _LendingBooksPageState();
}

class _LendingBooksPageState extends State<LendingBooksPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  
  bool _isLoading = true;
  LendingPagination? _data;
  String? _error;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadLendingData();
  }

  Future<void> _loadLendingData() async {
    final queryParams = <String, String>{
      if (_titleController.text.isNotEmpty) 'book_title': _titleController.text,
      if (_fromDateController.text.isNotEmpty) 'due_date_from': _fromDateController.text,
      if (_toDateController.text.isNotEmpty) 'due_date_to': _toDateController.text,
    };

    final cacheKey = 'lending_books_${_currentPage}_${jsonEncode(queryParams)}';
    
    // 1. Load from cache
    final cachedData = await TeacherCacheService.load(cacheKey);
    if (cachedData != null) {
      if (mounted) {
        setState(() {
          _data = LendingPagination.fromJson(cachedData);
          _isLoading = false;
        });
      }
    }

    // 2. Fetch from API
    try {
      final freshData = await ApiService.getLendingBooks(queryParams, _currentPage);
      await TeacherCacheService.save(cacheKey, freshData.toJson());
      
      if (mounted) {
        setState(() {
          _data = freshData;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (_data == null && mounted) {
        setState(() {
          _error = ErrorHandler.getMessage(e);
          _isLoading = false;
        });
      } else if (mounted) {
        ErrorHandler.showError(context, e);
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.book_outlined, size: context.scale(20)),
            SizedBox(width: context.scale(12)),
            const Text("My Lending Books"),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null && _data == null) {
      return Center(child: Text('Error: $_error', style: TextStyle(color: context.theme.colorScheme.error)));
    }

    final issuedBooks = _data?.issuedBooks ?? <IssuedBook>[];

    return TeacherLoadingWrapper(
      isLoading: _isLoading,
      hasData: _data != null,
      skeleton: _buildSkeletonLoader(context),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                _buildFilterSection(),
                _buildLendingTable(issuedBooks, _data),
                SizedBox(height: context.scale(32)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final theme = context.theme;
    return buildFilterCard(
      context,
      children: [
        Row(
          children: [
            Icon(Icons.filter_alt_outlined, size: context.scale(18), color: theme.colorScheme.primary),
            SizedBox(width: context.scale(8)),
            Text(
              "Filter Books",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.font(16),
              ),
            ),
          ],
        ),
        SizedBox(height: context.spacing),
        buildResponsiveRow(context, [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel("Book Title"),
              buildTextField(context, _titleController, "e.g. Math, Physics"),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel("Due Date From"),
              buildDateField(context, _fromDateController, "dd-mm-yyyy"),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel("Due Date To"),
              buildDateField(context, _toDateController, "dd-mm-yyyy"),
            ],
          ),
        ]),
        SizedBox(height: context.scale(24)),
        Row(
          children: [
            const Spacer(),
            SizedBox(
              width: context.scale(120),
              child: buildActionButton(
                context,
                "RESET",
                () {
                  _titleController.clear();
                  _fromDateController.clear();
                  _toDateController.clear();
                  setState(() {
                    _currentPage = 1;
                    _isLoading = true;
                    _data = null;
                  });
                  _loadLendingData();
                },
                isPrimary: false,
              ),
            ),
            SizedBox(width: context.scale(12)),
            SizedBox(
              width: context.scale(120),
              child: buildActionButton(
                context,
                "FILTER",
                () {
                  setState(() {
                    _currentPage = 1;
                    _isLoading = true;
                    _data = null;
                  });
                  _loadLendingData();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(top: context.spacing / 2, bottom: context.spacing / 4),
      child: Text(
        text,
        style: context.theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: context.font(12),
        ),
      ),
    );
  }

  Widget _buildLendingTable(List<IssuedBook> issuedBooks, LendingPagination? pagination) {
    final theme = context.theme;
    return Card(
      elevation: 0,
      margin: context.pagePadding,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.spacing),
            child: Text(
              "${issuedBooks.length} Books Found",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: context.font(14),
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: context.scale(24),
                headingRowHeight: context.scale(56),
                dataRowMinHeight: context.scale(56),
                dataRowMaxHeight: context.scale(64),
                headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                columns: [
                  DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                  DataColumn(label: Text("Issue No.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                  DataColumn(label: Text("Book Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                  DataColumn(label: Text("Due Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13), color: theme.colorScheme.onSurfaceVariant))),
                ],
                rows: issuedBooks.isEmpty 
                  ? []
                  : issuedBooks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return DataRow(cells: [
                        DataCell(Text("${(pagination!.currentPage - 1) * 10 + index + 1}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(13)))),
                        DataCell(Text(item.issueNo ?? "N/A", style: TextStyle(fontSize: context.font(13)))),
                        DataCell(Text(item.book.title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: context.font(13)))),
                        DataCell(Text(item.dueDate, style: TextStyle(fontSize: context.font(13)))),
                      ]);
                    }).toList(),
              ),
            ),
          ),
          if (issuedBooks.isEmpty)
            Padding(
              padding: EdgeInsets.all(context.spacing * 2),
              child: Center(child: Text("No records found", style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurfaceVariant))),
            ),
          if (pagination != null && pagination.lastPage > 1) _buildPagination(pagination),
        ],
      ),
    );
  }

  Widget _buildPagination(LendingPagination pagination) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(context.spacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: pagination.currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                      _isLoading = true;
                      _data = null;
                    });
                    _loadLendingData();
                  }
                : null,
            icon: Icon(Icons.chevron_left, size: context.scale(24), color: colorScheme.primary),
          ),
          Text(
            "Page ${pagination.currentPage} of ${pagination.lastPage}",
            style: TextStyle(fontSize: context.font(13), fontWeight: FontWeight.w500, color: colorScheme.onSurface),
          ),
          IconButton(
            onPressed: pagination.currentPage < pagination.lastPage
                ? () {
                    setState(() {
                      _currentPage++;
                      _isLoading = true;
                      _data = null;
                    });
                    _loadLendingData();
                  }
                : null,
            icon: Icon(Icons.chevron_right, size: context.scale(24), color: colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: context.pagePadding,
            child: TeacherSkeleton(
              height: context.scale(200),
              borderRadius: BorderRadius.circular(context.scale(16)),
            ),
          ),
          Padding(
            padding: context.pagePadding,
            child: TeacherSkeleton(
              height: context.scale(400),
              borderRadius: BorderRadius.circular(context.scale(16)),
            ),
          ),
        ],
      ),
    );
  }
}
