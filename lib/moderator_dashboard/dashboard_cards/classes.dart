import 'dart:async';
import 'dart:convert';
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
  Future<List<ClassInfo>> fetchClasses(String instituteId) async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
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
        final List<dynamic> classesJson = data['classes'];
        return classesJson.map((json) => ClassInfo.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load classes.');
      }
    } else {
      throw Exception('Failed to load classes. Status Code: ${response.statusCode}');
    }
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

  @override
  void initState() {
    super.initState();
    _classesFuture = _provider.fetchClasses(widget.instituteId);
  }

  Future<void> _refreshClasses() async {
    setState(() {
      _classesFuture = _provider.fetchClasses(widget.instituteId);
    });
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
            onPressed: _refreshClasses,
            icon: Icon(Icons.refresh_rounded, size: context.scale(24)),
          ),
          SizedBox(width: context.md),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshClasses,
        color: theme.colorScheme.primary,
        child: FutureBuilder<List<ClassInfo>>(
          future: _classesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: context.pagePadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: context.scale(48), color: colorScheme.error),
                      SizedBox(height: context.md),
                      Text('Error: ${snapshot.error}', textAlign: TextAlign.center, style: TextStyle(fontSize: context.font(14), color: theme.colorScheme.onSurface)),
                      SizedBox(height: context.lg),
                      ElevatedButton(
                        onPressed: _refreshClasses,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        child: Text("Retry", style: TextStyle(fontSize: context.font(16))),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState(context);
            }

            final classes = snapshot.data!;

            return SingleChildScrollView(
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
            );
          },
        ),
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
