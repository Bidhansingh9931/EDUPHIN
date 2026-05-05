import 'package:eduphin/services/error_handler.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eduphin/moderator_dashboard/cache_helper.dart';
import 'package:eduphin/moderator_dashboard/skeleton_widgets.dart';
import 'package:eduphin/services/api_service.dart';
import 'package:eduphin/services/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. Data Model for a Class
class ClassInfo {
  final String name;
  final String section;

  ClassInfo({
    required this.name,
    required this.section,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      name: json['name'] ?? 'No Name',
      section: json['section'] ?? 'No Section',
    );
  }
}

// 2. Data Provider to fetch class data
class ClassProvider {
  static const String _cacheKeyPrefix = 'classes_list_';

  Future<List<ClassInfo>> fetchClasses(String instituteId, {bool bypassCache = false}) async {
    try {
      if (!bypassCache) {
        final cached = await getCachedClasses(instituteId);
        if (cached != null) return cached;
      }
      final token = await ApiService.getToken();
      if (token == null) {
        throw ApiException('Session expired. Please log in again.', statusCode: 401);
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/moderator/institutes/$instituteId/classes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['classes'] != null) {
          await CacheHelper.save(_cacheKeyPrefix + instituteId, data);
          final List<dynamic> classesJson = data['classes'];
          return classesJson.map((json) => ClassInfo.fromJson(json)).toList();
        } else {
          throw ApiException(data['message'] ?? 'Failed to load classes');
        }
      } else {
        throw ApiException('Failed to load classes', statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ApiException || e is NetworkException) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<ClassInfo>?> getCachedClasses(String instituteId) async {
    final cached = await CacheHelper.load(_cacheKeyPrefix + instituteId);
    if (cached != null && cached['classes'] != null) {
      final List<dynamic> classesJson = cached['classes'];
      return classesJson.map((json) => ClassInfo.fromJson(json)).toList();
    }
    return null;
  }
}

// 3. Updated StatefulWidget
class ClassesPage extends StatefulWidget {
  final String instituteId;
  const ClassesPage({super.key, required this.instituteId});

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  final ClassProvider _provider = ClassProvider();
  late Future<List<ClassInfo>> _classesFuture;
  List<ClassInfo>? _cachedClasses;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _cachedClasses = await _provider.getCachedClasses(widget.instituteId);
    _refreshClasses();
  }

  Future<void> _refreshClasses({bool bypassCache = false}) async {
    setState(() {
      _classesFuture = _provider.fetchClasses(widget.instituteId, bypassCache: bypassCache);
    });
    try {
      await _classesFuture;
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Institute Classes', style: TextStyle(fontSize: context.font(20), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => _refreshClasses(bypassCache: true),
            icon: Icon(Icons.refresh_rounded, size: context.scale(24)),
          ),
          SizedBox(width: context.md),
        ],
      ),
      body: FutureBuilder<List<ClassInfo>>(
        future: _classesFuture,
        builder: (context, snapshot) {
          return ModeratorLoadingWrapper<List<ClassInfo>>(
            snapshot: snapshot,
            cachedData: _cachedClasses,
            skeleton: const ListSkeleton(),
            onRefresh: () => _refreshClasses(bypassCache: true),
            builder: (classes) {
              if (classes.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: () => _refreshClasses(bypassCache: true),
                color: theme.colorScheme.primary,
                child: SingleChildScrollView(
                  padding: context.pagePadding,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: context.scale(1200)),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: classes.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: context.responsive(1, tablet: 2, desktop: 3),
                          crossAxisSpacing: context.md,
                          mainAxisSpacing: context.md,
                          mainAxisExtent: context.scale(100),
                        ),
                        itemBuilder: (context, index) {
                          return _buildClassCard(context, classes[index]);
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassInfo classInfo) {
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
        leading: Container(
          padding: EdgeInsets.all(context.sm),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.sm),
          ),
          child: Icon(Icons.class_rounded, color: colorScheme.primary, size: context.scale(24)),
        ),
        title: Text(
          classInfo.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16), color: theme.colorScheme.onSurface),
        ),
        subtitle: Text(
          "Section: ${classInfo.section}",
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14)),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: context.scale(16), color: theme.colorScheme.onSurfaceVariant),
        onTap: () {},
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.class_outlined, size: context.scale(64), color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
          SizedBox(height: context.md),
          Text("No classes found", style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.font(16), color: theme.colorScheme.onSurfaceVariant)),
          SizedBox(height: context.sm),
          Text("There are no classes recorded for this institute.", textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: context.font(14))),
        ],
      ),
    );
  }
}
