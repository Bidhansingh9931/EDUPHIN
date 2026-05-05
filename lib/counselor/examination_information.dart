import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/error_handler.dart';
import '../../services/caching_service.dart';
import '../../services/common_widgets.dart';
import 'counselor_models.dart';
import 'exam_schedule.dart';

class ExamListPage extends StatefulWidget {
  const ExamListPage({super.key});

  @override
  State<ExamListPage> createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage> {
  bool _isLoading = true;
  List<ExamType> _exams = [];
  String? _errorMessage;
  final String _cacheKey = 'counselor_exam_list_data';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchExams();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CachingService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      final data = cachedData['data'] ?? cachedData;
      final List examData = data['exams'] ?? data['instituteexam'] ?? [];
      setState(() {
        _exams = examData.map((e) => ExamType.fromJson(e)).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchExams() async {
    if (_exams.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final response = await ApiService.get('counselor/exams');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await CachingService.saveData(_cacheKey, data);
        if (mounted) {
          final examDataList = data['data'] ?? data['instituteexam'] ?? [];
          setState(() {
            _exams = (examDataList as List).map((e) => ExamType.fromJson(e)).toList();
            _isLoading = false;
            _errorMessage = null;
          });
        }
      } else {
        if (mounted && _exams.isEmpty) {
          setState(() {
            _errorMessage = ErrorHandler.getMessage("Failed to load exams. Status: ${response.statusCode}");
            _isLoading = false;
          });
          ErrorHandler.showError(context, _errorMessage);
        }
      }
    } catch (e) {
      if (mounted && _exams.isEmpty) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(width: 150, height: 20),
                      SizedBox(height: 16),
                      Skeleton(width: double.infinity, height: 48),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.all(20), child: Skeleton(width: 180, height: 20)),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: List.generate(
                          5,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(5, (i) => Skeleton(width: 80, height: 12)),
                            ),
                          ),
                        ),
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
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Examination List", style: TextStyle(fontSize: context.font(20))),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchExams,
        child: LoadingWrapper(
          isLoading: _isLoading,
          hasData: _exams.isNotEmpty,
          skeleton: _buildSkeleton(),
          child: _errorMessage != null && _exams.isEmpty
              ? Center(
                  child: Padding(
                  padding: EdgeInsets.all(context.scale(24.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: theme.colorScheme.error, size: context.scale(48)),
                      SizedBox(height: context.md),
                      Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error, fontSize: context.font(14))),
                      SizedBox(height: context.lg),
                      FilledButton.icon(onPressed: _fetchExams, icon: const Icon(Icons.refresh), label: const Text("RETRY")),
                    ],
                  ),
                ))
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: context.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: Padding(
                              padding: EdgeInsets.all(context.scale(20)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Search Active Exams", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                                  SizedBox(height: context.scale(16)),
                                  TextField(
                                    style: TextStyle(fontSize: context.font(14)),
                                    decoration: InputDecoration(
                                      hintText: "Search by exam name or code...",
                                      prefixIcon: Icon(Icons.search, size: context.scale(20)),
                                      hintStyle: TextStyle(fontSize: context.font(14)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: context.scale(24)),
                          Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(context.scale(20)),
                                  child: Text("Exams Collection", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: context.font(16))),
                                ),
                                const Divider(height: 1),
                                if (_exams.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.all(context.scale(40.0)),
                                    child: Center(child: Text("No active exams found", style: TextStyle(fontSize: context.font(14)))),
                                  )
                                else
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
                                      columnSpacing: context.scale(20),
                                      columns: [
                                        DataColumn(label: Text("#", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("Exam Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("Code", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                        DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(12)))),
                                      ],
                                      rows: _exams.asMap().entries.map((entry) {
                                        int idx = entry.key;
                                        ExamType exam = entry.value;
                                        return DataRow(cells: [
                                          DataCell(Text("${idx + 1}", style: TextStyle(fontSize: context.font(12)))),
                                          DataCell(SizedBox(width: context.scale(180), child: Text(exam.name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: context.font(12))))),
                                          DataCell(Container(
                                            padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(4)),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                                              borderRadius: BorderRadius.circular(context.scale(6)),
                                            ),
                                            child: Text(
                                              (exam.type ?? "WRITTEN").toUpperCase(),
                                              style: TextStyle(color: theme.colorScheme.onSecondaryContainer, fontSize: context.font(11), fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                          DataCell(Text(exam.code ?? "-", style: TextStyle(fontSize: context.font(12)))),
                                          DataCell(Text("${exam.startDate ?? ''} - ${exam.endDate ?? ''}", style: TextStyle(fontSize: context.font(11)))),
                                          DataCell(
                                            TextButton(
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (_) => ExamSchedulePage(exam: exam)));
                                              },
                                              child: Text("VIEW", style: TextStyle(fontSize: context.font(11), fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}


