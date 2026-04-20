import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/caching_service.dart';
import '../../services/common_widgets.dart';
import '../counselor_models.dart';

class BookCatelogPage extends StatefulWidget {
  const BookCatelogPage({super.key});

  @override
  State<BookCatelogPage> createState() => _BookCatelogPageState();
}

class _BookCatelogPageState extends State<BookCatelogPage> {
  bool _isLoading = true;
  List<Book> _books = [];
  List<String> _categories = ["All"];
  List<String> _languages = ["All"];
  List<String> _formats = ["All"];
  List<String> _years = ["All"];

  String _selectedCategory = "All";
  String _selectedLanguage = "All";
  String _selectedFormat = "All";
  String _selectedYear = "All";

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final String _cacheKey = 'counselor_book_catelog_data';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchBooks();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CachingService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      _processData(cachedData);
      setState(() => _isLoading = false);
    }
  }

  void _processData(dynamic jsonResponse) {
    final data = jsonResponse['data'] is Map ? jsonResponse['data'] : jsonResponse;

    // 1. Parse Books
    final booksData = data['books'];
    if (booksData is List) {
      _books = booksData.map((json) => Book.fromJson(json)).toList();
    } else if (booksData is Map && booksData['data'] is List) {
      _books = (booksData['data'] as List).map((json) => Book.fromJson(json)).toList();
    } else {
      _books = [];
    }

    // 2. Parse Dropdown Options
    if (data['categories'] != null) {
      _categories = ["All", ...(data['categories'] as List).map((e) => e.toString())];
    }
    if (data['languages'] != null) {
      _languages = ["All", ...(data['languages'] as List).map((e) => e.toString())];
    }
    if (data['formats'] != null) {
      _formats = ["All", ...(data['formats'] as List).map((e) => e.toString())];
    }

    // 3. Handle publication_years
    if (data['publication_years'] != null) {
      final yearsSource = data['publication_years'];
      List<String> yearsList = [];
      if (yearsSource is Map) {
        yearsList = yearsSource.values.map((e) => e.toString()).toList();
      } else if (yearsSource is List) {
        yearsList = yearsSource.map((e) => e.toString()).toList();
      }
      yearsList = yearsList.toSet().toList()..sort((a, b) => b.compareTo(a));
      _years = ["All", ...yearsList];
    }
  }

  Future<void> _fetchBooks() async {
    if (_books.isEmpty) {
      setState(() => _isLoading = true);
    }
    try {
      final Map<String, String> queryParams = {};
      if (_titleController.text.isNotEmpty) queryParams['title'] = _titleController.text;
      if (_authorController.text.isNotEmpty) queryParams['author'] = _authorController.text;
      if (_isbnController.text.isNotEmpty) queryParams['isbn'] = _isbnController.text;
      if (_selectedCategory != "All") queryParams['category'] = _selectedCategory;
      if (_selectedLanguage != "All") queryParams['language'] = _selectedLanguage;
      if (_selectedFormat != "All") queryParams['format'] = _selectedFormat;
      if (_selectedYear != "All") queryParams['publication_year'] = _selectedYear;
      if (_searchController.text.isNotEmpty) queryParams['title'] = _searchController.text;

      final response = await ApiService.get('counselor/library/books', queryParams);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        await CachingService.saveData(_cacheKey, jsonResponse);
        if (mounted) {
          setState(() {
            _processData(jsonResponse);
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetFilters() {
    _titleController.clear();
    _authorController.clear();
    _isbnController.clear();
    _searchController.clear();
    setState(() {
      _selectedCategory = "All";
      _selectedLanguage = "All";
      _selectedFormat = "All";
      _selectedYear = "All";
    });
    _fetchBooks();
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: context.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(context.spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Skeleton(width: 150, height: 24),
                      SizedBox(height: context.spacing),
                      ...List.generate(
                          4,
                          (index) => Padding(
                                padding: EdgeInsets.only(bottom: context.spacing),
                                child: Row(
                                  children: [
                                    Expanded(child: Skeleton(height: 48, borderRadius: 8)),
                                    SizedBox(width: context.spacing / 2),
                                    Expanded(child: Skeleton(height: 48, borderRadius: 8)),
                                  ],
                                ),
                              )),
                      Row(
                        children: [
                          Expanded(child: Skeleton(height: 40, borderRadius: 8)),
                          SizedBox(width: context.spacing / 2),
                          Expanded(child: Skeleton(height: 40, borderRadius: 8)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.spacing * 1.5),
              const Skeleton(width: 180, height: 24),
              SizedBox(height: context.spacing),
              Card(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(context.spacing),
                      child: Skeleton(width: double.infinity, height: 48, borderRadius: 8),
                    ),
                    Padding(
                      padding: EdgeInsets.all(context.spacing),
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
        title: const Text("Book Catalog"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBooks,
        child: LoadingWrapper(
          isLoading: _isLoading,
          hasData: _books.isNotEmpty,
          skeleton: _buildSkeleton(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        padding: EdgeInsets.all(context.spacing),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Search Filters",
                                style: context.theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.font(18))),
                            SizedBox(height: context.spacing),
                            _buildResponsiveRow(context, [
                              _buildTextField(
                                  context, "Title", "Search Title", _titleController),
                              _buildTextField(
                                  context, "Author", "Search Author", _authorController),
                            ]),
                            _buildResponsiveRow(context, [
                              _buildTextField(
                                  context, "ISBN", "Search ISBN", _isbnController),
                              _buildDropdown(
                                  context,
                                  "Category",
                                  _categories,
                                  _selectedCategory,
                                  (val) => setState(() => _selectedCategory = val!)),
                            ]),
                            _buildResponsiveRow(context, [
                              _buildDropdown(
                                  context,
                                  "Language",
                                  _languages,
                                  _selectedLanguage,
                                  (val) => setState(() => _selectedLanguage = val!)),
                              _buildDropdown(
                                  context,
                                  "Year",
                                  _years,
                                  _selectedYear,
                                  (val) => setState(() => _selectedYear = val!)),
                            ]),
                            _buildResponsiveRow(context, [
                              _buildDropdown(
                                  context,
                                  "Format",
                                  _formats,
                                  _selectedFormat,
                                  (val) => setState(() => _selectedFormat = val!)),
                              const SizedBox.shrink(),
                            ]),
                            SizedBox(height: context.spacing),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _fetchBooks,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: context.spacing / 2),
                                    ),
                                    child: const Text("APPLY FILTERS"),
                                  ),
                                ),
                                SizedBox(width: context.spacing / 2),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _resetFilters,
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: context.spacing / 2),
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
                    SizedBox(height: context.spacing * 1.5),
                    Text("Books Collection",
                        style: context.theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold, fontSize: context.font(18))),
                    SizedBox(height: context.spacing),
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
                            padding: EdgeInsets.all(context.spacing),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) => _fetchBooks(),
                              decoration: InputDecoration(
                                hintText: "Quick search by title...",
                                hintStyle: TextStyle(fontSize: context.font(14)),
                                prefixIcon: Icon(Icons.search, size: context.scale(20)),
                              ),
                            ),
                          ),
                          if (_isLoading && _books.isEmpty)
                            Padding(
                                padding: EdgeInsets.all(context.spacing * 1.5),
                                child: const CircularProgressIndicator())
                          else if (_books.isEmpty)
                            Padding(
                                padding: EdgeInsets.all(context.spacing * 1.5),
                                child: const Center(child: Text("No books found")))
                          else
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: context.screenWidth -
                                        (context.isMobile
                                            ? context.scale(64)
                                            : context.scale(100))),
                                child: DataTable(
                                  columnSpacing: context.spacing,
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
                                        label: Text("Author",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: context.font(14)))),
                                    DataColumn(
                                        label: Text("Category",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: context.font(14)))),
                                    DataColumn(
                                        label: Text("Copies",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: context.font(14)))),
                                  ],
                                  rows: _books.asMap().entries.map((entry) {
                                    int idx = entry.key;
                                    Book book = entry.value;
                                    return DataRow(cells: [
                                      DataCell(Text("${idx + 1}",
                                          style: TextStyle(fontSize: context.font(14)))),
                                      DataCell(SizedBox(
                                          width: context.scale(200),
                                          child: Text(book.title,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: context.font(14))))),
                                      DataCell(Text(book.author ?? "-",
                                          style: TextStyle(fontSize: context.font(14)))),
                                      DataCell(Text(book.category ?? "-",
                                          style: TextStyle(fontSize: context.font(14)))),
                                      DataCell(Text("${book.availableCopies}",
                                          style: TextStyle(fontSize: context.font(14)))),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.spacing),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map((c) => Expanded(
              child: Padding(
                  padding: EdgeInsets.only(right: context.spacing / 2), child: c)))
          .toList(),
    );
  }

  Widget _buildTextField(
      BuildContext context, String label, String hint, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: context.theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold, fontSize: context.font(11))),
          SizedBox(height: context.spacing / 4),
          TextField(
            controller: controller,
            style: TextStyle(fontSize: context.font(14)),
            decoration: InputDecoration(
                hintText: hint,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: context.spacing / 2, vertical: context.spacing / 4)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String label, List<String> items,
      String value, Function(String?) onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: context.theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold, fontSize: context.font(11))),
          SizedBox(height: context.spacing / 4),
          DropdownButtonFormField<String>(
            value: items.contains(value) ? value : items.first,
            isExpanded: true,
            style: TextStyle(color: context.theme.colorScheme.onSurface),
            decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    horizontal: context.spacing / 2, vertical: context.spacing / 4)),
            items: items
                .map((String item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: TextStyle(fontSize: context.font(13)))))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

