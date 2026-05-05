import 'package:eduphin/services/error_handler.dart';
import 'dart:async';
import 'dart:io';
import 'package:eduphin/moderator_dashboard/cache_helper.dart';
import 'package:eduphin/moderator_dashboard/skeleton_widgets.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';

// 1. Data Model for an Exam Type
class ExamType {
  final String name;
  final String description;

  ExamType({
    required this.name,
    required this.description,
  });

  factory ExamType.fromJson(Map<String, dynamic> json) {
    return ExamType(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}

// 2. Data Provider to fetch exam types
class ExamTypeProvider {
  static const String _cacheKey = 'moderator_exam_types_list';

  Future<List<ExamType>> fetchExamTypes({bool bypassCache = false}) async {
    try {
      if (!bypassCache) {
        final cached = await CacheHelper.load(_cacheKey);
        if (cached != null && cached is List) {
          return (cached as List).map((e) => ExamType.fromJson(e)).toList();
        }
      }
      // Placeholder logic for now, but adding error handling structure
      await Future.delayed(const Duration(seconds: 2));
      final data = List.generate(
        15,
        (index) => ExamType(
          name: 'Exam Type ${index + 1}',
          description: 'Description for exam type ${index + 1}',
        ),
      );
      await CacheHelper.save(_cacheKey, data.map((e) => e.toJson()).toList());
      return data;
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw Exception('Failed to fetch exam types: $e');
    }
  }
}

// 3. StatefulWidget to handle dynamic data
class ExamTypesPage extends StatefulWidget {
  const ExamTypesPage({super.key});

  @override
  State<ExamTypesPage> createState() => _ExamTypesPageState();
}

class _ExamTypesPageState extends State<ExamTypesPage> {
  final ExamTypeProvider _provider = ExamTypeProvider();
  late Future<List<ExamType>> _examTypesFuture;
  List<ExamType>? _cachedData;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _examTypesFuture = _provider.fetchExamTypes();
  }

  Future<void> _loadCachedData() async {
    final cached = await CacheHelper.load(ExamTypeProvider._cacheKey);
    if (cached != null && cached is List) {
      setState(() {
        _cachedData = cached.map((e) => ExamType.fromJson(e)).toList();
      });
    }
  }

  Future<void> _refreshData({bool bypassCache = false}) async {
    setState(() {
      _examTypesFuture = _provider.fetchExamTypes(bypassCache: bypassCache);
    });
    try {
      await _examTypesFuture;
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Exam Types',
          style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<ExamType>>(
        future: _examTypesFuture,
        builder: (context, snapshot) {
          return ModeratorLoadingWrapper<List<ExamType>>(
            snapshot: snapshot,
            cachedData: _cachedData,
            skeleton: const ListSkeleton(),
            onRefresh: () async => _refreshData(bypassCache: true),
            builder: (examTypes) {
              if (examTypes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: context.scale(64), color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                      SizedBox(height: context.md),
                      Text('No exam types found.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(16), fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _refreshData(bypassCache: true),
                child: GridView.builder(
                  padding: context.pagePadding,
                  itemCount: examTypes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                    crossAxisSpacing: context.md,
                    mainAxisSpacing: context.md,
                    mainAxisExtent: context.scale(100),
                  ),
                  itemBuilder: (context, index) {
                    return ExamTypeCard(
                      examType: examTypes[index],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ExamTypeCard extends StatelessWidget {
  final ExamType examType;

  const ExamTypeCard({
    super.key,
    required this.examType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.md),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: context.md, vertical: context.sm),
        leading: CircleAvatar(
          radius: context.scale(20),
          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.laptop_chromebook_outlined, color: colorScheme.primary, size: context.scale(22)),
        ),
        title: Text(
          examType.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16), color: theme.colorScheme.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          examType.description,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(13)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {},
      ),
    );
  }
}
