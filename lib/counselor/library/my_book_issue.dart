import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
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

  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _dueFromController = TextEditingController();
  final TextEditingController _dueToController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLendingHistory();
  }

  Future<void> _fetchLendingHistory() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final queryParams = <String, String>{};
      if (_bookTitleController.text.isNotEmpty) queryParams['book_title'] = _bookTitleController.text;
      if (_dueFromController.text.isNotEmpty) queryParams['due_from'] = _dueFromController.text;
      if (_dueToController.text.isNotEmpty) queryParams['due_to'] = _dueToController.text;

      final response = await ApiService.get('counselor/library/lending', queryParams);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            dynamic booksData = data['issuedBooks'] ?? data['data'] ?? [];
            List rawList = [];
            if (booksData is List) {
              rawList = booksData;
            } else if (booksData is Map && booksData['data'] is List) {
              rawList = booksData['data'];
            }
            
            _issuedBooks = rawList.map((json) => IssuedBook.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to load lending history";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Issued Books"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLendingHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: context.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Search Filters", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          _buildResponsiveRow(context, [
                            _buildTextField(context, "Book Title", _bookTitleController),
                            _buildDateField(context, "Due Date From", _dueFromController),
                          ]),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: ElevatedButton(onPressed: _fetchLendingHistory, child: const Text("APPLY"))),
                              const SizedBox(width: 12),
                              Expanded(child: OutlinedButton(
                                onPressed: () {
                                  _bookTitleController.clear();
                                  _dueFromController.clear();
                                  _dueToController.clear();
                                  _fetchLendingHistory();
                                },
                                child: const Text("RESET"),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: "Quick search...",
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        if (_isLoading)
                          const Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator())
                        else if (_issuedBooks.isEmpty)
                          const Padding(padding: EdgeInsets.all(40.0), child: Center(child: Text("No records found")))
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 24,
                              headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withValues(alpha: 0.05)),
                              columns: const [
                                DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Title", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Issued", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Due Date", style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: _issuedBooks.where((b) => b.book.title.toLowerCase().contains(_searchController.text.toLowerCase())).toList().asMap().entries.map((entry) {
                                int idx = entry.key;
                                IssuedBook issue = entry.value;
                                bool isReturned = issue.returnedAt != null;
                                return DataRow(cells: [
                                  DataCell(Text("${idx + 1}")),
                                  DataCell(SizedBox(width: 150, child: Text(issue.book.title, style: const TextStyle(fontWeight: FontWeight.w500)))),
                                  DataCell(Text(issue.issuedAt ?? "-")),
                                  DataCell(Text(issue.dueDate ?? "-")),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (isReturned ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: (isReturned ? Colors.green : Colors.orange).withValues(alpha: 0.5)),
                                      ),
                                      child: Text(
                                        isReturned ? "Returned" : "Pending",
                                        style: TextStyle(
                                          color: isReturned ? Colors.green : Colors.orange,
                                          fontSize: 10,
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
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, List<Widget> children) {
    if (!context.isTablet) return Column(children: children);
    return Row(children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList());
  }

  Widget _buildTextField(BuildContext context, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2101));
          if (picked != null) controller.text = DateFormat("yyyy-MM-dd").format(picked);
        },
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}
