import 'dart:convert';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/error_handler.dart';
import '../../services/caching_service.dart';
import '../../services/common_widgets.dart';
import '../counselor_models.dart';

class ManageClassesPage extends StatefulWidget {
  const ManageClassesPage({super.key});

  @override
  State<ManageClassesPage> createState() => _ManageClassesPageState();
}

class _ManageClassesPageState extends State<ManageClassesPage> {
  bool _isLoading = true;
  List<ClassInfo> _classes = [];
  String? _errorMessage;
  final String _cacheKey = 'counselor_manage_classes_data';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchClasses();
  }

  Future<void> _loadCachedData() async {
    final cachedData = await CachingService.getData(_cacheKey);
    if (cachedData != null && mounted) {
      _processData(cachedData);
    }
  }

  void _processData(dynamic data) {
    final jsonResponse = data is String ? jsonDecode(data) : data;
    final responseData = jsonResponse['data'] is Map ? jsonResponse['data'] : jsonResponse;
    
    final List classesJson = responseData['classes'] is List ? responseData['classes'] : [];
    final List sectionsJson = responseData['sections'] is List ? responseData['sections'] : [];

    setState(() {
      _classes = classesJson.map((classMap) {
        final classId = classMap['id'];
        final classSections = sectionsJson.where((s) => s['class_id'] == classId).toList();
        
        final fullClassMap = Map<String, dynamic>.from(classMap);
        fullClassMap['sections'] = classSections;
        
        return ClassInfo.fromJson(fullClassMap);
      }).toList();
      _isLoading = false;
      _errorMessage = null;
    });
  }

  Future<void> _fetchClasses() async {
    if (_classes.isEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final response = await ApiService.get('counselor/classes');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await CachingService.saveData(_cacheKey, data);
        if (mounted) {
          _processData(data);
        }
      } else {
        if (mounted) {
          if (_classes.isEmpty) {
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
        if (_classes.isEmpty) {
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
    return GridView.builder(
      padding: context.pagePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
        mainAxisExtent: context.scale(200),
        crossAxisSpacing: context.spacing,
        mainAxisSpacing: context.spacing,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(context.spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Skeleton(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Skeleton(width: 120, height: 16),
                        const SizedBox(height: 8),
                        const Skeleton(width: 60, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Skeleton(width: 80, height: 12),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(3, (i) => const Skeleton(width: 50, height: 24, borderRadius: BorderRadius.all(Radius.circular(12)))),
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
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: const Text("Manage Classes"),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchClasses,
        child: LoadingWrapper(
          isLoading: _isLoading,
          hasData: _classes.isNotEmpty,
          error: _errorMessage,
          skeleton: _buildSkeleton(),
          onRetry: _fetchClasses,
          child: _classes.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: context.scale(200)),
                        Center(
                            child: Text("No classes found",
                                style: TextStyle(color: context.theme.hintColor))),
                      ],
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: GridView.builder(
                          padding: context.pagePadding,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                            mainAxisExtent: context.scale(200),
                            crossAxisSpacing: context.spacing,
                            mainAxisSpacing: context.spacing,
                          ),
                          itemCount: _classes.length,
                          itemBuilder: (context, index) {
                            final classInfo = _classes[index];
                            final isActive = classInfo.status == 1;
                            return Card(
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
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: context.scale(20),
                                          backgroundColor: context.theme.colorScheme.primary
                                              .withValues(alpha: 0.1),
                                          child: Icon(Icons.class_outlined,
                                              color: context.theme.colorScheme.primary,
                                              size: context.scale(20)),
                                        ),
                                        SizedBox(width: context.sm),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.centerLeft,
                                                child: Text(classInfo.name,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: context.font(16))),
                                              ),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.centerLeft,
                                                child: Text(isActive ? "ACTIVE" : "INACTIVE",
                                                    style: TextStyle(
                                                        color: isActive ? Colors.green : Colors.red,
                                                        fontSize: context.font(10),
                                                        fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.edit_outlined,
                                                size: context.scale(20))),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text("SECTIONS",
                                        style: context.theme.textTheme.labelSmall?.copyWith(
                                            color: context.theme.hintColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: context.font(10))),
                                    SizedBox(height: context.xs),
                                    Expanded(
                                      flex: 2,
                                      child: SingleChildScrollView(
                                        child: Wrap(
                                          spacing: context.xs,
                                          runSpacing: context.xs,
                                          children: classInfo.sections
                                              .map((s) => Chip(
                                                    label: Text(s.name,
                                                        style: TextStyle(fontSize: context.font(11))),
                                                    padding: EdgeInsets.zero,
                                                    visualDensity: VisualDensity.compact,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize.shrinkWrap,
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}

