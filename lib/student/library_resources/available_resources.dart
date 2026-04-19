import 'package:flutter/material.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';

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
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getStudentLibraryBooks(_filters, 1);
      setState(() {
        _books = response['data']['books']['data'] ?? [];
        
        // Update filter options if they are empty (only once)
        if (_categories.length == 1) {
          _categories.addAll(List<String>.from(response['data']['filters']['categories'] ?? []));
          _languages.addAll(List<String>.from(response['data']['filters']['languages'] ?? []));
          _formats.addAll(List<String>.from(response['data']['filters']['formats'] ?? []));
          _years.addAll(List<String>.from(response['data']['filters']['years']?.map((e) => e.toString()) ?? []));
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
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
                Card(
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
                      if (_isLoading)
                        Center(child: Padding(padding: EdgeInsets.all(context.scale(40.0)), child: CircularProgressIndicator(color: colorScheme.primary)))
                      else if (_errorMessage != null)
                        Center(child: Padding(padding: EdgeInsets.all(context.scale(40.0)), child: Text(_errorMessage!, style: TextStyle(color: colorScheme.error, fontSize: context.font(14)))))
                      else if (_books.isEmpty)
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
      value: _filters[filterKey],
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
