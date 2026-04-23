import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:eduphin/services/caching_service.dart';
import 'package:eduphin/services/common_widgets.dart';

class LibraryBooksPage extends StatefulWidget {
  const LibraryBooksPage({super.key});

  @override
  State<LibraryBooksPage> createState() => _LibraryBooksPageState();
}

class _LibraryBooksPageState extends State<LibraryBooksPage> {
  List<dynamic> _books = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filters
  Map<String, String> _filters = {
    'title': '',
    'author': '',
    'isbn': '',
    'category': 'All',
    'language': 'All',
    'format': 'All',
    'publication_year': 'All',
  };

  // Dropdown data
  List<String> _categories = ['All'];
  List<String> _languages = ['All'];
  List<String> _formats = ['All'];
  List<String> _years = ['All'];

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchBooks();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CacheService.getData('student_library_books');
    if (cachedData != null && mounted) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(cachedData as Map? ?? {});
      setState(() {
        _books = List<dynamic>.from(data['books'] ?? []);
        if (_categories.length == 1 && data['filters'] != null) {
          final filters = Map<String, dynamic>.from(data['filters']);
          _categories.addAll(List<String>.from(filters['categories'] ?? []));
          _languages.addAll(List<String>.from(filters['languages'] ?? []));
          _formats.addAll(List<String>.from(filters['formats'] ?? []));
          _years.addAll(List<String>.from(filters['years']?.map((e) => e.toString()) ?? []));
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBooks() async {
    if (_books.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    _errorMessage = null;

    try {
      final response = await ApiService.getStudentLibraryBooks(_filters, 1);
      final data = response['data'];
      if (mounted) {
        setState(() {
          _books = data['books']['data'] ?? [];
          
          // Update filter options if they are empty (only once)
          if (_categories.length == 1) {
            _categories.addAll(List<String>.from(data['filters']['categories'] ?? []));
            _languages.addAll(List<String>.from(data['filters']['languages'] ?? []));
            _formats.addAll(List<String>.from(data['filters']['formats'] ?? []));
            _years.addAll(List<String>.from(data['filters']['years']?.map((e) => e.toString()) ?? []));
          }
          
          _isLoading = false;
        });
        await CacheService.saveData('student_library_books', {
          'books': _books,
          'filters': data['filters'],
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_books.isEmpty) {
            _errorMessage = e.toString();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to refresh: ${e.toString()}")),
            );
          }
        });
      }
    }
  }

  void _applyFilters() {
    _filters['title'] = _titleController.text;
    _filters['author'] = _authorController.text;
    _filters['isbn'] = _isbnController.text;
    _fetchBooks();
  }

  void _resetFilters() {
    _titleController.clear();
    _authorController.clear();
    _isbnController.clear();
    setState(() {
      _filters = {
        'title': '',
        'author': '',
        'isbn': '',
        'category': 'All',
        'language': 'All',
        'format': 'All',
        'publication_year': 'All',
      };
    });
    _fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Resources"),
      ),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// FILTER CARD
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.scale(16)),
                    side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(context.scale(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.filter_list, color: colorScheme.primary, size: context.scale(20)),
                            SizedBox(width: context.scale(8)),
                            Text(
                              "Search Resources",
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(20)),
                            ),
                          ],
                        ),
                        SizedBox(height: context.scale(20)),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double spacing = context.scale(16);
                            final int crossAxisCount = context.responsive(1, tablet: 2, desktop: 3);
                            final double itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: [
                                _buildFilterItem(context, "Title", buildTextField(context, _titleController, "Search Title"), itemWidth),
                                _buildFilterItem(context, "Author", buildTextField(context, _authorController, "Search Author"), itemWidth),
                                _buildFilterItem(context, "ISBN", buildTextField(context, _isbnController, "Search ISBN"), itemWidth),
                                _buildFilterItem(context, "Category", buildDropdown(context, _categories, 'category'), itemWidth),
                                _buildFilterItem(context, "Language", buildDropdown(context, _languages, 'language'), itemWidth),
                                _buildFilterItem(context, "Format", buildDropdown(context, _formats, 'format'), itemWidth),
                                _buildFilterItem(context, "Year", buildDropdown(context, _years, 'publication_year'), itemWidth),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: context.scale(24)),

                        /// Apply & Reset
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                ),
                                onPressed: _applyFilters,
                                child: Text("APPLY FILTERS", style: TextStyle(fontSize: context.font(14))),
                              ),
                            ),
                            SizedBox(width: context.scale(12)),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: context.scale(16)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(12))),
                                  backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  foregroundColor: colorScheme.onSurface,
                                  elevation: 0,
                                ),
                                onPressed: _resetFilters,
                                child: Text("RESET", style: TextStyle(fontSize: context.font(14))),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: context.scale(24)),

                /// RESULTS TABLE
                LoadingWrapper(
                  isLoading: _isLoading,
                  hasData: _books.isNotEmpty,
                  error: _errorMessage,
                  skeleton: const _BooksSkeleton(),
                  onRetry: _fetchBooks,
                  child: Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.scale(16)),
                      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(context.scale(20.0)),
                          child: Text(
                            "Available Books",
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(18)),
                          ),
                        ),
                        if (_books.isEmpty)
                          Center(child: Padding(padding: EdgeInsets.all(context.scale(40.0)), child: Text("No books found", style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurfaceVariant))))
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: context.screenWidth - context.scale(64)),
                              child: Theme(
                                data: theme.copyWith(dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                                  columnSpacing: context.responsive(24.0, tablet: 48.0, desktop: 64.0),
                                  columns: [
                                    DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                    DataColumn(label: Text("TITLE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                    DataColumn(label: Text("AUTHOR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                    DataColumn(label: Text("ISBN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                    DataColumn(label: Text("COPIES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(14)))),
                                  ],
                                  rows: _books.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    var book = entry.value;
                                    return DataRow(cells: [
                                      DataCell(Text((index + 1).toString(), style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface))),
                                      DataCell(Text(book['title'] ?? 'N/A', style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface))),
                                      DataCell(Text(book['author'] ?? 'N/A', style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface))),
                                      DataCell(Text(book['isbn'] ?? 'N/A', style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface))),
                                      DataCell(Text(book['available_copies']?.toString() ?? '0', style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface))),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: context.scale(12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterItem(BuildContext context, String label, Widget child, double width) {
    final colorScheme = context.theme.colorScheme;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: context.scale(8), bottom: context.scale(8)),
            child: Text(
              label,
              style: TextStyle(fontSize: context.font(14), fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
            ),
          ),
          child,
        ],
      ),
    );
  }

  /// ========== Common Widgets ==========

  Widget buildTextField(BuildContext context, TextEditingController controller, String hint) {
    final colorScheme = context.theme.colorScheme;
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: context.font(14), color: colorScheme.onSurfaceVariant),
        isDense: true,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(context.scale(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(context.scale(12)),
        ),
      ),
    );
  }

  Widget buildDropdown(BuildContext context, List<String> items, String filterKey) {
    final colorScheme = context.theme.colorScheme;
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _filters[filterKey],
      dropdownColor: colorScheme.surfaceContainerLow,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(fontSize: context.font(14), color: colorScheme.onSurface)),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _filters[filterKey] = newValue!;
        });
      },
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: EdgeInsets.symmetric(horizontal: context.scale(16), vertical: context.scale(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(context.scale(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(context.scale(12)),
        ),
      ),
    );
  }
}

class _BooksSkeleton extends StatelessWidget {
  const _BooksSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scale(16)),
        side: BorderSide(color: context.theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.scale(20)),
            child: SkeletonBox(width: context.scale(120), height: context.scale(20), borderRadius: context.scale(4)),
          ),
          ...List.generate(5, (index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(12)),
            child: Row(
              children: [
                SkeletonBox(width: context.scale(30), height: context.scale(16), borderRadius: context.scale(4)),
                SizedBox(width: context.scale(16)),
                Expanded(child: SkeletonBox(height: context.scale(16), borderRadius: context.scale(4))),
                SizedBox(width: context.scale(16)),
                SkeletonBox(width: context.scale(60), height: context.scale(16), borderRadius: context.scale(4)),
              ],
            ),
          )),
          SizedBox(height: context.scale(12)),
        ],
      ),
    );
  }
}
