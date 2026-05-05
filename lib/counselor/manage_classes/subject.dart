import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/error_handler.dart';
import '../../services/caching_service.dart';
import '../../services/common_widgets.dart';
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
  final String _cacheKey = 'counselor_manage_subjects_data';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchSubjects();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CachingService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      _processData(cachedData);
    }
  }

  void _processData(dynamic data) {
    final jsonResponse = data is String ? jsonDecode(data) : data;
    final dataMap = jsonResponse['data'] is Map ? jsonResponse['data'] : jsonResponse;
    final List rawList = dataMap['subjects'] is List 
        ? dataMap['subjects'] 
        : (dataMap['subject'] is List ? dataMap['subject'] : []);
    
    setState(() {
      _subjects = rawList.map((s) => Subject.fromJson(s)).toList();
      _isLoading = false;
      _errorMessage = null;
    });
  }

  Future<void> _fetchSubjects() async {
    if (_subjects.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final response = await ApiService.get('counselor/subjects');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await CachingService.saveData(_cacheKey, data);
        if (mounted) {
          _processData(data);
        }
      } else {
        if (mounted) {
          if (_subjects.isEmpty) {
            setState(() {
              _errorMessage = ErrorHandler.getMessage("Status: ${response.statusCode}");
              _isLoading = false;
            });
          }
          ErrorHandler.showError(context, "Status: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (mounted) {
        if (_subjects.isEmpty) {
          setState(() {
            _errorMessage = ErrorHandler.getMessage(e);
            _isLoading = false;
          });
        }
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
          child: Card(
            elevation: 0,
            child: Padding(
              padding: context.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Skeleton(width: 180, height: 20),
                  const SizedBox(height: 24),
                  const Skeleton(width: double.infinity, height: 48),
                  const SizedBox(height: 24),
                  Column(
                    children: List.generate(5, (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Skeleton(width: 30, height: 20),
                          const SizedBox(width: 16),
                          const Skeleton(width: 150, height: 20),
                          const Spacer(),
                          const Skeleton(width: 60, height: 20),
                          const SizedBox(width: 16),
                          const Skeleton(width: 40, height: 40, borderRadius: 20),
                        ],
                      ),
                    )),
                  ),
                ],
              ),
            ),
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
        title: const Text("Subject Management"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSubjects,
        child: LoadingWrapper(
          isLoading: _isLoading,
          hasData: _subjects.isNotEmpty,
          error: _errorMessage,
          skeleton: _buildSkeleton(),
          onRetry: _fetchSubjects,
          child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: context.pagePadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Card(
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
                          padding: context.pagePadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Available Subjects",
                                  style: context.theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.font(18))),
                              SizedBox(height: context.md),
                              TextField(
                                decoration: InputDecoration(
                                  hintText: "Search subjects...",
                                  hintStyle: TextStyle(fontSize: context.font(14)),
                                  prefixIcon:
                                      Icon(Icons.search, size: context.scale(20)),
                                ),
                              ),
                              SizedBox(height: context.lg),
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
                                        label: Text("Subject Name",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: context.font(14)))),
                                    DataColumn(
                                        label: Text("Code",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: context.font(14)))),
                                    DataColumn(
                                        label: Text("Actions",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: context.font(14)))),
                                  ],
                                  rows: _subjects.asMap().entries.map((entry) {
                                    int idx = entry.key;
                                    Subject s = entry.value;
                                    return DataRow(
                                      cells: [
                                        DataCell(Text("${idx + 1}",
                                            style:
                                                TextStyle(fontSize: context.font(14)))),
                                        DataCell(Text(s.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: context.font(14)))),
                                        DataCell(
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: context.xs,
                                                vertical: context.xs / 2),
                                            decoration: BoxDecoration(
                                              color: context.theme.colorScheme.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(
                                                  context.scale(6)),
                                            ),
                                            child: Text(
                                              s.code ?? "-",
                                              style: TextStyle(
                                                  color:
                                                      context.theme.colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: context.font(11)),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          IconButton(
                                            icon: Icon(Icons.info_outline,
                                                color: context.theme.colorScheme.primary,
                                                size: context.scale(20)),
                                            onPressed: () {},
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                              if (_subjects.isEmpty)
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: context.scale(40)),
                                  child: const Center(child: Text("No subjects available")),
                                ),
                            ],
                          ),
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

