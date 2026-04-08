import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../counselor_models.dart';

class SubjectManagementPage extends StatefulWidget {
  const SubjectManagementPage({super.key});

  @override
  State<SubjectManagementPage> createState() => _SubjectManagementPageState();
}

class _SubjectManagementPageState extends State<SubjectManagementPage> {
  bool _isLoading = true;
  List<Subject> _subjects = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiService.get('counselor/subjects');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            dynamic subjectsData = data['subject'] ?? data['data'] ?? [];
            List rawList = [];
            if (subjectsData is List) {
              rawList = subjectsData;
            } else if (subjectsData is Map && subjectsData['data'] is List) {
              rawList = subjectsData['data'];
            }
            
            _subjects = rawList.map((s) => Subject.fromJson(s)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to load subjects";
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
        title: const Text("Subject Management"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
                ))
              : RefreshIndicator(
                  onRefresh: _fetchSubjects,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: context.pagePadding,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Available Subjects", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                TextField(
                                  decoration: const InputDecoration(
                                    hintText: "Search subjects...",
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columnSpacing: 24,
                                    headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withValues(alpha: 0.05)),
                                    columns: const [
                                      DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Subject Name", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Code", style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                    rows: _subjects.asMap().entries.map((entry) {
                                      int idx = entry.key;
                                      Subject s = entry.value;
                                      return DataRow(
                                        cells: [
                                          DataCell(Text("${idx + 1}")),
                                          DataCell(Text(s.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                s.code ?? "-",
                                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            IconButton(
                                              icon: Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
                                              onPressed: () {},
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                                if (_subjects.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    child: Center(child: Text("No subjects available")),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
