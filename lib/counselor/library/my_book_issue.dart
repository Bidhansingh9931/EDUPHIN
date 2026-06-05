import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/error_handler.dart';
import '../../services/caching_service.dart';
import '../../services/common_widgets.dart';
import '../counselor_models.dart';

class MyBookIssuePage extends StatefulWidget {
  const MyBookIssuePage({super.key});

  @override
  State<MyBookIssuePage> createState() => _MyBookIssuePageState();
}

class _MyBookIssuePageState extends State<MyBookIssuePage> {
  bool _isLoading = true;
  List<IssuedBook> _issuedBooks = [];
  String? _errorMessage;
  final String _cacheKey = 'counselor_library_lending_data';

  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _dueFromController = TextEditingController();
  final TextEditingController _dueToController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchLendingHistory();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CachingService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      _processData(cachedData);
      setState(() => _isLoading = false);
    }
  }

  void _processData(dynamic data) {
    dynamic booksData = data['issuedBooks'] ?? data['data'] ?? [];
    List rawList = [];
    if (booksData is List) {
      rawList = booksData;
    } else if (booksData is Map && booksData['data'] is List) {
      rawList = booksData['data'];
    }
    _issuedBooks = rawList.map((json) => IssuedBook.fromJson(json)).toList();
  }

  Future<void> _fetchLendingHistory() async {
    if (_issuedBooks.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final queryParams = <String, String>{};
      if (_bookTitleController.text.isNotEmpty) queryParams['book_title'] = _bookTitleController.text;
      if (_dueFromController.text.isNotEmpty) queryParams['due_from'] = _dueFromController.text;
      if (_dueToController.text.isNotEmpty) queryParams['due_to'] = _dueToController.text;

      final response = await ApiService.get('counselor/library/lending', queryParams);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await CachingService.saveData(_cacheKey, data);
        if (mounted) {
          setState(() {
            _processData(data);
            _isLoading = false;
            _errorMessage = null;
          });
        }
      } else {
        if (mounted && _issuedBooks.isEmpty) {
          setState(() {
            _errorMessage = ErrorHandler.getMessage("Failed to load lending history. Status: ${response.statusCode}");
            _isLoading = false;
          });
          ErrorHandler.showError(context, _errorMessage);
        }
      }
    } catch (e) {
      if (mounted && _issuedBooks.isEmpty) {
        setState(() {
          _errorMessage = ErrorHandler.getMessage(e);
          _isLoading = false;
        });
        ErrorHandler.showError(context, e);
      }
    }
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(context.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Skeleton(width: 150, height: 24),
                      SizedBox(height: context.md),
                      Row(
                        children: [
                          Expanded(child: Skeleton(height: 48, borderRadius: BorderRadius.circular(8))),
                          SizedBox(width: context.sm),
                          Expanded(child: Skeleton(height: 48, borderRadius: BorderRadius.circular(8))),
                        ],
                      ),
                      SizedBox(height: context.md),
                      Row(
                        children: [
                          Expanded(child: Skeleton(height: 40, borderRadius: BorderRadius.circular(8))),
                          SizedBox(width: context.sm),
                          Expanded(child: Skeleton(height: 40, borderRadius: BorderRadius.circular(8))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.xl),
              Card(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(context.md),
                      child: Skeleton(width: double.infinity, height: 48, borderRadius: BorderRadius.circular(8)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(context.md),
                      child: Column(
                        children: List.generate(
                            5,
                            (index) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(5, (i) => Skeleton(width: 70, height: 14)),
                                  ),
                                )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: const Text("My Issued Books"),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLendingHistory,
        child: LoadingWrapper(
          isLoading: _isLoading,
          hasData: _issuedBooks.isNotEmpty,
          skeleton: _buildSkeleton(),
          child: _errorMessage != null && _issuedBooks.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(context.scale(24.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: context.theme.colorScheme.error, size: context.scale(48)),
                        SizedBox(height: context.md),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: context.theme.colorScheme.error, fontSize: context.font(14))),
                        SizedBox(height: context.lg),
                        FilledButton.icon(onPressed: _fetchLendingHistory, icon: const Icon(Icons.refresh), label: const Text("RETRY")),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: context.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Column(
                        children: [
                          Card(
                            elevation: 0,
                            color: context.theme.colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.scale(12)),
                              side: BorderSide(
                                color: context.theme.colorScheme.outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(context.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Search Filters",
                                      style: context.theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.font(18))),
                                  SizedBox(height: context.md),
                                  _buildResponsiveRow(context, [
                                    _buildTextField(context, "Book Title", _bookTitleController),
                                    _buildDateField(context, "Due Date From", _dueFromController),
                                  ]),
                                  SizedBox(height: context.md),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _fetchLendingHistory,
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                vertical: context.sm),
                                          ),
                                          child: const Text("APPLY"),
                                        ),
                                      ),
                                      SizedBox(width: context.sm),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            _bookTitleController.clear();
                                            _dueFromController.clear();
                                            _dueToController.clear();
                                            _fetchLendingHistory();
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                vertical: context.sm),
                                          ),
                                          child: const Text("RESET"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: context.xl),
                          Card(
                            elevation: 0,
                            color: context.theme.colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(context.scale(12)),
                              side: BorderSide(
                                color: context.theme.colorScheme.outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(context.md),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (v) => setState(() {}),
                                    decoration: InputDecoration(
                                      hintText: "Quick search...",
                                      hintStyle: TextStyle(fontSize: context.font(14)),
                                      prefixIcon: Icon(Icons.search, size: context.scale(20)),
                                    ),
                                  ),
                                ),
                                if (_issuedBooks.isEmpty)
                                  Padding(
                                      padding: EdgeInsets.all(context.xl),
                                      child: const Center(child: Text("No records found")))
                                else
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columnSpacing: context.lg,
                                      headingRowColor: WidgetStateProperty.all(context
                                          .theme.colorScheme.primary
                                          .withValues(alpha: 0.05)),
                                      columns: [
                                        DataColumn(
                                            label: Text("#",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: context.font(14)))),
                                        DataColumn(
                                            label: Text("Title",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: context.font(14)))),
                                        DataColumn(
                                            label: Text("Issued",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: context.font(14)))),
                                        DataColumn(
                                            label: Text("Due Date",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: context.font(14)))),
                                        DataColumn(
                                            label: Text("Status",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: context.font(14)))),
                                      ],
                                      rows: _issuedBooks
                                          .where((b) => b.book.title
                                              .toLowerCase()
                                              .contains(_searchController.text.toLowerCase()))
                                          .toList()
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        int idx = entry.key;
                                        IssuedBook issue = entry.value;
                                        bool isReturned = issue.returnedAt != null;
                                        return DataRow(cells: [
                                          DataCell(Text("${idx + 1}",
                                              style: TextStyle(fontSize: context.font(14)))),
                                          DataCell(SizedBox(
                                              width: context.scale(150),
                                              child: Text(issue.book.title,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: context.font(14))))),
                                          DataCell(Text(issue.issuedAt ?? "-",
                                              style: TextStyle(fontSize: context.font(14)))),
                                          DataCell(Text(issue.dueDate ?? "-",
                                              style: TextStyle(fontSize: context.font(14)))),
                                          DataCell(
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: context.sm,
                                                  vertical: context.xs),
                                              decoration: BoxDecoration(
                                                color: (isReturned ? Colors.green : Colors.orange)
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(context.scale(6)),
                                                border: Border.all(
                                                    color: (isReturned
                                                            ? Colors.green
                                                            : Colors.orange)
                                                        .withValues(alpha: 0.5)),
                                              ),
                                              child: Text(
                                                isReturned ? "Returned" : "Pending",
                                                style: TextStyle(
                                                  color: isReturned ? Colors.green : Colors.orange,
                                                  fontSize: context.font(10),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: context.xl),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (context.isMobile) return Column(children: children);
    return Row(
        children: children
            .map((c) => Expanded(
                child: Padding(
                    padding: EdgeInsets.only(right: context.sm), child: c)))
            .toList());
  }

  Widget _buildTextField(
      BuildContext context, String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: context.font(14)),
        decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontSize: context.font(14)),
            contentPadding: EdgeInsets.symmetric(
                horizontal: context.sm, vertical: context.xs)),
      ),
    );
  }

  Widget _buildDateField(
      BuildContext context, String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.md),
      child: TextField(
        controller: controller,
        readOnly: true,
        style: TextStyle(fontSize: context.font(14)),
        onTap: () async {
          DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101));
          if (picked != null) {
            controller.text = DateFormat("yyyy-MM-dd").format(picked);
          }
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: context.font(14)),
          suffixIcon: Icon(Icons.calendar_today, size: context.scale(18)),
          contentPadding: EdgeInsets.symmetric(
              horizontal: context.sm, vertical: context.xs),
        ),
      ),
    );
  }
}

